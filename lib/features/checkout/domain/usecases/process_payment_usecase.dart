import 'package:dartz/dartz.dart';
import 'package:e_commerce_app/core/errors/failures.dart';
import 'package:e_commerce_app/core/usecases/usecase.dart';
import 'package:e_commerce_app/features/checkout/domain/repositories/checkout_repository.dart';

class ProcessPaymentUseCase implements UseCase<bool, double> {
  final CheckoutRepository repository;

  ProcessPaymentUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(double amount) async {
    return await repository.processPayment(amount, 'EGP');
  }
}
