import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_code/app/data/custom_category_cubit.dart';
import 'package:qr_code/app/data/qr_cubit.dart';
import 'package:qr_code/app/data/scan_history_cubit.dart';
import 'package:qr_code/app/screens/home.dart';
import 'package:qr_code/app/screens/onboarding_screen.dart';
import 'package:qr_code/core/constants/app_constants.dart';
import 'package:qr_code/core/utils/theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(
      ThemeData.light().textTheme,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: Apptheme.lightTheme.copyWith(textTheme: textTheme),
      darkTheme: Apptheme.darkTheme.copyWith(textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      )),
      themeMode: ThemeMode.system,
      home: const AppEntry(),
    );
  }
}

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkOnboarding(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        if (snapshot.data == true) {
          return const MainApp();
        }

        return OnboardingScreen(onDone: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(AppConstants.onboardingDoneKey, true);
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainApp()),
            );
          }
        });
      },
    );
  }

  Future<bool> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.onboardingDoneKey) ?? false;
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => QrCubit()),
        BlocProvider(create: (_) => ScanHistoryCubit()),
        BlocProvider(create: (_) => CustomCategoryCubit()),
      ],
      child: const Home(),
    );
  }
}
