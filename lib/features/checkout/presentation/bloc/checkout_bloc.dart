import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_app/features/checkout/domain/entities/order_entity.dart';
import 'package:e_commerce_app/features/checkout/domain/usecases/create_order_usecase.dart';
import 'package:e_commerce_app/features/checkout/domain/usecases/process_payment_usecase.dart';
import 'package:e_commerce_app/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:e_commerce_app/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:e_commerce_app/features/orders/domain/usecases/add_order_usecase.dart';
import 'package:e_commerce_app/core/errors/failures.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CreateOrderUseCase createOrderUseCase;
  final ProcessPaymentUseCase processPaymentUseCase;
  final AddOrderUseCase addOrderUseCase;

  CheckoutBloc({required this.createOrderUseCase, required this.processPaymentUseCase, required this.addOrderUseCase})
    : super(const CheckoutState()) {
    on<SubmitAddressEvent>(_onSubmitAddress);
    on<ProcessPaymentEvent>(_onProcessPayment);
    on<StepChangedEvent>(_onStepChanged);
    on<PaymentSuccessEvent>(_onPaymentSuccess);
  }

  Future<void> _onSubmitAddress(SubmitAddressEvent event, Emitter<CheckoutState> emit) async {
    emit(state.copyWith(status: CheckoutStatus.addressValid, shippingAddress: event.address, currentStep: 1));
  }

  Future<void> _onProcessPayment(ProcessPaymentEvent event, Emitter<CheckoutState> emit) async {
    emit(state.copyWith(status: CheckoutStatus.loading, cart: event.cart));

    final paymentResult = await processPaymentUseCase(event.cart.total);

    paymentResult.fold(
      (failure) {
        emit(state.copyWith(status: CheckoutStatus.failure, errorMessage: failure.message));
      },
      (paymentData) {
        emit(
          state.copyWith(
            status: CheckoutStatus.paymentReady,
            paymentUrl: paymentData.paymentUrl,
            orderId: paymentData.orderId,
          ),
        );
      },
    );
  }

  Future<void> _onPaymentSuccess(PaymentSuccessEvent event, Emitter<CheckoutState> emit) async {
    if (state.cart == null || state.shippingAddress == null) {
      emit(state.copyWith(status: CheckoutStatus.failure, errorMessage: 'Missing cart or address information'));
      return;
    }

    emit(state.copyWith(status: CheckoutStatus.loading));

    final order = OrderEntity(
      id: event.orderId, // Use the payment/order ID from Paymob
      items: state.cart!.items,
      totalAmount: state.cart!.total,
      shippingAddress: state.shippingAddress!,
      status: 'Paid',
      date: DateTime.now(),
    );

    final result = await addOrderUseCase(order);

    result.fold(
      (failure) => emit(state.copyWith(status: CheckoutStatus.failure, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: CheckoutStatus.orderCreated, createdOrder: order)),
    );
  }

  void _onStepChanged(StepChangedEvent event, Emitter<CheckoutState> emit) {
    emit(state.copyWith(currentStep: event.step));
  }
}
