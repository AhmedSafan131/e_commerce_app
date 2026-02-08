import 'package:equatable/equatable.dart';
import 'package:e_commerce_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:e_commerce_app/features/checkout/domain/entities/address_entity.dart';

class OrderEntity extends Equatable {
  final String id;
  final List<CartItemEntity> items;
  final double totalAmount;
  final AddressEntity shippingAddress;
  final String status;
  final DateTime date;

  const OrderEntity({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    required this.status,
    required this.date,
  });

  @override
  List<Object> get props => [id, items, totalAmount, shippingAddress, status, date];
}
