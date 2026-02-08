import 'package:dartz/dartz.dart';
import 'package:e_commerce_app/core/errors/failures.dart';
import 'package:e_commerce_app/core/services/payment_gateway.dart';
import 'package:e_commerce_app/features/checkout/domain/entities/address_entity.dart';
import 'package:e_commerce_app/features/checkout/domain/entities/order_entity.dart';

abstract class CheckoutRepository {
  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order);
  Future<Either<Failure, bool>> validateAddress(AddressEntity address);
  Future<Either<Failure, PaymentResult>> processPayment(
    double amount,
    String currency,
  );
}
