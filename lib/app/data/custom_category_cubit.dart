import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:qr_code/app/models/category_model.dart';
import 'package:qr_code/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class CustomCategoryState {}

final class CustomCategoriesLoaded extends CustomCategoryState {
  final List<CategoryModel> categories;
  CustomCategoriesLoaded({required this.categories});
}

class CustomCategoryCubit extends Cubit<CustomCategoryState> {
  CustomCategoryCubit() : super(CustomCategoriesLoaded(categories: [])) {
    _loadCustomCategories();
  }

  Future<void> _loadCustomCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList =
          prefs.getStringList(AppConstants.customCategoriesKey) ?? [];
      final categories = jsonList
          .map((j) => CategoryModel.fromJson(jsonDecode(j)))
          .toList();
      emit(CustomCategoriesLoaded(categories: categories));
    } catch (_) {
      emit(CustomCategoriesLoaded(categories: []));
    }
  }

  List<CategoryModel> getAllCategories() {
    final builtIn = AppConstants.builtInCategories;
    final custom = state is CustomCategoriesLoaded
        ? (state as CustomCategoriesLoaded).categories
        : <CategoryModel>[];
    return [...builtIn, ...custom];
  }

  Future<void> addCustomCategory(String name, IconData icon, int color) async {
    try {
      final current = state is CustomCategoriesLoaded
          ? (state as CustomCategoriesLoaded).categories
          : <CategoryModel>[];
      final newCat = CategoryModel(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        icon: icon,
        colorValue: color,
        isBuiltIn: false,
      );
      final updated = [...current, newCat];
      await _save(updated);
      emit(CustomCategoriesLoaded(categories: updated));
    } catch (_) {}
  }

  Future<void> deleteCustomCategory(String id) async {
    try {
      final current = state is CustomCategoriesLoaded
          ? (state as CustomCategoriesLoaded).categories
          : <CategoryModel>[];
      final updated = current.where((c) => c.id != id).toList();
      await _save(updated);
      emit(CustomCategoriesLoaded(categories: updated));
    } catch (_) {}
  }

  Future<void> _save(List<CategoryModel> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = categories.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(AppConstants.customCategoriesKey, jsonList);
  }
}
