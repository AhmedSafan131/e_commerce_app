import 'package:e_commerce_app/features/cart/data/models/cart_item_model.dart';
import 'package:e_commerce_app/features/checkout/data/models/address_model.dart';
import 'package:e_commerce_app/features/checkout/domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      items: entity.items.map((e) => CartItemModel.fromEntity(e)).toList(),
      totalAmount: entity.totalAmount,
      shippingAddress: AddressModel.fromEntity(entity.shippingAddress),
      status: entity.status,
      date: entity.date,
    );
  }

  const OrderModel({
    required super.id,
    required super.items,
    required super.totalAmount,
    required super.shippingAddress,
    required super.status,
    required super.date,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>).map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      shippingAddress: AddressModel.fromJson(json['shippingAddress'] as Map<String, dynamic>),
      status: json['status'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((e) => (e as CartItemModel).toJson()).toList(),
      'totalAmount': totalAmount,
      'shippingAddress': (shippingAddress as AddressModel).toJson(),
      'status': status,
      'date': date.toIso8601String(),
    };
  }
}
