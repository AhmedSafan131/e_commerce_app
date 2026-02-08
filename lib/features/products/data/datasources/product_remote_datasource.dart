import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<void> seedProducts(); // For initial data setup
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore firestore;

  ProductRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ProductModel>> getProducts({
    String? category,
    String? query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      Query<Map<String, dynamic>> productsQuery = firestore.collection(
        'products',
      );

      // Filter by category if provided
      if (category != null && category.isNotEmpty) {
        productsQuery = productsQuery.where('category', isEqualTo: category);
      }

      // Server-side search by name (case-insensitive requires array-contains)
      // For better search, we'll use startAt/endAt for prefix search
      if (query != null && query.isNotEmpty) {
        final String searchEnd = query.toLowerCase() + '\uf8ff';
        productsQuery = productsQuery
            .where('nameLower', isGreaterThanOrEqualTo: query.toLowerCase())
            .where('nameLower', isLessThanOrEqualTo: searchEnd);
      }

      // Order by name for consistent pagination
      productsQuery = productsQuery.orderBy('nameLower');

      // Pagination
      final int startIndex = (page - 1) * limit;
      if (startIndex > 0) {
        // Skip to the correct page (Firestore doesn't have skip, so we fetch and skip)
        productsQuery = productsQuery.limit(startIndex + limit);
      } else {
        productsQuery = productsQuery.limit(limit);
      }

      final querySnapshot = await productsQuery.get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      // If we had to fetch extra docs for pagination, skip them
      final docs = startIndex > 0
          ? querySnapshot.docs.skip(startIndex).toList()
          : querySnapshot.docs;

      return docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Ensure ID is included
        return ProductModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('❌ [Products] Error fetching products: $e');
      throw ServerFailure('Unable to fetch products: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final docSnapshot = await firestore.collection('products').doc(id).get();

      if (!docSnapshot.exists) {
        throw const ServerFailure('Product not found');
      }

      final data = docSnapshot.data()!;
      data['id'] = docSnapshot.id;
      return ProductModel.fromJson(data);
    } catch (e) {
      print('❌ [Products] Error fetching product by ID: $e');
      throw ServerFailure('Product not found: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final querySnapshot = await firestore.collection('products').get();

      final categories = querySnapshot.docs
          .map((doc) => doc.data()['category'] as String?)
          .where((category) => category != null && category.isNotEmpty)
          .cast<String>() // Cast to non-nullable String
          .toSet()
          .toList();

      categories.sort();
      return categories;
    } catch (e) {
      print('❌ [Products] Error fetching categories: $e');
      throw ServerFailure('Unable to fetch categories: ${e.toString()}');
    }
  }

  @override
  Future<void> seedProducts() async {
    try {
      // Check if products already exist
      final existingProducts = await firestore
          .collection('products')
          .limit(1)
          .get();
      if (existingProducts.docs.isNotEmpty) {
        print('ℹ️  [Products] Products already seeded, skipping...');
        return;
      }

      print('🌱 [Products] Seeding products to Firestore...');

      final List<Map<String, dynamic>> mockProducts = [
        {
          'id': 'e1',
          'name': 'Wireless Noise-Cancelling Headphones',
          'nameLower': 'wireless noise-cancelling headphones',
          'description':
              'Premium over-ear headphones with active noise cancellation and 30 hours of battery life.',
          'price': 199.99,
          'imageUrl':
              'https://images.pexels.com/photos/3945666/pexels-photo-3945666.jpeg',
          'stock': 12,
          'category': 'Headphones',
        },
        {
          'id': 'e2',
          'name': 'Smartwatch Series X',
          'nameLower': 'smartwatch series x',
          'description':
              'Modern smartwatch with heart-rate monitoring, GPS, and AMOLED display.',
          'price': 249.00,
          'imageUrl':
              'https://images.pexels.com/photos/2773942/pexels-photo-2773942.jpeg',
          'stock': 8,
          'category': 'Wearables',
        },
        {
          'id': 'e3',
          'name': 'Bluetooth Speaker',
          'nameLower': 'bluetooth speaker',
          'description':
              'Portable Bluetooth speaker with rich bass and 12-hour playtime.',
          'price': 89.50,
          'imageUrl':
              'https://images.pexels.com/photos/374870/pexels-photo-374870.jpeg',
          'stock': 20,
          'category': 'Speakers',
        },
        {
          'id': 'e4',
          'name': 'Mirrorless Camera Pro',
          'nameLower': 'mirrorless camera pro',
          'description':
              '24MP mirrorless camera with 4K video recording and interchangeable lenses.',
          'price': 999.00,
          'imageUrl':
              'https://images.pexels.com/photos/65540/pexels-photo-65540.jpeg',
          'stock': 5,
          'category': 'Cameras',
        },
        {
          'id': 'e5',
          'name': 'Ultrabook 14"',
          'nameLower': 'ultrabook 14"',
          'description':
              'Slim and light 14-inch ultrabook with 16GB RAM and 512GB SSD.',
          'price': 1299.00,
          'imageUrl': 'https://images.pexels.com/photos/18104/pexels-photo.jpg',
          'stock': 7,
          'category': 'Laptops',
        },
        {
          'id': 'e6',
          'name': 'Wireless Earbuds',
          'nameLower': 'wireless earbuds',
          'description':
              'Compact true wireless earbuds with wireless charging case.',
          'price': 149.99,
          'imageUrl':
              'https://images.pexels.com/photos/1649771/pexels-photo-1649771.jpeg',
          'stock': 18,
          'category': 'Headphones',
        },
        {
          'id': 'e7',
          'name': 'Gaming Mouse RGB',
          'nameLower': 'gaming mouse rgb',
          'description':
              'Ergonomic gaming mouse with customizable RGB lighting and 8 programmable buttons.',
          'price': 59.99,
          'imageUrl':
              'https://images.pexels.com/photos/3945683/pexels-photo-3945683.jpeg',
          'stock': 25,
          'category': 'Accessories',
        },
        {
          'id': 'e8',
          'name': 'Mechanical Keyboard',
          'nameLower': 'mechanical keyboard',
          'description':
              'Compact mechanical keyboard with hot-swappable switches and white backlight.',
          'price': 119.00,
          'imageUrl':
              'https://images.pexels.com/photos/2115257/pexels-photo-2115257.jpeg',
          'stock': 14,
          'category': 'Accessories',
        },
        {
          'id': 'e9',
          'name': '4K Ultra HD Monitor',
          'nameLower': '4k ultra hd monitor',
          'description':
              '27-inch 4K UHD monitor with thin bezels and adjustable stand, ideal for design and gaming.',
          'price': 349.00,
          'imageUrl':
              'https://images.pexels.com/photos/572056/pexels-photo-572056.jpeg',
          'stock': 9,
          'category': 'Monitors',
        },
        {
          'id': 'e10',
          'name': 'Noise Cancelling Earphones',
          'nameLower': 'noise cancelling earphones',
          'description':
              'In-ear earphones with active noise cancelling and in-line microphone.',
          'price': 79.99,
          'imageUrl':
              'https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg',
          'stock': 30,
          'category': 'Headphones',
        },
      ];

      final batch = firestore.batch();
      for (final product in mockProducts) {
        final docRef = firestore
            .collection('products')
            .doc(product['id'] as String);
        batch.set(docRef, product);
      }

      await batch.commit();
      print(
        '✅ [Products] Successfully seeded ${mockProducts.length} products!',
      );
    } catch (e) {
      print('❌ [Products] Error seeding products: $e');
      throw ServerFailure('Failed to seed products: ${e.toString()}');
    }
  }
}
