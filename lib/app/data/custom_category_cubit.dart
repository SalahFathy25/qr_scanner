import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:qr_studio/app/models/category_model.dart';
import 'package:qr_studio/core/constants/app_constants.dart';
import 'package:qr_studio/core/services/storage_service.dart';

sealed class CustomCategoryState {
  const CustomCategoryState();
}

final class CustomCategoriesLoaded extends CustomCategoryState {
  final List<CategoryModel> categories;
  const CustomCategoriesLoaded({required this.categories});
}

class CustomCategoryCubit extends Cubit<CustomCategoryState> {
  CustomCategoryCubit(this._storage)
      : super(const CustomCategoriesLoaded(categories: [])) {
    _loadCustomCategories();
  }

  final StorageService _storage;

  Future<void> _loadCustomCategories() async {
    try {
      final categories = await _storage.loadCustomCategories();
      emit(CustomCategoriesLoaded(categories: categories));
    } catch (_) {
      emit(const CustomCategoriesLoaded(categories: []));
    }
  }

  List<CategoryModel> getAllCategories() {
    final builtIn = AppConstants.builtInCategories;
    final custom = switch (state) {
      CustomCategoriesLoaded(:final categories) => categories,
    };
    return [...builtIn, ...custom];
  }

  Future<void> addCustomCategory(String name, IconData icon, int color) async {
    try {
      final current = switch (state) {
        CustomCategoriesLoaded(:final categories) => categories,
      };
      final newCat = CategoryModel(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        icon: icon,
        colorValue: color,
        isBuiltIn: false,
      );
      final updated = [...current, newCat];
      await _storage.saveCustomCategories(updated);
      emit(CustomCategoriesLoaded(categories: updated));
    } catch (_) {}
  }

  Future<void> deleteCustomCategory(String id) async {
    try {
      final current = switch (state) {
        CustomCategoriesLoaded(:final categories) => categories,
      };
      final updated = current.where((c) => c.id != id).toList();
      await _storage.saveCustomCategories(updated);
      emit(CustomCategoriesLoaded(categories: updated));
    } catch (_) {}
  }
}
