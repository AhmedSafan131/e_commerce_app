import 'package:dartz/dartz.dart';
import 'package:e_commerce_app/core/errors/failures.dart';
import 'package:e_commerce_app/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:e_commerce_app/features/cart/data/models/cart_item_model.dart';
import 'package:e_commerce_app/features/cart/domain/entities/cart_entity.dart';
import 'package:e_commerce_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:e_commerce_app/features/products/data/models/product_model.dart';
import 'package:e_commerce_app/features/products/domain/entities/product_entity.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      final items = await remoteDataSource.getCart();
      return Right(CartEntity(items: items));
    } catch (e) {
      return Left(ServerFailure('Failed to load cart: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> addToCart(ProductEntity product) async {
    try {
      final items = await remoteDataSource.getCart();
      final index = items.indexWhere((item) => item.product.id == product.id);

      if (index != -1) {
        final existingItem = items[index];
        final newQuantity = existingItem.quantity + 1;
        await remoteDataSource.updateQuantity(product.id, newQuantity);

        items[index] = CartItemModel(
          product: ProductModel.fromEntity(existingItem.product),
          quantity: newQuantity,
        );
      } else {
        final newItem = CartItemModel(
          product: ProductModel.fromEntity(product),
          quantity: 1,
        );
        await remoteDataSource.addItem(newItem);
        items.add(newItem);
      }

      return Right(CartEntity(items: items));
    } catch (e) {
      return Left(ServerFailure('Failed to add to cart: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> removeFromCart(String productId) async {
    try {
      await remoteDataSource.removeItem(productId);
      final items = await remoteDataSource.getCart();
      return Right(CartEntity(items: items));
    } catch (e) {
      return Left(ServerFailure('Failed to remove from cart: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateQuantity(
    String productId,
    int quantity,
  ) async {
    try {
      await remoteDataSource.updateQuantity(productId, quantity);
      final items = await remoteDataSource.getCart();
      return Right(CartEntity(items: items));
    } catch (e) {
      return Left(ServerFailure('Failed to update quantity: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> clearCart() async {
    try {
      await remoteDataSource.clearCart();
      return const Right(CartEntity(items: []));
    } catch (e) {
      return Left(ServerFailure('Failed to clear cart: ${e.toString()}'));
    }
  }
}
