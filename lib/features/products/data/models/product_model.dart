import 'package:e_commerce_app/features/products/domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.stock,
    required super.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawCategory = json['category'];
    final bool isRemoteApiShape =
        json.containsKey('title') || rawCategory is Map<String, dynamic>;

    if (isRemoteApiShape) {
      final images = (json['images'] as List<dynamic>?) ?? [];
      final imageUrl = images.isNotEmpty ? images.first as String : '';
      final categoryName = rawCategory is Map<String, dynamic>
          ? (rawCategory['name'] as String? ?? 'General')
          : 'General';

      return ProductModel(
        id: json['id'].toString(),
        name: (json['title'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
        price: (json['price'] as num).toDouble(),
        imageUrl: imageUrl,

        stock: (json['id'] is int && (json['id'] as int) % 5 == 0) ? 0 : 20,
        category: categoryName,
      );
    } else {
      return ProductModel(
        id: json['id'].toString(),
        name: (json['name'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
        price: (json['price'] as num).toDouble(),
        imageUrl: (json['imageUrl'] as String?) ?? '',
        stock: (json['stock'] as int?) ?? 0,
        category: (json['category'] as String?) ?? 'General',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'stock': stock,
      'category': category,
    };
  }
}
