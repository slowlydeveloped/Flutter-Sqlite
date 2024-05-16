part of 'sign_in_bloc.dart';

@immutable
sealed class SignInState {}

final class SignInInitial extends SignInState {}

class SignInSuccess extends SignInState {
  final int userId;

  SignInSuccess({required this.userId});
}

class SignInFailure extends SignInState {
  final String? message;

  SignInFailure(this.message);
}

class SignInProgress extends SignInState {}
