import 'package:flutter/material.dart';
import 'package:qr_code/app/models/category_model.dart';

class AppConstants {
  static const String storageKey = 'all_qr_codes';
  static const String scanHistoryKey = 'scan_history';
  static const String customCategoriesKey = 'custom_categories';

  static const List<CategoryModel> builtInCategories = [
    CategoryModel(
      id: 'whatsapp',
      name: 'WhatsApp',
      icon: Icons.chat,
      colorValue: 0xFF33D951,
      imagePath: 'assets/logos/whatsapp_logo.png',
    ),
    CategoryModel(
      id: 'facebook',
      name: 'Facebook',
      icon: Icons.facebook,
      colorValue: 0xFF0F8FF2,
      imagePath: 'assets/logos/facebook_logo.png',
    ),
    CategoryModel(
      id: 'instagram',
      name: 'Instagram',
      icon: Icons.camera_alt,
      colorValue: 0xFFE73D5D,
      imagePath: 'assets/logos/instagram_logo.png',
    ),
    CategoryModel(
      id: 'linkedin',
      name: 'LinkedIn',
      icon: Icons.work,
      colorValue: 0xFF2967B0,
      imagePath: 'assets/logos/linkedin_logo.png',
    ),
    CategoryModel(
      id: 'wifi',
      name: 'WiFi',
      icon: Icons.wifi,
      colorValue: 0xFF1E88E5,
    ),
    CategoryModel(
      id: 'email',
      name: 'Email',
      icon: Icons.email,
      colorValue: 0xFFE53935,
    ),
    CategoryModel(
      id: 'vcard',
      name: 'vCard',
      icon: Icons.contact_page,
      colorValue: 0xFF43A047,
    ),
    CategoryModel(
      id: 'url',
      name: 'URL',
      icon: Icons.link,
      colorValue: 0xFFFB8C00,
    ),
    CategoryModel(
      id: 'text',
      name: 'Text',
      icon: Icons.text_fields,
      colorValue: 0xFF7B1FA2,
    ),
  ];

  static const List<CategoryModel> socialMediaCategories = [
    CategoryModel(
      id: 'whatsapp',
      name: 'WhatsApp',
      icon: Icons.chat,
      colorValue: 0xFF33D951,
      imagePath: 'assets/logos/whatsapp_logo.png',
    ),
    CategoryModel(
      id: 'facebook',
      name: 'Facebook',
      icon: Icons.facebook,
      colorValue: 0xFF0F8FF2,
      imagePath: 'assets/logos/facebook_logo.png',
    ),
    CategoryModel(
      id: 'instagram',
      name: 'Instagram',
      icon: Icons.camera_alt,
      colorValue: 0xFFE73D5D,
      imagePath: 'assets/logos/instagram_logo.png',
    ),
    CategoryModel(
      id: 'linkedin',
      name: 'LinkedIn',
      icon: Icons.work,
      colorValue: 0xFF2967B0,
      imagePath: 'assets/logos/linkedin_logo.png',
    ),
  ];
}
