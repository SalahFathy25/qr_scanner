import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code/cubit/qr_cubit.dart';
import 'package:qr_code/screens/home.dart';
import 'package:qr_code/utils/theme/theme.dart';

void main() {
  runApp(BlocProvider(create: (context) => QrCubit(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Apptheme.lightTheme,
      darkTheme: Apptheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Home(),
    );
  }
}
