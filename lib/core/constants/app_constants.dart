import 'package:flutter/material.dart';
import 'package:qr_code/app/models/category_model.dart';

class AppConstants {
  AppConstants._();

  static const String storageKey = 'all_qr_codes';
  static const String scanHistoryKey = 'scan_history';
  static const String customCategoriesKey = 'custom_categories';
  static const String onboardingDoneKey = 'onboarding_done';
  static const String appName = 'QR Studio';

  static const List<CategoryModel> builtInCategories = [
    CategoryModel(id: 'whatsapp', name: 'WhatsApp', icon: Icons.chat, colorValue: 0xFF33D951, imagePath: 'assets/logos/whatsapp_logo.png'),
    CategoryModel(id: 'facebook', name: 'Facebook', icon: Icons.facebook, colorValue: 0xFF0F8FF2, imagePath: 'assets/logos/facebook_logo.png'),
    CategoryModel(id: 'instagram', name: 'Instagram', icon: Icons.camera_alt, colorValue: 0xFFE73D5D, imagePath: 'assets/logos/instagram_logo.png'),
    CategoryModel(id: 'linkedin', name: 'LinkedIn', icon: Icons.work, colorValue: 0xFF2967B0, imagePath: 'assets/logos/linkedin_logo.png'),
    CategoryModel(id: 'wifi', name: 'WiFi', icon: Icons.wifi, colorValue: 0xFF1E88E5),
    CategoryModel(id: 'email', name: 'Email', icon: Icons.email, colorValue: 0xFFE53935),
    CategoryModel(id: 'vcard', name: 'vCard', icon: Icons.contact_page, colorValue: 0xFF43A047),
    CategoryModel(id: 'url', name: 'URL', icon: Icons.link, colorValue: 0xFFFB8C00),
    CategoryModel(id: 'text', name: 'Text', icon: Icons.text_fields, colorValue: 0xFF7B1FA2),
    CategoryModel(id: 'calendar', name: 'Calendar', icon: Icons.event, colorValue: 0xFF1565C0),
    CategoryModel(id: 'location', name: 'Location', icon: Icons.location_on, colorValue: 0xFFD84315),
    CategoryModel(id: 'sms', name: 'SMS', icon: Icons.sms, colorValue: 0xFF2E7D32),
  ];

  static List<CategoryModel> get socialMediaCategories =>
      builtInCategories.where((c) => ['whatsapp', 'facebook', 'instagram', 'linkedin'].contains(c.id)).toList();

  static List<CategoryModel> get utilityCategories =>
      builtInCategories.where((c) => !['whatsapp', 'facebook', 'instagram', 'linkedin'].contains(c.id)).toList();

  static const List<Color> qrColors = [
    Color(0xFF000000), Color(0xFF6C63FF), Color(0xFF33D951), Color(0xFF0F8FF2),
    Color(0xFFE73D5D), Color(0xFF2967B0), Color(0xFFE53935), Color(0xFFFB8C00),
    Color(0xFF43A047), Color(0xFF7B1FA2), Color(0xFF00BCD4), Color(0xFF795548),
    Color(0xFFFF6F00), Color(0xFFD50000), Color(0xFF6200EA), Color(0xFF0091EA),
  ];

  static const List<Color> gradientPresets = [
    Color(0xFF6C63FF), Color(0xFF00BFA6),
    Color(0xFFFF6B6B), Color(0xFF4ECDC4),
    Color(0xFFA8E063), Color(0xFF56AB2F),
    Color(0xFFF7797D), Color(0xFFFBD786),
    Color(0xFF667EEA), Color(0xFF764BA2),
    Color(0xFF1A2980), Color(0xFF26D0CE),
    Color(0xFFEB3349), Color(0xFFF45C43),
    Color(0xFF00B4DB), Color(0xFF0083B0),
  ];
}
