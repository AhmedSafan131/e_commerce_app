import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/features/checkout/data/models/order_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderModel>> getOrders();
  Future<void> addOrder(OrderModel order);
  Future<void> clearOrders();
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  OrdersRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  CollectionReference<Map<String, dynamic>> _ordersCollection(String uid) {
    return firestore.collection('users').doc(uid).collection('orders');
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Not authenticated');
    }
    final snapshot =
        await _ordersCollection(uid).orderBy('date', descending: true).get();
    return snapshot.docs
        .map((doc) => OrderModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> addOrder(OrderModel order) async {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Not authenticated');
    }
    await _ordersCollection(uid).doc(order.id).set(order.toJson());
  }

  @override
  Future<void> clearOrders() async {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Not authenticated');
    }
    final col = _ordersCollection(uid);
    final snapshot = await col.get();
    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
