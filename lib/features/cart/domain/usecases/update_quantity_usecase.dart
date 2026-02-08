import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:e_commerce_app/core/errors/failures.dart';
import 'package:e_commerce_app/core/usecases/usecase.dart';
import 'package:e_commerce_app/features/cart/domain/entities/cart_entity.dart';
import 'package:e_commerce_app/features/cart/domain/repositories/cart_repository.dart';

class UpdateQuantityUseCase implements UseCase<CartEntity, UpdateQuantityParams> {
  final CartRepository repository;

  UpdateQuantityUseCase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(UpdateQuantityParams params) async {
    return await repository.updateQuantity(params.productId, params.quantity);
  }
}

class UpdateQuantityParams extends Equatable {
  final String productId;
  final int quantity;

  const UpdateQuantityParams({required this.productId, required this.quantity});

  @override
  List<Object> get props => [productId, quantity];
}
