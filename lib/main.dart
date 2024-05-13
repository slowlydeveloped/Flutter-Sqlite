import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../presentation/blocs/order_history_bloc/order_history_bloc.dart';
import '../presentation/blocs/add_to_cart/add_to_cart_bloc.dart';
import '../presentation/blocs/cart_bloc/cart_bloc.dart';
import '../presentation/blocs/logged_out/logged_out_bloc.dart';
import '../presentation/blocs/sign_in_bloc/sign_in_bloc.dart';
import '../presentation/blocs/sign_up_bloc/sign_up_bloc.dart';
import '../data/data_sources/sqlite.dart';
import '../presentation/screens/home_page/add_to_cart.dart';
import '../core/constants/my_strings.dart';
import '../core/themes/app_themes.dart';
import '../presentation/router/router_imports.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(dataBaseHelper: DataBaseHelper()));
}

class MyApp extends StatelessWidget {
  final DataBaseHelper dataBaseHelper;
  MyApp({super.key, required this.dataBaseHelper});
  final _appRouter = AppRouter();
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
                ),
              ),
              BlocProvider<SignUpBloc>(
                create: (_) => SignUpBloc(
                  DataBaseHelper(),
                ),
              ),
              BlocProvider<LoggedOutBloc>(create: (context) => LoggedOutBloc()),
              BlocProvider<CartBloc>(
                  create: (context) =>
                      CartBloc(dataBaseHelper: dataBaseHelper)),
              BlocProvider(
                  create: (context) =>
                      OrderHistoryBloc(dataBaseHelper: dataBaseHelper)),
              BlocProvider(
                create: (context) =>
                    AddToCartBloc(dataBaseHelper: dataBaseHelper),
                child: const AddToCartScreen(),
              )
            ],
            child: MaterialApp.router(
              title: MyStrings.appName,
              theme: AppThemes.light,
              darkTheme: AppThemes.dark,
              debugShowCheckedModeBanner: false,
              routerConfig: _appRouter.config(),
            ),
          );
        });
  }
}
