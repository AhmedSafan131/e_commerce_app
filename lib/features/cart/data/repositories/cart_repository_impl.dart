import 'package:dartz/dartz.dart';
import 'package:e_commerce_app/core/errors/failures.dart';
import 'package:e_commerce_app/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:e_commerce_app/features/cart/data/models/cart_item_model.dart';
import 'package:e_commerce_app/features/cart/domain/entities/cart_entity.dart';
import 'package:e_commerce_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:e_commerce_app/features/products/data/models/product_model.dart';
import 'package:e_commerce_app/features/products/domain/entities/product_entity.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      final items = await localDataSource.getCart();
      return Right(CartEntity(items: items));
    } catch (e) {
      return const Left(CacheFailure('Failed to load cart'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> addToCart(ProductEntity product) async {
    try {
      final items = await localDataSource.getCart();
      final index = items.indexWhere((item) => item.product.id == product.id);

      if (index != -1) {
        final existingItem = items[index];
        items[index] = CartItemModel(
          product: existingItem.product as ProductModel,
          quantity: existingItem.quantity + 1,
        );
      } else {
        items.add(CartItemModel(
          product: ProductModel(
            id: product.id,
            name: product.name,
            description: product.description,
            price: product.price,
            imageUrl: product.imageUrl,
            stock: product.stock,
            category: product.category,
          ),
          quantity: 1,
        ));
      }

      await localDataSource.saveCart(items);
      return Right(CartEntity(items: items));
    } catch (e) {
      return const Left(CacheFailure('Failed to add to cart'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> removeFromCart(String productId) async {
    try {
      final items = await localDataSource.getCart();
      items.removeWhere((item) => item.product.id == productId);
      await localDataSource.saveCart(items);
      return Right(CartEntity(items: items));
    } catch (e) {
      return const Left(CacheFailure('Failed to remove from cart'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateQuantity(String productId, int quantity) async {
    try {
      final items = await localDataSource.getCart();
      final index = items.indexWhere((item) => item.product.id == productId);

      if (index != -1) {
        if (quantity <= 0) {
          items.removeAt(index);
        } else {
          final existingItem = items[index];
          items[index] = CartItemModel(
            product: existingItem.product as ProductModel,
            quantity: quantity,
          );
        }
        await localDataSource.saveCart(items);
      }
      return Right(CartEntity(items: items));
    } catch (e) {
      return const Left(CacheFailure('Failed to update quantity'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> clearCart() async {
    try {
      await localDataSource.saveCart([]);
      return const Right(CartEntity(items: []));
    } catch (e) {
      return const Left(CacheFailure('Failed to clear cart'));
    }
  }
}
