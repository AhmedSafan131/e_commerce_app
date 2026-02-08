import 'package:dartz/dartz.dart';
import 'package:e_commerce_app/core/errors/failures.dart';
import 'package:e_commerce_app/core/usecases/usecase.dart';
import 'package:e_commerce_app/features/checkout/domain/entities/order_entity.dart';
import 'package:e_commerce_app/features/orders/domain/repositories/orders_repository.dart';

class AddOrderUseCase implements UseCase<void, OrderEntity> {
  final OrdersRepository repository;

  AddOrderUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(OrderEntity params) async {
    return repository.addOrder(params);
  }
}
