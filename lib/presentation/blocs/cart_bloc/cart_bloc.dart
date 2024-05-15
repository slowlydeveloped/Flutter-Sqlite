import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/data_sources/sqlite.dart';
import '../../../data/models/cart_model.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final DataBaseHelper _dataBaseHelper;
  final int userId; 

  CartBloc({required DataBaseHelper dataBaseHelper, required this.userId})
      : _dataBaseHelper = dataBaseHelper,
        super(CartInitial()) {
    // Event handlers for various cart-related events.

    on<FetchCartItemEvent>((event, emit) async {
      emit(CartScreenLoadingState());
      try {
        final items = await _dataBaseHelper.getCartItem(userId);
        emit(CartScreenLoadedState(cartItems: items));
      } catch (e) {
        emit(CartErrorState("Failed to load products!!!"));
      }
    });

    on<AddCartItemEvent>((event, emit) async {
      emit(CartScreenLoadingState());
      try {
        final id = await _dataBaseHelper.createCartItem(event.items, userId);
        final items = await _dataBaseHelper.getCartItem(userId);
        emit(CartItemCreatedState(id));
        emit(CartScreenLoadedState(cartItems: items));
      } catch (e) {
        emit(CartErrorState("Failed to add items!"));
      }
    });

    on<CartItemUpdateEvent>((event, emit) async {
      emit(CartScreenLoadingState());
      try {
        final id = await _dataBaseHelper.updateCartItem(
            event.id, event.product, event.description, event.amount, event.userId);
        final items = await _dataBaseHelper.getCartItem(userId);
        emit(CartItemUpdateState(id));
        emit(CartScreenLoadedState(cartItems: items));
      } catch (e) {
        emit(CartErrorState('Failed to Update the items!!!'));
      }
    });

    on<CartItemDeleteEvent>((event, emit) async {
      emit(CartScreenLoadingState());
      try {
        await _dataBaseHelper.deleteCartItem(event.id);
        final items = await _dataBaseHelper.getCartItem(userId);
        emit(CartItemDeleteState(event.id));
        emit(CartScreenLoadedState(cartItems: items));
      } catch (e) {
        emit(CartErrorState("Failed to Deleted Item!!!"));
      }
    });

    on<CartItemAddedOnClickedEvent>((event, emit) async {
      emit(CartScreenLoadingState());
      try {
        final id = await _dataBaseHelper.addToCart(event.clickedItem, userId);
        final items = await _dataBaseHelper.getCartItem(userId);
        emit(CartItemAddedOnClickedState(id));
        emit(CartScreenLoadedState(cartItems: items));
      } catch (e) {
        emit(CartErrorState("Failed to add item!!!"));
      }
    });

    on<CartItemSearchEvent>((event, emit) async {
      emit(SearchLoadingState());
      try {
        dynamic items = await _dataBaseHelper.searchCartItem(event.keywords, event.userId);
        emit(CartScreenLoadedState(cartItems: items));
      } catch (e) {
        emit(CartErrorState("Failed to perform search"));
      }
    });
  }
}
