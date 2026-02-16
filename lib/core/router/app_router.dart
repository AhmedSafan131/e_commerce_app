import 'package:e_commerce_app/features/cart/presentation/pages/cart_page.dart';
import 'package:e_commerce_app/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:e_commerce_app/features/checkout/presentation/pages/checkout_page.dart';
import 'package:e_commerce_app/features/checkout/presentation/pages/payment_webview_page.dart';
import 'package:e_commerce_app/features/products/domain/entities/product_entity.dart';
import 'package:e_commerce_app/injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:e_commerce_app/features/auth/presentation/pages/login_page.dart';
import 'package:e_commerce_app/features/auth/presentation/pages/register_page.dart';
import 'package:e_commerce_app/features/products/presentation/pages/product_list_page.dart';
import 'package:e_commerce_app/features/products/presentation/pages/product_details_page.dart';
import 'package:e_commerce_app/features/orders/presentation/pages/orders_page.dart';
import 'package:e_commerce_app/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:e_commerce_app/features/orders/presentation/bloc/orders_event.dart';

import 'package:e_commerce_app/features/home/presentation/pages/main_page.dart';
import 'package:e_commerce_app/features/checkout/presentation/pages/order_success_page.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainPage(child: child, location: state.uri.toString());
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const ProductListPage()),
        GoRoute(path: '/cart', builder: (context, state) => const CartPage()),
        GoRoute(
          path: '/orders',
          builder: (context, state) =>
              BlocProvider(create: (_) => di.sl<OrdersBloc>()..add(const LoadOrdersEvent()), child: const OrdersPage()),
        ),
      ],
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final product = state.extra as ProductEntity;
        return ProductDetailsPage(product: product);
      },
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => BlocProvider(create: (_) => di.sl<CheckoutBloc>(), child: const CheckoutPage()),
    ),
    GoRoute(
      path: '/payment-webview',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>;
        return PaymentWebViewPage(paymentUrl: extra['paymentUrl']!, orderId: extra['orderId']!);
      },
    ),
    GoRoute(path: '/order-success', builder: (context, state) => const OrderSuccessPage()),
  ],
);
