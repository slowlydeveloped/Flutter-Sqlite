import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/presentation/screens/auth/login/login_imports.dart';
import '../data/data_sources/sqlite.dart';
import '../core/constants/my_strings.dart';
import 'presentation/blocs/sign_in_bloc/sign_in_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dataBaseHelper = DataBaseHelper();
  runApp(MyApp(dataBaseHelper: dataBaseHelper));
}

class MyApp extends StatelessWidget {
  final DataBaseHelper dataBaseHelper;

  const MyApp({super.key, required this.dataBaseHelper});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return BlocProvider(
          create: (_) => SignInBloc(dataBaseHelper: dataBaseHelper),
          child: const MaterialApp(
              title: MyStrings.appName,
              debugShowCheckedModeBanner: false,
              home: Login()),
        );
      },
    );
  }
}
