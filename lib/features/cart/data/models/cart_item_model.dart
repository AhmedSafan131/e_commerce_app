import 'package:e_commerce_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:e_commerce_app/features/products/data/models/product_model.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required ProductModel super.product,
    required super.quantity,
  });

  // Convenience getters for Firestore operations
  String get productId => product.id;
  String get productName => product.name;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      product: ProductModel.fromEntity(entity.product),
      quantity: entity.quantity,
    );
  }

  CartItemEntity toEntity() {
    return CartItemEntity(product: product, quantity: quantity);
  }

  Map<String, dynamic> toJson() {
    return {
      'product': (product as ProductModel).toJson(),
      'quantity': quantity,
    };
  }
}
