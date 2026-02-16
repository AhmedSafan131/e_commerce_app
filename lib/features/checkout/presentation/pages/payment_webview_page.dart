import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:e_commerce_app/core/utils/app_logger.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String paymentUrl;
  final String orderId;

  const PaymentWebViewPage({super.key, required this.paymentUrl, required this.orderId});

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            AppLogger.info('🔵 [Payment WebView] Page started loading: $url');
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            AppLogger.success('✅ [Payment WebView] Page finished loading: $url');
            setState(() => _isLoading = false);
            _checkPaymentStatus(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            AppLogger.info('🔵 [Payment WebView] Navigation request: ${request.url}');

            // Check if payment is complete
            if (_isPaymentComplete(request.url)) {
              _handlePaymentComplete(request.url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            AppLogger.error('❌ [Payment WebView] Error: ${error.description}');
            _showError('Failed to load payment page');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  bool _isPaymentComplete(String url) {
    // Ignore internal Paymob 3DS callbacks
    if (url.contains('mpgs_secure_callback')) return false;
    if (url.contains('confirmation')) return false; // Ignore confirmation callbacks

    // Check for final result indicators
    // Paymob uses different callback patterns
    return url.contains('success=') ||
        url.contains('payment_complete') ||
        url.contains('txn_response_code') ||
        (url.contains('post_pay') && url.contains('pending=false'));
  }

  void _checkPaymentStatus(String url) {
    if (_isPaymentComplete(url)) {
      _handlePaymentComplete(url);
    }
  }

  void _handlePaymentComplete(String url) {
    AppLogger.success('✅ [Payment WebView] Payment completed: $url');

    // Parse URL to get success status
    final uri = Uri.parse(url);

    // Check various success indicators
    final String? successParam = uri.queryParameters['success'];
    final String? txnResponseCode = uri.queryParameters['txn_response_code'];
    final String? pending = uri.queryParameters['pending'];

    // Determine if payment was successful
    bool isSuccess = false;

    if (successParam == 'true') {
      isSuccess = true;
    } else if (txnResponseCode == 'APPROVED') {
      isSuccess = true;
    } else if (pending == 'false' && url.contains('post_pay')) {
      // Paymob calls post_pay with pending=false on success
      isSuccess = true;
    }

    AppLogger.info('💰 Payment Status: ${isSuccess ? "SUCCESS" : "FAILED"}');

    // Return result to CheckoutPage
    if (mounted) {
      if (isSuccess) {
        context.pop(true);
      } else {
        context.pop(false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment failed or cancelled')));
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Confirm before closing
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cancel Payment?'),
                content: const Text('Are you sure you want to cancel this payment?'),
                actions: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('No')),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      context.pop(false); // Return false
                    },
                    child: const Text('Yes, Cancel'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Loading payment page...')],
              ),
            ),
        ],
      ),
    );
  }
}
