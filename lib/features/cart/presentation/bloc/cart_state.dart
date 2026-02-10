import 'package:equatable/equatable.dart';
import 'package:e_commerce_app/features/cart/domain/entities/cart_entity.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final CartEntity cart;
  final String? message;

  const CartLoaded({required this.cart, this.message});

  @override
  List<Object?> get props => [cart, message];
}

class CartError extends CartState {
  final String message;

  const CartError({required this.message});

  @override
  List<Object> get props => [message];
}
