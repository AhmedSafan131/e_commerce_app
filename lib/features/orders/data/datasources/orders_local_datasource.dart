import 'dart:convert';
import 'package:e_commerce_app/features/checkout/data/models/order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class OrdersLocalDataSource {
  Future<List<OrderModel>> getOrders();
  Future<void> addOrder(OrderModel order);
  Future<void> clearOrders();
}

class OrdersLocalDataSourceImpl implements OrdersLocalDataSource {
  static const _key = 'orders';
  final SharedPreferences sharedPreferences;

  OrdersLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<OrderModel>> getOrders() async {
    final data = sharedPreferences.getString(_key);
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addOrder(OrderModel order) async {
    final existing = await getOrders();
    existing.add(order);
    final encoded = jsonEncode(existing.map((e) => e.toJson()).toList());
    await sharedPreferences.setString(_key, encoded);
  }

  @override
  Future<void> clearOrders() async {
    await sharedPreferences.remove(_key);
  }
}
