part of 'logged_out_bloc.dart';

@immutable
sealed class LoggedOutEvent {
  final BuildContext context;
  const LoggedOutEvent(this.context);
}

class UserRequestedLogout extends LoggedOutEvent {
  UserRequestedLogout(BuildContext context) : super(context);
}
