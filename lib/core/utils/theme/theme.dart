import 'package:flutter/material.dart';

import 'custom_themes/custom_appbar_theme.dart';
import 'custom_themes/custom_bottom_sheet_theme.dart';
import 'custom_themes/custom_checkbox_theme.dart';
import 'custom_themes/custom_chip_theme.dart';
import 'custom_themes/custom_elevated_button_theme.dart';
import 'custom_themes/custom_outlined_button_theme.dart';
import 'custom_themes/custom_text_field_theme.dart';
import 'custom_themes/custom_text_theme.dart';

class Apptheme {
  Apptheme._();

  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF00BFA6);
  static const Color surface = Color(0xFFF8F9FE);
  static const Color onSurface = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF0F0F1A);
  static const Color darkOnSurface = Color(0xFFE8E8F0);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: surface,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
      onSurface: onSurface,
    ),
    textTheme: CustomTextTheme.lightTextTheme,
    chipTheme: CustomChipTheme.lightChipTheme,
    appBarTheme: CustomAppbarTheme.lightAppBarTheme,
    checkboxTheme: CustomCheckboxTheme.lightCheckboxTheme,
    bottomSheetTheme: CustomBottomSheetTheme.lightBottomSheetTheme,
    elevatedButtonTheme: CustomElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: CustomOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: CustomTextFieldTheme.lightInputDecorationTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: darkSurface,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: darkSurface,
      onSurface: darkOnSurface,
    ),
    textTheme: CustomTextTheme.darkTextTheme,
    chipTheme: CustomChipTheme.darkChipTheme,
    appBarTheme: CustomAppbarTheme.darkAppBarTheme,
    checkboxTheme: CustomCheckboxTheme.darkCheckboxTheme,
    bottomSheetTheme: CustomBottomSheetTheme.darkBottomSheetTheme,
    elevatedButtonTheme: CustomElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: CustomOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: CustomTextFieldTheme.darkInputDecorationTheme,
  );
}
