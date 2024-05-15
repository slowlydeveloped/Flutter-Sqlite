import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/presentation/screens/home_page/oder_history.dart';
import '../../../data/models/cart_model.dart';
import '../../blocs/add_to_cart/add_to_cart_bloc.dart';

class AddToCartScreen extends StatelessWidget {
  const AddToCartScreen({super.key, required this.userId});

  final int userId;
  double _calculateTotalPrice(
      List<CartItemModel> cartItems, OfferState? offerState) {
    double totalPrice = 0.0;
    for (var item in cartItems) {
      if (item.isSelected) {
        double amountWithGST = item.amount * 1.18;
        double discountedAmount = offerState != null
            ? _calculateDiscountedAmount(amountWithGST, offerState)
            : amountWithGST;
        totalPrice += item.quantity * discountedAmount;
      }
    }
    return totalPrice;
  }

  double _calculateDiscountedAmount(double amount, OfferState offerState) {
    if (offerState is SBIState) {
      return amount * (1 - offerState.discountPercentage);
    } else if (offerState is AxisState) {
      return amount * (1 - offerState.discountPercentage);
    } else if (offerState is FirstTransactionState) {
      return amount * (1 - offerState.discountPercentage);
    } else {
      return amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<AddToCartBloc>().add(AddToCartInitialEvent());
    return Scaffold(
      appBar: AppBar(title: const Text("Add to Cart")),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
        child: BlocBuilder<AddToCartBloc, AddToCartState>(
          builder: (context, state) {
            if (state is AddToCartItemAddedSuccessState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: state.cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = state.cartItems[index];
                        return Card(
                          color: Colors.white,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Checkbox(
                                      value: cartItem.isSelected,
                                      onChanged: (bool? value) {
                                        BlocProvider.of<AddToCartBloc>(context)
                                            .add(
                                          CheckedItemsInCartEvent(
                                            checkedItems: state.cartItems,
                                            onClick: value!,
                                            index: index,
                                          ),
                                        );
                                      },
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 5),
                                            Text(
                                              "Product : ${cartItem.product}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                                "Desc: ${cartItem.description}"),
                                            Text(
                                                "₹ ${cartItem.amount.toStringAsFixed(2)}"),
                                            const Text(
                                                '(Inclusive of all taxes with 18% GST)'),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                    onTap: () {
                                                      context
                                                          .read<AddToCartBloc>()
                                                          .add(
                                                            OnMinusButtonEvent(
                                                                cartList: state
                                                                    .cartItems,
                                                                index: index,
                                                                quantity: cartItem
                                                                    .quantity,
                                                                totalPrice:
                                                                    cartItem
                                                                        .amount),
                                                          );
                                                    },
                                                    child: const Icon(
                                                        Icons.remove)),
                                                const SizedBox(width: 8),
                                                Text(cartItem.quantity
                                                    .toString()),
                                                const SizedBox(width: 8),
                                                GestureDetector(
                                                  onTap: () {
                                                    context
                                                        .read<AddToCartBloc>()
                                                        .add(
                                                          OnAddButtonEvent(
                                                              cartList: state
                                                                  .cartItems,
                                                              index: index,
                                                              quantity: cartItem
                                                                  .quantity,
                                                              totalPrice:
                                                                  cartItem
                                                                      .amount),
                                                        );
                                                  },
                                                  child: const Icon(Icons.add),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            const Row(
                                              children: [
                                                Icon(Icons.local_offer_outlined,
                                                    color: Colors.black),
                                                SizedBox(width: 5),
                                                Text(
                                                  'Offers',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                            ElevatedButton(
                                                onPressed: () {
                                                  context
                                                      .read<AddToCartBloc>()
                                                      .add(SelectSBIEvent(
                                                          index));
                                                },
                                                child: const Text(
                                                    '3% Discount on SBI credit card')),
                                            ElevatedButton(
                                                onPressed: () {
                                                  context
                                                      .read<AddToCartBloc>()
                                                      .add(SelectAxisEvent(
                                                          index));
                                                },
                                                child: const Text(
                                                    '5% Discount on Axis credit card')),
                                            ElevatedButton(
                                                onPressed: () {
                                                  context.read<AddToCartBloc>().add(
                                                      SelectFirstTransactionEvent(
                                                          index));
                                                },
                                                child: const Text(
                                                    'Flat 2% off on first transaction'))
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (cartItem.id != null) {
                                          context.read<AddToCartBloc>().add(
                                              RemoveProductFromCartEvent(
                                                  cartItem.id!));
                                        }
                                      },
                                      child: const Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        overflow: TextOverflow.ellipsis,
                        'Total Price: ₹ ${_calculateTotalPrice(state.cartItems, state.offerState).toStringAsFixed(2)}  (Inclusive of all taxes)',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      final selectedItems = state.cartItems
                          .where((items) => items.isSelected)
                          .toList();
                      if (selectedItems.isNotEmpty) {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                         OrderHistoryScreen(userId: userId)))
                            .then((value) => BlocProvider.of<AddToCartBloc>(context).add(AddToCartInitialEvent()));
                      }
                      context.read<AddToCartBloc>().add(PlaceOrderEvent());
                    },
                    child: const Text('Continue'),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
