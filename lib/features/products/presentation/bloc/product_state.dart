import 'package:equatable/equatable.dart';
import 'package:e_commerce_app/features/products/domain/entities/product_entity.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductEntity> products;
  final bool hasReachedMax;
  final String? category;
  final String? query;
  final int page;

  const ProductLoaded({
    required this.products,
    this.hasReachedMax = false,
    this.category,
    this.query,
    this.page = 1,
  });

  ProductLoaded copyWith({
    List<ProductEntity>? products,
    bool? hasReachedMax,
    String? category,
    String? query,
    int? page,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      category: category ?? this.category,
      query: query ?? this.query,
      page: page ?? this.page,
    );
  }

  @override
  List<Object> get props => [products, hasReachedMax, category ?? '', query ?? '', page];
}

class ProductError extends ProductState {
  final String message;

  const ProductError({required this.message});

  @override
  List<Object> get props => [message];
}

class CategoriesLoaded extends ProductState {
  final List<String> categories;

  const CategoriesLoaded({required this.categories});

  @override
  List<Object> get props => [categories];
}
