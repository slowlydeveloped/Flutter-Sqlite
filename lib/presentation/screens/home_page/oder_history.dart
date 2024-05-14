import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_sources/sqlite.dart';
import '../../blocs/order_history_bloc/order_history_bloc.dart';
import 'order_details.dart';

class OrderHistoryScreen extends StatelessWidget {
  OrderHistoryScreen({super.key});

  OrderHistoryBloc orderHistoryBloc =
      OrderHistoryBloc(dataBaseHelper: DataBaseHelper())
        ..add(OrderHistoryFetchingEvent());
        
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: BlocBuilder<OrderHistoryBloc, OrderHistoryState>(
        bloc: orderHistoryBloc,
        builder: (context, state) {
          if (state is OrderHistoryLoadingError) {
            return Text(state.message);
          } else if (state is FetchOrderHistoryState) {
            return Stack(
              children: [
                ListView.builder(
                  itemCount: state.orderHistoryList.length,
                  itemBuilder: (context, index) {
                    final order = state.orderHistoryList[index];
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PaymentScreen(orderId: order["orderId"]),
                          ),
                        ).then((value) {
                          orderHistoryBloc.add(OrderHistoryFetchingEvent());
                        });
                      },
                      child: Card(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Order ID: ${order['orderId']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Total Price: ₹${order['totalAmount'].toStringAsFixed(2)}',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
