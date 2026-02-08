import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/core/errors/failures.dart';
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
    try {
      if (_userId == null) {
        print('⚠️  [Cart] User not authenticated, returning empty cart');
        return [];
      }

      print('🔵 [Cart] Fetching cart for user: $_userId');
      final querySnapshot = await _cartCollection.get();

      final items = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['productId'] = doc.id; // Ensure productId is set
        return CartItemModel.fromJson(data);
      }).toList();

      print('✅ [Cart] Fetched ${items.length} items from Firestore');
      return items;
    } catch (e) {
      print('❌ [Cart] Error fetching cart: $e');
      throw ServerFailure('Failed to fetch cart: ${e.toString()}');
    }
  }

  @override
  Future<void> saveCart(List<CartItemModel> items) async {
    try {
      if (_userId == null) {
        print('⚠️  [Cart] User not authenticated, cannot save cart');
        return;
      }

      print('🔵 [Cart] Saving ${items.length} items to Firestore');

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
      print('✅ [Cart] Cart saved successfully');
    } catch (e) {
      print('❌ [Cart] Error saving cart: $e');
      throw ServerFailure('Failed to save cart: ${e.toString()}');
    }
  }

  @override
  Future<void> addItem(CartItemModel item) async {
    try {
      if (_userId == null) {
        print('⚠️  [Cart] User not authenticated, cannot add item');
        return;
      }

      print('🔵 [Cart] Adding item: ${item.productName}');
      await _cartCollection.doc(item.productId).set(item.toJson());
      print('✅ [Cart] Item added successfully');
    } catch (e) {
      print('❌ [Cart] Error adding item: $e');
      throw ServerFailure('Failed to add item: ${e.toString()}');
    }
  }

  @override
  Future<void> removeItem(String productId) async {
    try {
      if (_userId == null) {
        print('⚠️  [Cart] User not authenticated, cannot remove item');
        return;
      }

      print('🔵 [Cart] Removing item: $productId');
      await _cartCollection.doc(productId).delete();
      print('✅ [Cart] Item removed successfully');
    } catch (e) {
      print('❌ [Cart] Error removing item: $e');
      throw ServerFailure('Failed to remove item: ${e.toString()}');
    }
  }

  @override
  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      if (_userId == null) {
        print('⚠️  [Cart] User not authenticated, cannot update quantity');
        return;
      }

      print('🔵 [Cart] Updating quantity for $productId to $quantity');

      if (quantity <= 0) {
        await removeItem(productId);
        return;
      }

      await _cartCollection.doc(productId).update({'quantity': quantity});
      print('✅ [Cart] Quantity updated successfully');
    } catch (e) {
      print('❌ [Cart] Error updating quantity: $e');
      throw ServerFailure('Failed to update quantity: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      if (_userId == null) {
        print('⚠️  [Cart] User not authenticated, cannot clear cart');
        return;
      }

      print('🔵 [Cart] Clearing cart');
      final batch = firestore.batch();
      final docs = await _cartCollection.get();

      for (final doc in docs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ [Cart] Cart cleared successfully');
    } catch (e) {
      print('❌ [Cart] Error clearing cart: $e');
      throw ServerFailure('Failed to clear cart: ${e.toString()}');
    }
  }
}
