part of 'order_history_bloc.dart';

sealed class OrderHistoryEvent extends Equatable {
  const OrderHistoryEvent();

  @override
  List<Object> get props => [];
}

final class OrderHistoryFetchingEvent extends OrderHistoryEvent {}

final class OrderDetailsFetchingEvent extends OrderHistoryEvent {}

final class FetchOrderDetailsEvent extends OrderHistoryEvent {
  final String orderId;

  const FetchOrderDetailsEvent({required this.orderId});
}
