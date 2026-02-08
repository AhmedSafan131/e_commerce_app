import 'package:dartz/dartz.dart';
import 'package:e_commerce_app/core/errors/failures.dart';
import 'package:e_commerce_app/features/products/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? category,
    String? query,
    int page = 1,
    int limit = 10,
  });
  Future<Either<Failure, ProductEntity>> getProductById(String id);
  Future<Either<Failure, List<String>>> getCategories();
}
