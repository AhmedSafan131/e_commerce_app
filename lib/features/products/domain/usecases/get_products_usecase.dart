import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:e_commerce_app/core/errors/failures.dart';
import 'package:e_commerce_app/core/usecases/usecase.dart';
import 'package:e_commerce_app/features/products/domain/entities/product_entity.dart';
import 'package:e_commerce_app/features/products/domain/repositories/product_repository.dart';

class GetProductsUseCase implements UseCase<List<ProductEntity>, GetProductsParams> {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(GetProductsParams params) async {
    return await repository.getProducts(
      category: params.category,
      query: params.query,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetProductsParams extends Equatable {
  final String? category;
  final String? query;
  final int page;
  final int limit;

  const GetProductsParams({
    this.category,
    this.query,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [category, query, page, limit];
}
