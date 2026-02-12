import 'package:e_commerce_app/features/checkout/domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({required super.city, required super.street, required super.zipCode});

  factory AddressModel.fromEntity(AddressEntity entity) {
    if (entity is AddressModel) return entity;
    return AddressModel(city: entity.city, street: entity.street, zipCode: entity.zipCode);
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(city: json['city'], street: json['street'], zipCode: json['zipCode']);
  }

  Map<String, dynamic> toJson() {
    return {'city': city, 'street': street, 'zipCode': zipCode};
  }
}
