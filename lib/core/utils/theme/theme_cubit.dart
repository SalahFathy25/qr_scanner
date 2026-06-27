import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_code/core/constants/app_constants.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(_loadTheme(_prefs));

  static ThemeMode _loadTheme(SharedPreferences prefs) {
    final index = prefs.getInt(AppConstants.themeModeKey) ?? 0;
    return ThemeMode.values[index];
  }

  void setTheme(ThemeMode mode) {
    _prefs.setInt(AppConstants.themeModeKey, mode.index);
    emit(mode);
  }

  void toggleTheme() {
    final next = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    setTheme(next);
  }
}
