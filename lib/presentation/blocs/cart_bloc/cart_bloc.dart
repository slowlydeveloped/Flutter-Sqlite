import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/data_sources/sqlite.dart';
import '../../../data/models/cart_model.dart';

part 'cart_event.dart';
part 'cart_state.dart';

// Bloc responsible for managing the cart functionality.
class CartBloc extends Bloc<CartEvent, CartState> {
  final DataBaseHelper _dataBaseHelper;

  // Constructor for CartBloc.
  // Parameters:
  //   - dataBaseHelper: Instance of DataBaseHelper used for database operations.
  CartBloc({required DataBaseHelper dataBaseHelper})
      : _dataBaseHelper = dataBaseHelper,
        super(CartInitial()) {
    // Event handlers for various cart-related events.

    // FetchCartItemEvent: Event triggered to fetch items from the cart.
    on<FetchCartItemEvent>((event, emit) async {
      emit(CartScreenLoadingState());
      try {
        final items = await _dataBaseHelper.getCartItem();
        emit(CartScreenLoadedState(cartItems: items));
      } catch (e) {
        emit(CartErrorState("Failed to load products!!!"));
      }
    });

    // CartItemUpdateEvent: Event triggered to update a cart item.
    on<CartItemUpdateEvent>((event, emit) async {
      emit(CartScreenLoadingState());
      try {
        final id = await _dataBaseHelper.updateCartItem(
            event.id, event.product, event.description, event.amount);
        final items = await _dataBaseHelper.getCartItem();
        emit(CartItemUpdateState(id));
        emit(CartScreenLoadedState(cartItems: items));
      } catch (e) {
        emit(CartErrorState('Failed to Update the items!!!'));
      }
    });

    // CartItemDeleteEvent: Event triggered to delete a cart item.
    on<CartItemDeleteEvent>((event, emit) async {
      emit(CartScreenLoadingState());
      try {
        await _dataBaseHelper.deleteCartItem(event.id);
        final items = await _dataBaseHelper.getCartItem();
        emit(CartItemDeleteState(event.id));
        emit(CartScreenLoadedState(cartItems: items));
      } catch (e) {
        emit(CartErrorState("Failed to Deleted Item!!!"));
      }
    });

    // AddCartItemEvent: Event triggered to add a new item to the cart.
    on<AddCartItemEvent>((event, emit) async {
      emit(CartScreenLoadingState());
      try {
        final id = await _dataBaseHelper.createCartItem(event.items);
        final items = await _dataBaseHelper.getCartItem();
        emit(CartItemAddedState(id));
        emit(CartScreenLoadedState(cartItems: items));
      } catch (e) {
        emit(CartErrorState("Failed to add items!"));
      }
    });

    // CartItemAddedOnClickedEvent: Event triggered when a cart item is clicked to be added to the cart.
    on<CartItemAddedOnClickedEvent>((event, emit) async {
      emit(CartScreenLoadingState());
      try {
        final id = await _dataBaseHelper.addToCart(event.clickedItem);
        final items = await _dataBaseHelper.getCartItem();
        emit(CartItemAddedOnClickedState(id));
        emit(CartScreenLoadedState(cartItems: items));
      } catch (e) {
        emit(CartErrorState("Failed to add item!!!"));
      }
    });

    // CartItemSearchEvent: Event triggered to search for items in the cart.
    on<CartItemSearchEvent>((event, emit) async {
      emit(SearchLoadingState());
      try {
        dynamic items = await _dataBaseHelper.searchCartItem(event.keywords);
        // final item = await _dataBaseHelper.getCartItem();
        emit(CartScreenLoadedState(cartItems: items));
        // emit(CartScreenLoadedState(cartItems: item));
      } catch (e) {
        emit(CartErrorState("Failed to perform search"));
      }
    });
  }
}
