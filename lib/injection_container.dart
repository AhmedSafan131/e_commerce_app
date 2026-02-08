import 'package:e_commerce_app/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:e_commerce_app/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:e_commerce_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:e_commerce_app/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:e_commerce_app/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:e_commerce_app/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:e_commerce_app/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:e_commerce_app/features/cart/domain/usecases/update_quantity_usecase.dart';
import 'package:e_commerce_app/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:e_commerce_app/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:e_commerce_app/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:e_commerce_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:e_commerce_app/features/checkout/domain/usecases/create_order_usecase.dart';
import 'package:e_commerce_app/features/checkout/domain/usecases/process_payment_usecase.dart';
import 'package:e_commerce_app/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:e_commerce_app/core/services/payment_gateway.dart';
import 'package:e_commerce_app/features/products/data/datasources/product_remote_datasource.dart';
import 'package:e_commerce_app/features/products/data/repositories/product_repository_impl.dart';
import 'package:e_commerce_app/features/products/domain/repositories/product_repository.dart';
import 'package:e_commerce_app/features/products/domain/usecases/get_categories_usecase.dart';
import 'package:e_commerce_app/features/products/domain/usecases/get_product_by_id_usecase.dart';
import 'package:e_commerce_app/features/products/domain/usecases/get_products_usecase.dart';
import 'package:e_commerce_app/features/products/presentation/bloc/categories_cubit.dart';
import 'package:e_commerce_app/features/products/presentation/bloc/product_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_commerce_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:e_commerce_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:e_commerce_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:e_commerce_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:e_commerce_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:e_commerce_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:e_commerce_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:e_commerce_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_commerce_app/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:e_commerce_app/features/orders/domain/repositories/orders_repository.dart';
import 'package:e_commerce_app/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:e_commerce_app/features/orders/domain/usecases/add_order_usecase.dart';
import 'package:e_commerce_app/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:e_commerce_app/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );

  // Features - Products
  // Bloc
  sl.registerFactory(
    () => ProductBloc(getProductsUseCase: sl(), getCategoriesUseCase: sl()),
  );
  sl.registerFactory(() => CategoriesCubit(getCategoriesUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(),
  );

  // Features - Cart
  // Bloc
  sl.registerFactory(
    () => CartBloc(
      getCartUseCase: sl(),
      addToCartUseCase: sl(),
      removeFromCartUseCase: sl(),
      updateQuantityUseCase: sl(),
      clearCartUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCartUseCase(sl()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl()));
  sl.registerLazySingleton(() => UpdateQuantityUseCase(sl()));
  sl.registerLazySingleton(() => ClearCartUseCase(sl()));

  // Repository
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Features - Checkout
  // Bloc
  sl.registerFactory(
    () => CheckoutBloc(
      createOrderUseCase: sl(),
      processPaymentUseCase: sl(),
      addOrderUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateOrderUseCase(sl()));
  sl.registerLazySingleton(() => ProcessPaymentUseCase(sl()));

  // Repository
  sl.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepositoryImpl(remoteDataSource: sl(), paymentGateway: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CheckoutRemoteDataSource>(
    () => CheckoutRemoteDataSourceImpl(),
  );

  // Features - Orders
  // Bloc
  sl.registerFactory(() => OrdersBloc(getOrdersUseCase: sl()));
  // Use cases
  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton(() => AddOrderUseCase(sl()));
  // Repository
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  );

  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton<PaymentGateway>(
    () => PaymobGateway(dio: Dio(), firebaseAuth: sl()),
  );
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
