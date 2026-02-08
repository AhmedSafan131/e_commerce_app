import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_app/core/usecases/usecase.dart';
import 'package:e_commerce_app/features/products/domain/usecases/get_categories_usecase.dart';

class CategoriesCubit extends Cubit<List<String>> {
  final GetCategoriesUseCase getCategoriesUseCase;

  CategoriesCubit({required this.getCategoriesUseCase}) : super([]);

  Future<void> loadCategories() async {
    final result = await getCategoriesUseCase(NoParams());
    result.fold(
      (failure) => null, // Handle error or ignore
      (categories) => emit(categories),
    );
  }
}
