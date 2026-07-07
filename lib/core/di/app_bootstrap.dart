import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_studio/core/constants/app_constants.dart';
import 'package:qr_studio/core/services/storage_service.dart';

final class AppBootstrap {
  AppBootstrap._();

  static late final StorageService storage;
  static late final TextTheme lightGoogleFonts;
  static late final TextTheme darkGoogleFonts;
  static late final bool onboardingDone;

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    storage = StorageService(prefs);
    onboardingDone = storage.getBool(AppConstants.onboardingDoneKey);
    lightGoogleFonts = GoogleFonts.poppinsTextTheme(
      ThemeData.light().textTheme,
    );
    darkGoogleFonts = GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    );
  }
}
