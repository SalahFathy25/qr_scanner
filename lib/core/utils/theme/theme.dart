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

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
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
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
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
