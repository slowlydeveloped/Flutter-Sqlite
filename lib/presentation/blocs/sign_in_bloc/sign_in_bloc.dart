import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/data_sources/sqlite.dart';
part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final DataBaseHelper dataBaseHelper;

  SignInBloc({required this.dataBaseHelper}) : super(SignInInitial()) {
    on<SignInRequiredEvent>(_onSignInButtonPressed);
  }

  void _onSignInButtonPressed(
      SignInRequiredEvent event, Emitter<SignInState> emit) async {
    emit(SignInProgress());

    try {
      final userId = await dataBaseHelper.getUserId(event.userName);
      if (userId != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLogged', true);
        await prefs.setInt('userId', userId);

        print('User ID $userId stored in SharedPreferences.');
        emit(SignInSuccess(userId: userId));
      } else {
        emit(SignInFailure('User not found'));
      }
    } catch (error) {
      emit(SignInFailure(error.toString()));
    }
  }
}
