import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/core/errors/failures.dart';
import 'package:e_commerce_app/core/utils/app_logger.dart';
import 'package:e_commerce_app/features/cart/data/models/cart_item_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemModel>> getCart();
  Future<void> saveCart(List<CartItemModel> items);
  Future<void> addItem(CartItemModel item);
  Future<void> removeItem(String productId);
  Future<void> updateQuantity(String productId, int quantity);
  Future<void> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  CartRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String? get _userId => firebaseAuth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _cartCollection {
    if (_userId == null) {
      throw const ServerFailure('User not authenticated');
    }
    return firestore.collection('users').doc(_userId).collection('cart');
  }

  @override
  Future<List<CartItemModel>> getCart() async {
    if (_userId == null) {
      AppLogger.warning('[Cart] User not authenticated, returning empty cart');
      return [];
    }

    AppLogger.info('[Cart] Fetching cart for user: $_userId');
    final querySnapshot = await _cartCollection.get();

    final items = querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['productId'] = doc.id; // Ensure productId is set
      return CartItemModel.fromJson(data);
    }).toList();

    AppLogger.success('[Cart] Fetched ${items.length} items from Firestore');
    return items;
  }

  @override
  Future<void> saveCart(List<CartItemModel> items) async {
    if (_userId == null) {
      AppLogger.warning('[Cart] User not authenticated, cannot save cart');
      return;
    }

    AppLogger.info('[Cart] Saving ${items.length} items to Firestore');

    // Use batch write for better performance
    final batch = firestore.batch();

    // First, clear existing cart
    final existingDocs = await _cartCollection.get();
    for (final doc in existingDocs.docs) {
      batch.delete(doc.reference);
    }

    // Then add new items
    for (final item in items) {
      final docRef = _cartCollection.doc(item.productId);
      batch.set(docRef, item.toJson());
    }

    await batch.commit();
    AppLogger.success('[Cart] Cart saved successfully');
  }

  @override
  Future<void> addItem(CartItemModel item) async {
    if (_userId == null) {
      AppLogger.warning('[Cart] User not authenticated, cannot add item');
      return;
    }

    AppLogger.info('[Cart] Adding item: ${item.productName}');
    await _cartCollection.doc(item.productId).set(item.toJson());
    AppLogger.success('[Cart] Item added successfully');
  }

  @override
  Future<void> removeItem(String productId) async {
    if (_userId == null) {
      AppLogger.warning('[Cart] User not authenticated, cannot remove item');
      return;
    }

    AppLogger.info('[Cart] Removing item: $productId');
    await _cartCollection.doc(productId).delete();
    AppLogger.success('[Cart] Item removed successfully');
  }

  @override
  Future<void> updateQuantity(String productId, int quantity) async {
    if (_userId == null) {
      AppLogger.warning(
        '[Cart] User not authenticated, cannot update quantity',
      );
      return;
    }

    AppLogger.info('[Cart] Updating quantity for $productId to $quantity');

    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }

    await _cartCollection.doc(productId).update({'quantity': quantity});
    AppLogger.success('[Cart] Quantity updated successfully');
  }

  @override
  Future<void> clearCart() async {
    if (_userId == null) {
      AppLogger.warning('[Cart] User not authenticated, cannot clear cart');
      return;
    }

    AppLogger.info('[Cart] Clearing cart');
    final batch = firestore.batch();
    final docs = await _cartCollection.get();

    for (final doc in docs.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    AppLogger.success('[Cart] Cart cleared successfully');
  }
}
