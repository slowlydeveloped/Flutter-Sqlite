import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sql_crud/presentation/screens/splash/splash_import.dart';
import '../presentation/blocs/order_history_bloc/order_history_bloc.dart';
import '../presentation/blocs/add_to_cart/add_to_cart_bloc.dart';
import '../presentation/blocs/cart_bloc/cart_bloc.dart';
import '../presentation/blocs/logged_out/logged_out_bloc.dart';
import '../presentation/blocs/sign_in_bloc/sign_in_bloc.dart';
import '../presentation/blocs/sign_up_bloc/sign_up_bloc.dart';
import '../data/data_sources/sqlite.dart';
import '../core/constants/my_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final dataBaseHelper = DataBaseHelper();
  // final userId = await dataBaseHelper.getUserId('lenovo@gmail.com', 'lenovo');
  runApp(MyApp(dataBaseHelper: DataBaseHelper(), userId: 1));
}

class MyApp extends StatelessWidget {
  final DataBaseHelper dataBaseHelper;
  final int userId;

  MyApp({super.key, required this.dataBaseHelper, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<SignInBloc>(
              create: (_) => SignInBloc(
                dataBaseHelper: dataBaseHelper,
                userId: userId
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
                userId: userId, // Pass userId to CartBloc
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
          child: MaterialApp(
            title: MyStrings.appName,
            debugShowCheckedModeBanner: false,
            home: Splash(),
          ),
        );
      },
    );
  }
}
