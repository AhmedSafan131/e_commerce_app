import 'package:e_commerce_app/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:e_commerce_app/features/orders/presentation/bloc/orders_event.dart';
import 'package:e_commerce_app/features/orders/presentation/bloc/orders_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(const LoadOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders'), automaticallyImplyLeading: false),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          if (state.status == OrdersStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == OrdersStatus.failure) {
            return Center(child: Text(state.errorMessage ?? 'Failed to load orders'));
          }
          if (state.orders.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }
          return ListView.separated(
            itemCount: state.orders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final order = state.orders[index];
              return ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text('Order ${order.id.substring(0, 8)}'),
                subtitle: Text('${order.status} • ${order.date.toLocal()}'),
                trailing: Text('\$${order.totalAmount.toStringAsFixed(2)}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.read<OrdersBloc>().add(const LoadOrdersEvent());
        },
        foregroundColor: Colors.white,
        label: const Text('Refresh'),
        icon: const Icon(Icons.refresh),
      ),
    );
  }
}
