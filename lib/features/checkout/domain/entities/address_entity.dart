import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final String city;
  final String street;
  final String zipCode;

  const AddressEntity({
    required this.city,
    required this.street,
    required this.zipCode,
  });

  @override
  List<Object> get props => [city, street, zipCode];
}
