part of 'order_history_bloc.dart';

sealed class OrderHistoryState extends Equatable {
  const OrderHistoryState();

  @override
  List<Object> get props => [];
}

final class OrderHistoryInitial extends OrderHistoryState {}

final class OrderHistoryLoading extends OrderHistoryState {}

final class FetchOrderHistoryState extends OrderHistoryState {
  final List<Map<String, dynamic>> orderHistoryList;

  const FetchOrderHistoryState({required this.orderHistoryList});
}

final class OrderHistoryLoadingError extends OrderHistoryState {
  final String message;

  const OrderHistoryLoadingError(this.message);
}

final class OrderDetailsFetchingState extends OrderHistoryState {
  final List<Map<String, dynamic>> orderDetailsList;

  const OrderDetailsFetchingState({required this.orderDetailsList});
}
