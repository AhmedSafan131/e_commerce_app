import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_app/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:e_commerce_app/features/orders/presentation/bloc/orders_event.dart';
import 'package:e_commerce_app/features/orders/presentation/bloc/orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetOrdersUseCase getOrdersUseCase;

  OrdersBloc({required this.getOrdersUseCase}) : super(const OrdersState()) {
    on<LoadOrdersEvent>(_onLoadOrders);
  }

  Future<void> _onLoadOrders(LoadOrdersEvent event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(status: OrdersStatus.loading));
    final result = await getOrdersUseCase(null);
    result.fold(
      (failure) => emit(state.copyWith(status: OrdersStatus.failure, errorMessage: failure.message)),
      (orders) => emit(state.copyWith(status: OrdersStatus.loaded, orders: orders)),
    );
  }
}
