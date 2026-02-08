import 'package:e_commerce_app/core/errors/failures.dart';
import 'package:e_commerce_app/features/products/data/models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    String? category,
    String? query,
    int page = 1,
    int limit = 10,
  });
  Future<ProductModel> getProductById(String id);
  Future<List<String>> getCategories();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  // Local mock electronics products with clean studio-style images.
  final List<ProductModel> _mockProducts = const [
    ProductModel(
      id: 'e1',
      name: 'Wireless Noise-Cancelling Headphones',
      description:
          'Premium over-ear headphones with active noise cancellation and 30 hours of battery life.',
      price: 199.99,
      imageUrl:
          'https://images.pexels.com/photos/3945666/pexels-photo-3945666.jpeg',
      stock: 12,
      category: 'Headphones',
    ),
    ProductModel(
      id: 'e2',
      name: 'Smartwatch Series X',
      description:
          'Modern smartwatch with heart-rate monitoring, GPS, and AMOLED display.',
      price: 249.00,
      imageUrl:
          'https://images.pexels.com/photos/2773942/pexels-photo-2773942.jpeg',
      stock: 8,
      category: 'Wearables',
    ),
    ProductModel(
      id: 'e3',
      name: 'Bluetooth Speaker',
      description:
          'Portable Bluetooth speaker with rich bass and 12-hour playtime.',
      price: 89.50,
      imageUrl:
          'https://images.pexels.com/photos/374870/pexels-photo-374870.jpeg',
      stock: 20,
      category: 'Speakers',
    ),
    ProductModel(
      id: 'e4',
      name: 'Mirrorless Camera Pro',
      description:
          '24MP mirrorless camera with 4K video recording and interchangeable lenses.',
      price: 999.00,
      imageUrl:
          'https://images.pexels.com/photos/65540/pexels-photo-65540.jpeg',
      stock: 5,
      category: 'Cameras',
    ),
    ProductModel(
      id: 'e5',
      name: 'Ultrabook 14"',
      description:
          'Slim and light 14-inch ultrabook with 16GB RAM and 512GB SSD.',
      price: 1299.00,
      imageUrl: 'https://images.pexels.com/photos/18104/pexels-photo.jpg',
      stock: 7,
      category: 'Laptops',
    ),
    ProductModel(
      id: 'e6',
      name: 'Wireless Earbuds',
      description: 'Compact true wireless earbuds with wireless charging case.',
      price: 149.99,
      imageUrl:
          'https://images.pexels.com/photos/1649771/pexels-photo-1649771.jpeg',
      stock: 18,
      category: 'Headphones',
    ),
    ProductModel(
      id: 'e7',
      name: 'Gaming Mouse RGB',
      description:
          'Ergonomic gaming mouse with customizable RGB lighting and 8 programmable buttons.',
      price: 59.99,
      imageUrl:
          'https://images.pexels.com/photos/3945683/pexels-photo-3945683.jpeg',
      stock: 25,
      category: 'Accessories',
    ),
    ProductModel(
      id: 'e8',
      name: 'Mechanical Keyboard',
      description:
          'Compact mechanical keyboard with hot-swappable switches and white backlight.',
      price: 119.00,
      imageUrl:
          'https://images.pexels.com/photos/2115257/pexels-photo-2115257.jpeg',
      stock: 14,
      category: 'Accessories',
    ),
    ProductModel(
      id: 'e9',
      name: '4K Ultra HD Monitor',
      description:
          '27-inch 4K UHD monitor with thin bezels and adjustable stand, ideal for design and gaming.',
      price: 349.00,
      imageUrl:
          'https://images.pexels.com/photos/572056/pexels-photo-572056.jpeg',
      stock: 9,
      category: 'Monitors',
    ),
    ProductModel(
      id: 'e10',
      name: 'Noise Cancelling Earphones',
      description:
          'In-ear earphones with active noise cancelling and in-line microphone.',
      price: 79.99,
      imageUrl:
          'https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg',
      stock: 30,
      category: 'Headphones',
    ),
  ];

  @override
  Future<List<ProductModel>> getProducts({
    String? category,
    String? query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      var filtered = _mockProducts;

      if (category != null && category.isNotEmpty) {
        filtered = filtered
            .where((p) => p.category.toLowerCase() == category.toLowerCase())
            .toList();
      }

      if (query != null && query.isNotEmpty) {
        filtered = filtered
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }

      final startIndex = (page - 1) * limit;
      if (startIndex >= filtered.length) {
        return [];
      }
      final endIndex = startIndex + limit;
      return filtered.sublist(
        startIndex,
        endIndex > filtered.length ? filtered.length : endIndex,
      );
    } catch (_) {
      throw const ServerFailure('Unable to fetch products');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      return _mockProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      throw const ServerFailure('Product not found');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    final categories = _mockProducts.map((p) => p.category).toSet().toList();
    categories.sort();
    return categories;
  }
}
