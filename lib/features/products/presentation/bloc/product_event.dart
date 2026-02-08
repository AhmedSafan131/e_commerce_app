import 'package:equatable/equatable.dart';
import 'package:e_commerce_app/features/products/domain/entities/product_entity.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class GetProductsEvent extends ProductEvent {
  final String? category;
  final String? query;
  final bool isRefresh;

  const GetProductsEvent({this.category, this.query, this.isRefresh = false});

  @override
  List<Object> get props => [category ?? '', query ?? '', isRefresh];
}

class LoadMoreProductsEvent extends ProductEvent {}

class GetCategoriesEvent extends ProductEvent {}
