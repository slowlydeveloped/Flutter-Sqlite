import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/order_history_bloc/order_history_bloc.dart';

class PaymentScreen extends StatelessWidget {
  final String orderId;

  const PaymentScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    context
        .read<OrderHistoryBloc>()
        .add(FetchOrderDetailsEvent(orderId: orderId));
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back)),
        title: const Text('Order Details'),
      ),
      body: BlocBuilder<OrderHistoryBloc, OrderHistoryState>(
        builder: (context, state) {
          if (state is OrderDetailsFetchingState) {
            final orderDetailsList = state.orderDetailsList;
            double totalAmount = 0.0;
            for (final order in orderDetailsList) {
              totalAmount += order['totalAmount'];
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Order ID: ${orderDetailsList.isNotEmpty ? orderDetailsList.first['orderId'] : ''}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    showBottomBorder: true,
                    columnSpacing: 40,
                    columns: const [
                      DataColumn(label: Text('Product Name')),
                      DataColumn(label: Text('Quantity')),
                      DataColumn(label: Text('Amount')),
                    ],
                    rows: orderDetailsList.map((order) {
                      return DataRow(cells: [
                        DataCell(Text(order['productName'])),
                        DataCell(Text(order['quantity'].toString())),
                        DataCell(Text(
                            '₹${(order['totalAmount']).toStringAsFixed(2)}')),
                      ]);
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: Text('Failed to fetch order details.'),
            );
          }
        },
      ),
    );
  }
}
