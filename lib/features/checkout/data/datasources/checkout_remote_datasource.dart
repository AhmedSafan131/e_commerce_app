import 'package:e_commerce_app/features/checkout/data/models/address_model.dart';
import 'package:e_commerce_app/features/checkout/data/models/order_model.dart';

abstract class CheckoutRemoteDataSource {
  Future<OrderModel> createOrder(OrderModel order);
  Future<bool> validateAddress(AddressModel address);
  Future<bool> processPayment(double amount, String currency);
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return order;
  }

  @override
  Future<bool> validateAddress(AddressModel address) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    return address.city.isNotEmpty && address.street.isNotEmpty && address.zipCode.isNotEmpty;
  }

  @override
  Future<bool> processPayment(double amount, String currency) async {
    // Simulate Stripe payment
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}
