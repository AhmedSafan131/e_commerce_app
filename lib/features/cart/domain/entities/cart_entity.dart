import 'package:equatable/equatable.dart';
import 'package:e_commerce_app/features/cart/domain/entities/cart_item_entity.dart';

class CartEntity extends Equatable {
  final List<CartItemEntity> items;

  const CartEntity({required this.items});

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);

  @override
  List<Object> get props => [items];
}
