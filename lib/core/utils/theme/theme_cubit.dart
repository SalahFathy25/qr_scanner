import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:qr_studio/core/constants/app_constants.dart';
import 'package:qr_studio/core/services/storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._storage) : super(_loadTheme(_storage));

  final StorageService _storage;

  static ThemeMode _loadTheme(StorageService storage) {
    final index = storage.getInt(AppConstants.themeModeKey);
    return ThemeMode.values[index];
  }

  void setTheme(ThemeMode mode) {
    _storage.setInt(AppConstants.themeModeKey, mode.index);
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
