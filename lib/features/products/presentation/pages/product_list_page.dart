import 'dart:async';
import 'package:e_commerce_app/core/theme/app_theme.dart';
import 'package:e_commerce_app/core/utils/app_logger.dart';
import 'package:e_commerce_app/features/products/presentation/bloc/categories_cubit.dart';
import 'package:e_commerce_app/features/products/presentation/bloc/product_bloc.dart';
import 'package:e_commerce_app/features/products/presentation/bloc/product_event.dart';
import 'package:e_commerce_app/features/products/presentation/bloc/product_state.dart';
import 'package:e_commerce_app/features/products/presentation/widgets/product_grid_item.dart';
import 'package:e_commerce_app/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:e_commerce_app/features/cart/presentation/bloc/cart_event.dart';
import 'package:e_commerce_app/features/cart/presentation/bloc/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String? _selectedCategory;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const GetProductsEvent());
    context.read<CategoriesCubit>().loadCategories();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('electronic')) return Icons.devices;
    if (lower.contains('jewel')) return Icons.diamond;
    if (lower.contains('men') && lower.contains('clothing')) {
      if (lower.contains('women')) return Icons.woman_2;
      return Icons.checkroom;
    }
    if (lower.contains('women')) return Icons.woman_2;
    if (lower.contains('access')) return Icons.watch; // Accessories usually include watches/bands
    if (lower.contains('camera')) return Icons.camera_alt;
    if (lower.contains('headphone')) return Icons.headphones;
    if (lower.contains('laptop') || lower.contains('computer')) return Icons.laptop;
    if (lower.contains('watch')) return Icons.watch;
    if (lower.contains('game') || lower.contains('gaming')) return Icons.videogame_asset;
    if (lower.contains('tv') || lower.contains('television')) return Icons.tv;
    if (lower.contains('audio') || lower.contains('sound')) return Icons.speaker;

    return Icons.category;
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ProductBloc>().add(LoadMoreProductsEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text);
    });
  }

  void _performSearch(String query) {
    AppLogger.info('🔍 [Search] Searching for: "$query"');
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    context.read<ProductBloc>().add(
      GetProductsEvent(category: _selectedCategory, query: query.isEmpty ? null : query, isRefresh: true),
    );
  }

  void _onCategorySelected(String category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = null; // Deselect
      } else {
        _selectedCategory = category;
      }
    });

    // Reset scroll to top
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    // Fetch products
    context.read<ProductBloc>().add(
      GetProductsEvent(
        category: _selectedCategory, // Keep original casing here, BLoC/UseCases should handle it
        query: _searchController.text.isEmpty ? null : _searchController.text,
        isRefresh: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<CartBloc, CartState>(
        listenWhen: (previous, current) =>
            current is CartError || (current is CartLoaded && current.message != null && previous != current),
        listener: (context, state) {
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
            );
          } else if (state is CartLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // 1. Welcome Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Center(
                  child: Text(
                    "Welcome Guest",
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Scrollable Content Body
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 3. Banner
                      Container(
                        width: double.infinity,
                        height: 115,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F3F2),
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1550009158-9ebf69173e03?auto=format&fit=crop&w=800&q=80',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "New Electronics",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Gilroy',
                                    ),
                                  ),
                                  Text(
                                    "Get Up To 40% OFF",
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Gilroy',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 2. Search Bar (Moved here)
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F3F2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search Store',
                            hintStyle: const TextStyle(
                              color: AppColors.greyText,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            prefixIcon: const Icon(Icons.search, color: AppColors.darkText),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.grey),
                                    onPressed: () {
                                      _searchController.clear();
                                      _performSearch('');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 4. Categories Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Categories",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                              fontFamily: 'Gilroy',
                            ),
                          ),
                          Text(
                            "See all",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontFamily: 'Gilroy',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 90,
                        child: BlocBuilder<CategoriesCubit, List<String>>(
                          builder: (context, categories) {
                            if (categories.isEmpty) return const SizedBox();
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              separatorBuilder: (c, i) => const SizedBox(width: 15),
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                final isSelected = category == _selectedCategory;
                                final bgColors = [
                                  const Color(0xFFE6F2EA),
                                  const Color(0xFFFFE9E5),
                                  const Color(0xFFFFF6E3),
                                  const Color(0xFFF3EFFA),
                                ];
                                final bgColor = bgColors[index % bgColors.length];

                                return GestureDetector(
                                  onTap: () => _onCategorySelected(category),
                                  child: Container(
                                    width: 80,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primary.withOpacity(0.2) : bgColor,
                                      borderRadius: BorderRadius.circular(18),
                                      border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(_getCategoryIcon(category), color: AppColors.darkText, size: 30),
                                        const SizedBox(height: 8),
                                        Text(
                                          category,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.darkText,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Gilroy',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 5. Exclusive Offer (Product Grid)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Exclusive Offer",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                              fontFamily: 'Gilroy',
                            ),
                          ),
                          Text(
                            "See all",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontFamily: 'Gilroy',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<ProductBloc, ProductState>(
                        builder: (context, state) {
                          if (state is ProductInitial || (state is ProductLoading && state is! ProductLoaded)) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is ProductError) {
                            return Center(child: Text(state.message));
                          } else if (state is ProductLoaded) {
                            if (state.products.isEmpty) {
                              return const Center(child: Text('No products found'));
                            }
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                              ),
                              itemCount: state.products.length,
                              itemBuilder: (context, index) {
                                final product = state.products[index];
                                return ProductGridItem(
                                  product: product,
                                  onTap: () => context.push('/product/${product.id}', extra: product),
                                  onAddToCart: () {
                                    context.read<CartBloc>().add(AddToCartEvent(product));
                                  },
                                );
                              },
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
