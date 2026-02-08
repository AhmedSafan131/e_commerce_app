import 'package:dartz/dartz.dart';
import 'package:e_commerce_app/core/errors/failures.dart';
import 'package:e_commerce_app/features/checkout/data/models/order_model.dart';
import 'package:e_commerce_app/features/checkout/data/models/address_model.dart';
import 'package:e_commerce_app/features/cart/data/models/cart_item_model.dart';
import 'package:e_commerce_app/features/products/data/models/product_model.dart';
import 'package:e_commerce_app/features/checkout/domain/entities/order_entity.dart';
import 'package:e_commerce_app/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:e_commerce_app/features/orders/domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders() async {
    try {
      final orders = await remoteDataSource.getOrders();
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addOrder(OrderEntity order) async {
    try {
      final model = OrderModel(
        id: order.id,
        items: order.items
            .map(
              (e) => CartItemModel(
                product: ProductModel(
                  id: e.product.id,
                  name: e.product.name,
                  description: e.product.description,
                  price: e.product.price,
                  imageUrl: e.product.imageUrl,
                  stock: e.product.stock,
                  category: e.product.category,
                ),
                quantity: e.quantity,
              ),
            )
            .toList(),
        totalAmount: order.totalAmount,
        shippingAddress: AddressModel(
          city: order.shippingAddress.city,
          street: order.shippingAddress.street,
          zipCode: order.shippingAddress.zipCode,
        ),
        status: order.status,
        date: order.date,
      );
      await remoteDataSource.addOrder(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearOrders() async {
    try {
      await remoteDataSource.clearOrders();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
