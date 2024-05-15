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
  }
}
