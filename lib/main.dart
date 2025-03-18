import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code/app/cubit/qr_cubit.dart';
import 'package:qr_code/app/screens/home.dart';
import 'package:qr_code/core/utils/theme/theme.dart';

void main() {
  runApp(BlocProvider(create: (context) => QrCubit(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Apptheme.lightTheme,
        darkTheme: Apptheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const Home(),
      ),
    );
  }
}
