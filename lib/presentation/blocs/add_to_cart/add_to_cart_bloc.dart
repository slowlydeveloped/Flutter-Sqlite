import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
// import 'package:meta/meta.dart';

import '../../../data/data_sources/sqlite.dart';
import '../../../data/models/cart_model.dart';

part 'add_to_cart_event.dart';
part 'add_to_cart_state.dart';

class AddToCartBloc extends Bloc<AddToCartEvent, AddToCartState> {
  final DataBaseHelper _dataBaseHelper;
  final int userId; // New field to store the user ID.

  // Constructor for AddToCartBloc.
  // Parameters:
  //   - dataBaseHelper: Instance of DataBaseHelper used for database operations.
  //   - userId: ID of the current user.
  AddToCartBloc({
    required DataBaseHelper dataBaseHelper,
    required this.userId,
  })  : _dataBaseHelper = dataBaseHelper,
        super(AddToCartInitial()) {
    // Event handlers for various AddToCart events.

    // AddToCartInitialEvent: Event triggered to fetch items from the cart.
    on<AddToCartInitialEvent>((event, emit) async {
      emit(AddToCartLoadingState());
      try {
        final item = await _dataBaseHelper.getAddToCartItems(userId);
        emit(AddToCartItemAddedSuccessState(cartItems: item, offerState: null));
      } catch (e) {
        emit(AddToCartErrorState("Oops Something went wrong!!!"));
      }
    });

    // RemoveProductFromCartEvent: Event triggered to remove a product from the cart.
    on<RemoveProductFromCartEvent>((event, emit) async {
      emit(AddToCartLoadingState());
      try {
        final id = await _dataBaseHelper.removeFromCart(event.id);
        final item = await _dataBaseHelper.getAddToCartItems(userId);

        emit(ItemRemovedFromCartState(id));
        emit(AddToCartItemAddedSuccessState(cartItems: item, offerState: null));
      } catch (e) {
        emit(AddToCartErrorState("Oops Something went wrong!!!"));
      }
    });

    // Other event handlers remain unchanged but should also pass `userId` where necessary.
    // CheckedItemsInCartEvent: Event triggered when items in the cart are checked.
    on<CheckedItemsInCartEvent>((event, emit) {
      event.checkedItems[event.index!].isSelected =
          !event.checkedItems[event.index!].isSelected;
      emit(AddToCartItemAddedSuccessState(cartItems: event.checkedItems));
    });

    // OnAddButtonEvent: Event triggered when the add button is clicked.
    on<OnAddButtonEvent>((event, emit) {
      event.quantity = event.quantity! + 1;
      event.cartList[event.index!].quantity = event.quantity!;
      double newTotalPrice = event.cartList
          .fold(0.0, (total, item) => total + (item.quantity * item.amount));
      event.cartList.first.totalPrice = newTotalPrice;
      emit(AddToCartItemAddedSuccessState(cartItems: event.cartList));
    });

    // OnMinusButtonEvent: Event triggered when the minus button is clicked.
    on<OnMinusButtonEvent>((event, emit) {
      if (event.quantity! > 1) {
        event.quantity = event.quantity! - 1;
        event.cartList[event.index!].quantity = event.quantity!;
        double newTotalPrice = event.cartList
            .fold(0.0, (total, item) => total + (item.quantity * item.amount));
        event.cartList.first.totalPrice = newTotalPrice;
        emit(AddToCartItemAddedSuccessState(cartItems: event.cartList));
      }
    });

    // SelectSBIEvent: Event triggered when SBI is selected.
    on<SelectSBIEvent>((event, emit) {
      final currentState = state;
      if (currentState is AddToCartItemAddedSuccessState) {
        emit(AddToCartItemAddedSuccessState(
          cartItems: currentState.cartItems,
          offerState: SBIState(),
        ));
      }
    });

    // SelectAxisEvent: Event triggered when Axis is selected.
    on<SelectAxisEvent>((event, emit) {
      final currentState = state;
      if (currentState is AddToCartItemAddedSuccessState) {
        emit(AddToCartItemAddedSuccessState(
          cartItems: currentState.cartItems,
          offerState: AxisState(),
        ));
      }
    });

    // SelectFirstTransactionEvent: Event triggered when FirstTransaction is selected.
    on<SelectFirstTransactionEvent>((event, emit) {
      final currentState = state;
      if (currentState is AddToCartItemAddedSuccessState) {
        emit(AddToCartItemAddedSuccessState(
          cartItems: currentState.cartItems,
          offerState: FirstTransactionState(),
        ));
      }
    });

    // PlaceOrderEvent: Event triggered to place an order.
    on<PlaceOrderEvent>((event, emit) async {
      if (state is AddToCartItemAddedSuccessState) {
        try {
          final selectedItems = (state as AddToCartItemAddedSuccessState)
              .cartItems
              .where((item) => item.isSelected)
              .toList();

          final orderId = UniqueKey().toString();
          await _dataBaseHelper.saveOrderHistory(
              orderId, selectedItems, userId);

          emit(OrderPlacedState(orderId));
        } catch (e) {
          emit(AddToCartErrorState("Failed to place order."));
        }
      }
    });
  }
}
