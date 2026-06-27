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
import 'package:qr_code/core/utils/theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool(AppConstants.onboardingDoneKey) ?? false;

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => QrCubit()),
        BlocProvider(create: (_) => ScanHistoryCubit()),
        BlocProvider(create: (_) => CustomCategoryCubit()),
        BlocProvider(create: (_) => ThemeCubit(prefs)),
      ],
      child: MyApp(onboardingDone: onboardingDone),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool onboardingDone;
  const MyApp({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(
      ThemeData.light().textTheme,
    );

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          theme: Apptheme.lightTheme.copyWith(textTheme: textTheme),
          darkTheme: Apptheme.darkTheme.copyWith(textTheme: GoogleFonts.poppinsTextTheme(
            ThemeData.dark().textTheme,
          )),
          themeMode: themeMode,
          home: onboardingDone ? const Home() : OnboardingScreen(onDone: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(AppConstants.onboardingDoneKey, true);
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const Home()),
              );
            }
          }),
        );
      },
    );
  }
}
