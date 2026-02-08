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

      final success = paymentResult.getOrElse(() => false);
      if (!success) {
        emit(
          state.copyWith(
            status: CheckoutStatus.failure,
            errorMessage: 'Payment failed',
          ),
        );
        return;
      }

      if (state.shippingAddress == null) {
        emit(
          state.copyWith(
            status: CheckoutStatus.failure,
            errorMessage:
                'Shipping address missing. Please go back and fill it.',
          ),
        );
        return;
      }

      final order = OrderEntity(
        id: const Uuid().v4(),
        items: event.cart.items,
        totalAmount: event.cart.total,
        shippingAddress: state.shippingAddress!,
        status: 'Pending',
        date: DateTime.now(),
      );

      final orderResult = await createOrderUseCase(order);
      if (orderResult.isLeft()) {
        final failure = orderResult.swap().getOrElse(
          () => const ServerFailure('Failed to create order'),
        );
        emit(
          state.copyWith(
            status: CheckoutStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return;
      }

      final createdOrder = orderResult.getOrElse(() => order);
      final addResult = await addOrderUseCase(createdOrder);
      if (addResult.isLeft()) {
        final failure = addResult.swap().getOrElse(
          () => const ServerFailure('Failed to save order'),
        );
        emit(
          state.copyWith(
            status: CheckoutStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: CheckoutStatus.orderCreated,
          createdOrder: createdOrder,
          currentStep: 2,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: 'Unexpected error during checkout',
        ),
      );
    }
  }

  void _onStepChanged(StepChangedEvent event, Emitter<CheckoutState> emit) {
    emit(state.copyWith(currentStep: event.step));
  }
}
