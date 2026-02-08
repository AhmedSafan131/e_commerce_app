import 'package:equatable/equatable.dart';
import 'package:e_commerce_app/features/checkout/domain/entities/address_entity.dart';
import 'package:e_commerce_app/features/checkout/domain/entities/order_entity.dart';

enum CheckoutStatus {
  initial,
  loading,
  addressValid,
  paymentReady, // New: Payment URL is ready for WebView
  paymentSuccess,
  orderCreated,
  failure,
}

class CheckoutState extends Equatable {
  final CheckoutStatus status;
  final int currentStep;
  final AddressEntity? shippingAddress;
  final OrderEntity? createdOrder;
  final String? errorMessage;
  final String? paymentUrl; // New: Payment URL for WebView
  final String? orderId; // New: Order ID from payment gateway

  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.currentStep = 0,
    this.shippingAddress,
    this.createdOrder,
    this.errorMessage,
    this.paymentUrl,
    this.orderId,
  });

  CheckoutState copyWith({
    CheckoutStatus? status,
    int? currentStep,
    AddressEntity? shippingAddress,
    OrderEntity? createdOrder,
    String? errorMessage,
    String? paymentUrl,
    String? orderId,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      createdOrder: createdOrder ?? this.createdOrder,
      errorMessage: errorMessage ?? this.errorMessage,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      orderId: orderId ?? this.orderId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentStep,
    shippingAddress,
    createdOrder,
    errorMessage,
    paymentUrl,
    orderId,
  ];
}
