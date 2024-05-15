import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'logged_out_event.dart';
part 'logged_out_state.dart';

class LoggedOutBloc extends Bloc<LoggedOutEvent, LoggedOutState> {
  LoggedOutBloc() : super(LoggedOutInitial()) {
    on<UserRequestedLogout>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLogged');
      emit(LogoutSuccess());
    });
  }
}
