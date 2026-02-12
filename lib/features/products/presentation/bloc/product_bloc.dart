import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_app/features/products/domain/usecases/get_categories_usecase.dart';
import 'package:e_commerce_app/features/products/domain/usecases/get_products_usecase.dart';
import 'package:e_commerce_app/features/products/presentation/bloc/product_event.dart';
import 'package:e_commerce_app/features/products/presentation/bloc/product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  ProductBloc({required this.getProductsUseCase, required this.getCategoriesUseCase}) : super(ProductInitial()) {
    on<GetProductsEvent>(_onGetProducts);
    on<LoadMoreProductsEvent>(_onLoadMoreProducts);
    on<GetCategoriesEvent>(_onGetCategories);
  }

  Future<void> _onGetProducts(GetProductsEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await getProductsUseCase(GetProductsParams(category: event.category, query: event.query, page: 1));

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (products) => emit(
        ProductLoaded(
          products: products,
          hasReachedMax: products.length < 10,
          category: event.category,
          query: event.query,
          page: 1,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreProducts(LoadMoreProductsEvent event, Emitter<ProductState> emit) async {
    final currentState = state;
    if (currentState is ProductLoaded && !currentState.hasReachedMax) {
      final nextPage = currentState.page + 1;
      final result = await getProductsUseCase(
        GetProductsParams(category: currentState.category, query: currentState.query, page: nextPage),
      );

      result.fold(
        (failure) => emit(ProductError(message: failure.message)),
        (products) => emit(
          products.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : currentState.copyWith(
                  products: currentState.products + products,
                  page: nextPage,
                  hasReachedMax: products.length < 10,
                ),
        ),
      );
    }
  }

  Future<void> _onGetCategories(GetCategoriesEvent event, Emitter<ProductState> emit) async {
    // Note: This logic assumes a separate bloc or state for categories if mixed with products.
    // Ideally, we might want a separate CategoriesCubit.
    // For simplicity, we might just load them when needed or use a different state.
    // But since ProductState is a union, switching to CategoriesLoaded would hide the products.
    // Better to have a separate Cubit for Categories or include categories in ProductLoaded.
    // For now, let's assume this event is called separately or we just print it.
    // Actually, let's create a CategoriesCubit.
  }
}
