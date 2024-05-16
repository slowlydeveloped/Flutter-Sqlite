import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/my_strings.dart';
import '../../../data/data_sources/sqlite.dart';
import '../../blocs/add_to_cart/add_to_cart_bloc.dart';
import '../../blocs/cart_bloc/cart_bloc.dart';
import '../../blocs/logged_out/logged_out_bloc.dart';
import '../../blocs/order_history_bloc/order_history_bloc.dart';
import '../../blocs/sign_in_bloc/sign_in_bloc.dart';
import '../../blocs/sign_up_bloc/sign_up_bloc.dart';
import 'cart.dart';

class MyAppWithUserId extends StatelessWidget {
  final DataBaseHelper dataBaseHelper;
  final int userId;

  MyAppWithUserId({required this.dataBaseHelper, required this.userId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SignInBloc>(
          create: (_) => SignInBloc(
            dataBaseHelper: dataBaseHelper,
          ),
        ),
        BlocProvider<SignUpBloc>(
          create: (_) => SignUpBloc(
            dataBaseHelper,
          ),
        ),
        BlocProvider<LoggedOutBloc>(
          create: (context) => LoggedOutBloc(),
        ),
        BlocProvider<CartBloc>(
          create: (context) => CartBloc(
            dataBaseHelper: dataBaseHelper,
            userId: userId,
          ),
        ),
        BlocProvider<OrderHistoryBloc>(
          create: (context) => OrderHistoryBloc(
              dataBaseHelper: dataBaseHelper, userId: userId),
        ),
        BlocProvider<AddToCartBloc>(
          create: (context) => AddToCartBloc(
            dataBaseHelper: dataBaseHelper,
            userId: userId,
          ),
        ),
      ],
      child: const MaterialApp(
        title: MyStrings.appName,
        debugShowCheckedModeBanner: false,
        home: HomePage(userName: ''), 
      ),
    );
  }
}
