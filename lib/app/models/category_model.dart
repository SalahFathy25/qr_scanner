import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final int colorValue;
  final bool isBuiltIn;
  final String? imagePath;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    this.isBuiltIn = true,
    this.imagePath,
  });

  Color get color => Color(colorValue);

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: _iconFromCodePoint(json['iconCodePoint'] as int),
      colorValue: json['colorValue'] as int,
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      imagePath: json['imagePath'] as String?,
    );
  }

  static IconData _iconFromCodePoint(int codePoint) {
    // ignore: non_const_argument_for_const_parameter
    return IconData(codePoint);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': icon.codePoint,
      'colorValue': colorValue,
      'isBuiltIn': isBuiltIn,
      'imagePath': imagePath,
    };
  }
}
