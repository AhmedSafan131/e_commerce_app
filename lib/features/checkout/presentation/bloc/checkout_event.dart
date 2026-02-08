import 'package:equatable/equatable.dart';
import 'package:e_commerce_app/features/cart/domain/entities/cart_entity.dart';
import 'package:e_commerce_app/features/checkout/domain/entities/address_entity.dart';
import 'package:e_commerce_app/features/checkout/domain/entities/order_entity.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object> get props => [];
}

class SubmitAddressEvent extends CheckoutEvent {
  final AddressEntity address;

  const SubmitAddressEvent(this.address);

  @override
  List<Object> get props => [address];
}

class ProcessPaymentEvent extends CheckoutEvent {
  final CartEntity cart;

  const ProcessPaymentEvent(this.cart);

  @override
  List<Object> get props => [cart];
}

class ConfirmOrderEvent extends CheckoutEvent {
  final OrderEntity order;

  const ConfirmOrderEvent(this.order);

  @override
  List<Object> get props => [order];
}

class StepChangedEvent extends CheckoutEvent {
  final int step;

  const StepChangedEvent(this.step);

  @override
  List<Object> get props => [step];
}
