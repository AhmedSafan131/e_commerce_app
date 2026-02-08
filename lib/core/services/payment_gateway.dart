import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class PaymentGateway {
  Future<bool> processPayment({
    required double amount,
    required String currency,
  });
}

class MockStripeGateway implements PaymentGateway {
  @override
  Future<bool> processPayment({
    required double amount,
    required String currency,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}

class PaymobGateway implements PaymentGateway {
  final Dio dio;
  final FirebaseAuth firebaseAuth;

  // Paymob API Configuration - Direct Integration (No Server)
  static const String paymobBaseUrl = 'https://accept.paymob.com/api';

  // ⚠️ WARNING: In production, these should NEVER be in the app code!
  // For learning/testing purposes only
  static const String apiKey =
      'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRFeU9EYzROaXdpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS45ZXpQbllOM3MtTGd5YjRIaUQxempFemhqLVRmWDZqbUl1Y1pqa3lDSG53RndYN2RtcktUNTV4RHNDbGlEYUZNM1F0cXZGYnZBSzhwSEdFNjJnNnJLZw==';
  static const int cardIntegrationId = 5499482;
  static const String iframeId = '1003704';

  PaymobGateway({
    required this.dio,
    required this.firebaseAuth,
    String? functionsBaseUrl, // Not used in direct integration
  });

  /// Step 1: Authenticate with Paymob and get auth token
  Future<String> _getAuthToken() async {
    print('🔵 [Paymob] Step 1: Getting authentication token...');

    final response = await dio.post(
      '$paymobBaseUrl/auth/tokens',
      data: {'api_key': apiKey},
    );

    final token = response.data['token'] as String;
    print('✅ [Paymob] Auth token received: ${token.substring(0, 20)}...');
    return token;
  }

  /// Step 2: Create order in Paymob
  Future<int> _createOrder({
    required String authToken,
    required int amountCents,
    required String currency,
    required String merchantOrderId,
  }) async {
    print('🔵 [Paymob] Step 2: Creating order...');

    final response = await dio.post(
      '$paymobBaseUrl/ecommerce/orders',
      data: {
        'auth_token': authToken,
        'delivery_needed': false,
        'amount_cents': amountCents,
        'currency': currency,
        'merchant_order_id': merchantOrderId,
        'items': [],
      },
    );

    final orderId = response.data['id'] as int;
    print('✅ [Paymob] Order created with ID: $orderId');
    return orderId;
  }

  /// Step 3: Get payment key
  Future<String> _getPaymentKey({
    required String authToken,
    required int orderId,
    required int amountCents,
    required String currency,
    required Map<String, dynamic> billingData,
  }) async {
    print('🔵 [Paymob] Step 3: Getting payment key...');

    final response = await dio.post(
      '$paymobBaseUrl/acceptance/payment_keys',
      data: {
        'auth_token': authToken,
        'amount_cents': amountCents,
        'currency': currency,
        'order_id': orderId,
        'integration_id': cardIntegrationId,
        'billing_data': billingData,
      },
    );

    final paymentToken = response.data['token'] as String;
    print(
      '✅ [Paymob] Payment key received: ${paymentToken.substring(0, 20)}...',
    );
    return paymentToken;
  }

  @override
  Future<bool> processPayment({
    required double amount,
    required String currency,
  }) async {
    try {
      print('🔵 [Paymob] Starting DIRECT payment process (No Server)...');
      print('🔵 [Paymob] Amount: $amount $currency');

      // Check authentication
      final uid = firebaseAuth.currentUser?.uid;
      if (uid == null) {
        print('❌ [Paymob] Error: User not authenticated');
        throw Exception('Not authenticated. Please login first.');
      }

      print('🔵 [Paymob] User ID: $uid');

      // Prepare data
      final amountCents = (amount * 100).round();
      final merchantOrderId = '$uid-${DateTime.now().millisecondsSinceEpoch}';

      // Get user name, ensuring it's never blank
      final displayName = firebaseAuth.currentUser?.displayName ?? '';
      final nameParts = displayName.trim().split(' ');
      final firstName = nameParts.isNotEmpty && nameParts.first.isNotEmpty
          ? nameParts.first
          : 'User';
      final lastName = nameParts.length > 1 && nameParts.last.isNotEmpty
          ? nameParts.last
          : 'Name';

      final billingData = {
        'apartment': 'NA',
        'email': firebaseAuth.currentUser?.email ?? 'user@example.com',
        'floor': 'NA',
        'first_name': firstName,
        'last_name': lastName,
        'street': 'NA',
        'building': 'NA',
        'phone_number': 'NA',
        'shipping_method': 'NA',
        'postal_code': 'NA',
        'city': 'NA',
        'country': 'EG',
        'state': 'NA',
      };

      // Step 1: Get auth token
      final authToken = await _getAuthToken();

      // Step 2: Create order
      final paymobOrderId = await _createOrder(
        authToken: authToken,
        amountCents: amountCents,
        currency: currency,
        merchantOrderId: merchantOrderId,
      );

      // Step 3: Get payment key
      final paymentToken = await _getPaymentKey(
        authToken: authToken,
        orderId: paymobOrderId,
        amountCents: amountCents,
        currency: currency,
        billingData: billingData,
      );

      // Step 4: Generate payment URL
      final paymentUrl =
          '$paymobBaseUrl/acceptance/iframes/$iframeId?payment_token=$paymentToken';
      print('✅ [Paymob] Payment URL generated: $paymentUrl');

      // Step 5: Open payment page in browser
      final uri = Uri.parse(paymentUrl);
      final canLaunch = await canLaunchUrl(uri);

      if (!canLaunch) {
        print('❌ [Paymob] Error: Cannot launch URL');
        throw Exception(
          'Cannot open payment page. Please check your browser settings.',
        );
      }

      print('🔵 [Paymob] Launching payment URL in browser...');
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      print('✅ [Paymob] Payment process completed successfully!');
      print('ℹ️  [Paymob] User will complete payment in browser');

      return true;
    } catch (e) {
      print('❌ [Paymob] Payment error: $e');

      if (e is DioException) {
        if (e.response != null) {
          print('❌ [Paymob] API Error: ${e.response?.data}');
          throw Exception('Payment API error: ${e.response?.data}');
        } else {
          print('❌ [Paymob] Network error: ${e.message}');
          throw Exception(
            'Network error. Please check your internet connection.',
          );
        }
      }

      rethrow;
    }
  }
}
