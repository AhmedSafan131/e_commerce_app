import 'dart:convert';

import 'package:e_commerce_app/features/cart/data/models/cart_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCart();
  Future<void> saveCart(List<CartItemModel> items);
}

const String CACHED_CART = 'CACHED_CART';

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences sharedPreferences;

  CartLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<CartItemModel>> getCart() async {
    final jsonString = sharedPreferences.getString(CACHED_CART);
    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      // If stored data is corrupted or from an old format, reset cart gracefully.
      await sharedPreferences.remove(CACHED_CART);
      return [];
    }
  }

  @override
  Future<void> saveCart(List<CartItemModel> items) async {
    final jsonString = json.encode(items.map((e) => e.toJson()).toList());
    await sharedPreferences.setString(CACHED_CART, jsonString);
  }
}
