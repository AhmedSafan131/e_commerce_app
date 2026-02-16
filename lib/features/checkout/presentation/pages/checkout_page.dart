import 'package:e_commerce_app/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:e_commerce_app/features/cart/presentation/bloc/cart_event.dart';
import 'package:e_commerce_app/features/cart/presentation/bloc/cart_state.dart';
import 'package:e_commerce_app/features/checkout/domain/entities/address_entity.dart';
import 'package:e_commerce_app/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:e_commerce_app/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:e_commerce_app/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:e_commerce_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _zipCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Make sure we have the latest cart when entering checkout.
    context.read<CartBloc>().add(LoadCartEvent());
  }

  @override
  void dispose() {
    _cityController.dispose();
    _streetController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.bold, fontFamily: 'Gilroy'),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<CheckoutBloc, CheckoutState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) async {
          // Navigate to WebView when payment URL is ready
          if (state.status == CheckoutStatus.paymentReady) {
            if (state.paymentUrl != null && state.orderId != null) {
              final orderId = state.orderId!;
              final result = await context.push<bool>(
                '/payment-webview',
                extra: {'paymentUrl': state.paymentUrl!, 'orderId': orderId},
              );

              if (result == true && context.mounted) {
                // Show success popup dialog
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.primary, size: 80),
                        const SizedBox(height: 16),
                        const Text(
                          'Payment Success!',
                          style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your payment has been processed successfully',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Gilroy', fontSize: 14, color: AppColors.greyText),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                fontFamily: 'Gilroy',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                if (context.mounted) {
                  context.read<CheckoutBloc>().add(PaymentSuccessEvent(orderId));
                }
              }
            }
          } else if (state.status == CheckoutStatus.orderCreated) {
            context.read<CartBloc>().add(ClearCartEvent());
            await Future.delayed(const Duration(milliseconds: 300));
            if (context.mounted) {
              context.go('/order-success');
            }
          } else if (state.status == CheckoutStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'Error occurred')));
          }
        },
        builder: (context, state) {
          return Stepper(
            currentStep: state.currentStep,
            controlsBuilder: (context, details) {
              return Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      textStyle: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w600),
                    ),
                    child: const Text('CONTINUE'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: details.onStepCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.darkText,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      textStyle: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w600),
                    ),
                    child: const Text('BACK'),
                  ),
                ],
              );
            },
            onStepContinue: () {
              if (state.currentStep == 0) {
                if (_formKey.currentState!.validate()) {
                  context.read<CheckoutBloc>().add(
                    SubmitAddressEvent(
                      AddressEntity(
                        city: _cityController.text,
                        street: _streetController.text,
                        zipCode: _zipCodeController.text,
                      ),
                    ),
                  );
                }
              } else if (state.currentStep == 1) {
                final cartState = context.read<CartBloc>().state;
                if (cartState is CartLoaded) {
                  if (cartState.cart.items.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
                    return;
                  }
                  context.read<CheckoutBloc>().add(ProcessPaymentEvent(cartState.cart));
                } else if (cartState is CartLoading || cartState is CartInitial) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loading cart...')));
                } else if (cartState is CartError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(cartState.message)));
                }
              }
            },
            onStepCancel: () {
              if (state.currentStep > 0) {
                context.read<CheckoutBloc>().add(StepChangedEvent(state.currentStep - 1));
              } else {
                context.pop();
              }
            },
            steps: [
              Step(
                title: const Text('Address'),
                content: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(labelText: 'City'),
                        validator: (value) => value?.isEmpty ?? true ? 'Please enter city' : null,
                      ),
                      TextFormField(
                        controller: _streetController,
                        decoration: const InputDecoration(labelText: 'Street'),
                        validator: (value) => value?.isEmpty ?? true ? 'Please enter street' : null,
                      ),
                      TextFormField(
                        controller: _zipCodeController,
                        decoration: const InputDecoration(labelText: 'Zip Code'),
                        validator: (value) => value?.isEmpty ?? true ? 'Please enter zip code' : null,
                      ),
                    ],
                  ),
                ),
                isActive: state.currentStep >= 0,
                state: state.currentStep > 0 ? StepState.complete : StepState.editing,
              ),
              Step(
                title: const Text('Payment'),
                content: BlocBuilder<CartBloc, CartState>(
                  builder: (context, cartState) {
                    if (cartState is CartInitial || cartState is CartLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (cartState is CartError) {
                      return Text(cartState.message, style: const TextStyle(color: Colors.red));
                    }
                    if (cartState is CartLoaded) {
                      if (cartState.cart.items.isEmpty) {
                        return const Text('Your cart is empty.');
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order Summary', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          ...cartState.cart.items.map(
                            (item) => ListTile(
                              title: Text(item.product.name),
                              subtitle: Text('Qty: ${item.quantity}'),
                              trailing: Text('\$${item.subtotal.toStringAsFixed(2)}'),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                            trailing: Text(
                              '\$${cartState.cart.total.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (state.status == CheckoutStatus.loading)
                            const Center(child: CircularProgressIndicator())
                          else
                            const Text('Payment Method: Stripe (Mocked)'),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),
                isActive: state.currentStep >= 1,
                state: state.currentStep > 1 ? StepState.complete : StepState.editing,
              ),
            ],
          );
        },
      ),
    );
  }
}
