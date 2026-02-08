import 'package:dartz/dartz.dart';
import 'package:e_commerce_app/core/errors/failures.dart';
import 'package:e_commerce_app/core/usecases/usecase.dart';
import 'package:e_commerce_app/features/checkout/domain/entities/order_entity.dart';
import 'package:e_commerce_app/features/checkout/domain/repositories/checkout_repository.dart';

class CreateOrderUseCase implements UseCase<OrderEntity, OrderEntity> {
  final CheckoutRepository repository;

  CreateOrderUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(OrderEntity params) async {
    return await repository.createOrder(params);
  }
}
