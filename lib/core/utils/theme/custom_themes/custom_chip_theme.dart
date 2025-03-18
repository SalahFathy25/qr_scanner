import 'package:flutter/material.dart';

class CustomChipTheme {
  CustomChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: Colors.grey.withOpacity(0.4),
    labelStyle: TextStyle(color: Colors.black),
    selectedColor: Colors.blue,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    checkmarkColor: Colors.white,
  );

  static ChipThemeData darkChipTheme = ChipThemeData(
    disabledColor: Colors.grey,
    labelStyle: TextStyle(color: Colors.white),
    selectedColor: Colors.blue,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    checkmarkColor: Colors.white,
  );
}
