import 'package:equatable/equatable.dart';
import 'package:e_commerce_app/features/checkout/domain/entities/address_entity.dart';
import 'package:e_commerce_app/features/checkout/domain/entities/order_entity.dart';

enum CheckoutStatus { initial, loading, addressValid, paymentSuccess, orderCreated, failure }

class CheckoutState extends Equatable {
  final CheckoutStatus status;
  final int currentStep;
  final AddressEntity? shippingAddress;
  final OrderEntity? createdOrder;
  final String? errorMessage;

  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.currentStep = 0,
    this.shippingAddress,
    this.createdOrder,
    this.errorMessage,
  });

  CheckoutState copyWith({
    CheckoutStatus? status,
    int? currentStep,
    AddressEntity? shippingAddress,
    OrderEntity? createdOrder,
    String? errorMessage,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      createdOrder: createdOrder ?? this.createdOrder,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, currentStep, shippingAddress, createdOrder, errorMessage];
}
