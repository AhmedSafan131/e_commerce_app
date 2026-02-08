import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_app/features/checkout/domain/entities/order_entity.dart';
import 'package:e_commerce_app/features/checkout/domain/usecases/create_order_usecase.dart';
import 'package:e_commerce_app/features/checkout/domain/usecases/process_payment_usecase.dart';
import 'package:e_commerce_app/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:e_commerce_app/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:uuid/uuid.dart';
import 'package:e_commerce_app/features/orders/domain/usecases/add_order_usecase.dart';
import 'package:e_commerce_app/core/errors/failures.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CreateOrderUseCase createOrderUseCase;
  final ProcessPaymentUseCase processPaymentUseCase;
  final AddOrderUseCase addOrderUseCase;

  CheckoutBloc({
    required this.createOrderUseCase,
    required this.processPaymentUseCase,
    required this.addOrderUseCase,
  }) : super(const CheckoutState()) {
    on<SubmitAddressEvent>(_onSubmitAddress);
    on<ProcessPaymentEvent>(_onProcessPayment);
    on<StepChangedEvent>(_onStepChanged);
  }

  Future<void> _onSubmitAddress(
    SubmitAddressEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    // Validate address logic here if needed, for now assume valid
    emit(
      state.copyWith(
        status: CheckoutStatus.addressValid,
        shippingAddress: event.address,
        currentStep: 1,
      ),
    );
  }

  Future<void> _onProcessPayment(
    ProcessPaymentEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(status: CheckoutStatus.loading));
    try {
      // Step 1: Process payment and get payment URL
      final paymentResult = await processPaymentUseCase(event.cart.total);
      if (paymentResult.isLeft()) {
        final failure = paymentResult.swap().getOrElse(
          () => const ServerFailure('Payment error'),
        );
        emit(
          state.copyWith(
            status: CheckoutStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return;
      }

      // Step 2: Extract payment URL and order ID
      final paymentData = paymentResult.getOrElse(
        () => throw Exception('Payment result is null'),
      );

      // Step 3: Emit paymentReady state with URL
      // The UI will listen to this and navigate to WebView
      emit(
        state.copyWith(
          status: CheckoutStatus.paymentReady,
          paymentUrl: paymentData.paymentUrl,
          orderId: paymentData.orderId,
        ),
      );

      // Note: Order creation will happen after payment is confirmed
      // This will be triggered from the WebView page after successful payment
    } catch (e) {
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: 'Unexpected error during checkout: ${e.toString()}',
        ),
      );
    }
  }

  void _onStepChanged(StepChangedEvent event, Emitter<CheckoutState> emit) {
    emit(state.copyWith(currentStep: event.step));
  }
}
