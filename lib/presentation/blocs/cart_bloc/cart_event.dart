part of 'cart_bloc.dart';

@immutable
sealed class CartEvent {}

class FetchCartItemEvent extends CartEvent {
  final int userId; // Include userId parameter for user-specific data fetching

  FetchCartItemEvent({required this.userId});
}

class AddCartItemEvent extends CartEvent {
  final CartModel items;
  final int userId; // Include userId parameter for user-specific data

  AddCartItemEvent({required this.items, required this.userId});
}

class CartItemUpdateEvent extends CartEvent {
  final int id;
  final String product;
  final String description;
  final double amount;
  final int userId; 

  CartItemUpdateEvent(
      {required this.id,
      required this.product,
      required this.description,
      required this.amount,
      required this.userId});
}

class CartItemDeleteEvent extends CartEvent {
  final int id;
  final int userId; // Include userId parameter for user-specific data

  CartItemDeleteEvent(this.id, this.userId);
}

class CartItemAddedOnClickedEvent extends CartEvent {
  final CartItemModel clickedItem;
  final int userId; // Include userId parameter for user-specific data

  CartItemAddedOnClickedEvent({required this.clickedItem, required this.userId});
}

class CartItemIncreaseQuantityEvent extends CartEvent {
  final int itemId;
  final int userId; // Include userId parameter for user-specific data

  CartItemIncreaseQuantityEvent({required this.itemId, required this.userId});
}

// for search cart items

class CartItemSearchEvent extends CartEvent {
  final String keywords;
  final int userId; // Include userId parameter for user-specific data

  CartItemSearchEvent(this.keywords, this.userId);
}