import 'package:dartz/dartz.dart';
import 'package:e_commerce_app/core/errors/failures.dart';
import 'package:e_commerce_app/features/cart/data/models/cart_item_model.dart';
import 'package:e_commerce_app/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:e_commerce_app/features/checkout/data/models/address_model.dart';
import 'package:e_commerce_app/features/checkout/data/models/order_model.dart';
import 'package:e_commerce_app/features/checkout/domain/entities/address_entity.dart';
import 'package:e_commerce_app/features/checkout/domain/entities/order_entity.dart';
import 'package:e_commerce_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:e_commerce_app/features/products/data/models/product_model.dart';
import 'package:e_commerce_app/core/services/payment_gateway.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;
  final PaymentGateway? paymentGateway;

  CheckoutRepositoryImpl({required this.remoteDataSource, this.paymentGateway});

  @override
  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order) async {
    try {
      final orderModel = OrderModel(
        id: order.id,
        items: order.items.map((e) {
          final product = e.product;
          final productModel = ProductModel(
            id: product.id,
            name: product.name,
            description: product.description,
            price: product.price,
            imageUrl: product.imageUrl,
            stock: product.stock,
            category: product.category,
          );
          return CartItemModel(product: productModel, quantity: e.quantity);
        }).toList(),
        totalAmount: order.totalAmount,
        shippingAddress: AddressModel(
          city: order.shippingAddress.city,
          street: order.shippingAddress.street,
          zipCode: order.shippingAddress.zipCode,
        ),
        status: order.status,
        date: order.date,
      );
      final result = await remoteDataSource.createOrder(orderModel);
      return Right(result);
    } catch (e) {
      return const Left(ServerFailure('Failed to create order'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateAddress(AddressEntity address) async {
    try {
      final addressModel = AddressModel(
        city: address.city,
        street: address.street,
        zipCode: address.zipCode,
      );
      final result = await remoteDataSource.validateAddress(addressModel);
      if (result) {
        return const Right(true);
      } else {
        return const Left(ServerFailure('Invalid address'));
      }
    } catch (e) {
      return const Left(ServerFailure('Failed to validate address'));
    }
  }

  @override
  Future<Either<Failure, bool>> processPayment(
    double amount,
    String currency,
  ) async {
    try {
      final result = paymentGateway != null
          ? await paymentGateway!.processPayment(
              amount: amount,
              currency: currency,
            )
          : await remoteDataSource.processPayment(amount, currency);
      if (result) {
        return const Right(true);
      } else {
        return const Left(ServerFailure('Payment failed'));
      }
    } catch (e) {
      return const Left(ServerFailure('Payment error'));
    }
  }
}
