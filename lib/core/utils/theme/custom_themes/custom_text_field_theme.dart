import 'package:flutter/material.dart';

class CustomTextFieldTheme {
  CustomTextFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: Colors.grey,
    suffixIconColor: Colors.grey,
    labelStyle: TextStyle().copyWith(color: Colors.black, fontSize: 14.0),
    hintStyle: TextStyle().copyWith(color: Colors.black, fontSize: 14.0),
    errorStyle: TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: TextStyle().copyWith(
      color: Colors.black.withOpacity(0.8),
    ),
    border: OutlineInputBorder().copyWith(
      borderSide: BorderSide(color: Colors.grey, width: 1.0),
      borderRadius: BorderRadius.circular(14.0),
    ),
    enabledBorder: OutlineInputBorder().copyWith(
      borderSide: BorderSide(color: Colors.grey, width: 1.0),
      borderRadius: BorderRadius.circular(14.0),
    ),
    focusedBorder: OutlineInputBorder().copyWith(
      borderSide: BorderSide(color: Colors.black12, width: 1.0),
      borderRadius: BorderRadius.circular(14.0),
    ),
    errorBorder: OutlineInputBorder().copyWith(
      borderSide: BorderSide(color: Colors.red, width: 1.0),
      borderRadius: BorderRadius.circular(14.0),
    ),
    focusedErrorBorder: OutlineInputBorder().copyWith(
      borderSide: BorderSide(color: Colors.orange, width: 2.0),
      borderRadius: BorderRadius.circular(14.0),
    ),
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 2,
    prefixIconColor: Colors.grey,
    suffixIconColor: Colors.grey,
    labelStyle: TextStyle().copyWith(color: Colors.white, fontSize: 14.0),
    hintStyle: TextStyle().copyWith(color: Colors.white, fontSize: 14.0),
    errorStyle: TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: TextStyle().copyWith(
      color: Colors.black.withOpacity(0.8),
    ),
    border: OutlineInputBorder().copyWith(
      borderSide: BorderSide(color: Colors.grey, width: 1.0),
      borderRadius: BorderRadius.circular(14.0),
    ),
    enabledBorder: OutlineInputBorder().copyWith(
      borderSide: BorderSide(color: Colors.grey, width: 1.0),
      borderRadius: BorderRadius.circular(14.0),
    ),
    focusedBorder: OutlineInputBorder().copyWith(
      borderSide: BorderSide(color: Colors.white, width: 1.0),
      borderRadius: BorderRadius.circular(14.0),
    ),
    errorBorder: OutlineInputBorder().copyWith(
      borderSide: BorderSide(color: Colors.red, width: 1.0),
      borderRadius: BorderRadius.circular(14.0),
    ),
    focusedErrorBorder: OutlineInputBorder().copyWith(
      borderSide: BorderSide(color: Colors.orange, width: 2.0),
      borderRadius: BorderRadius.circular(14.0),
    ),
  );
}
