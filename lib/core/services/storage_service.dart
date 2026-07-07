import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_studio/app/models/category_model.dart';
import 'package:qr_studio/app/models/qr_code_model.dart';
import 'package:qr_studio/core/constants/app_constants.dart';

class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  // QR Codes
  Future<List<QrCodeModel>> loadQrCodes() async {
    final jsonList = _prefs.getStringList(AppConstants.storageKey) ?? [];
    return jsonList
        .map((j) => QrCodeModel.fromJson(jsonDecode(j)))
        .toList();
  }

  Future<void> saveQrCodes(List<QrCodeModel> codes) async {
    final jsonList = codes.map((qr) => jsonEncode(qr.toJson())).toList();
    await _prefs.setStringList(AppConstants.storageKey, jsonList);
  }

  // Scan History
  Future<List<QrCodeModel>> loadScanHistory() async {
    final jsonList = _prefs.getStringList(AppConstants.scanHistoryKey) ?? [];
    return jsonList
        .map((j) => QrCodeModel.fromJson(jsonDecode(j)))
        .toList();
  }

  Future<void> saveScanHistory(List<QrCodeModel> scans) async {
    final jsonList = scans.map((s) => jsonEncode(s.toJson())).toList();
    await _prefs.setStringList(AppConstants.scanHistoryKey, jsonList);
  }

  // Custom Categories
  Future<List<CategoryModel>> loadCustomCategories() async {
    final jsonList =
        _prefs.getStringList(AppConstants.customCategoriesKey) ?? [];
    return jsonList
        .map((j) => CategoryModel.fromJson(jsonDecode(j)))
        .toList();
  }

  Future<void> saveCustomCategories(List<CategoryModel> categories) async {
    final jsonList =
        categories.map((c) => jsonEncode(c.toJson())).toList();
    await _prefs.setStringList(AppConstants.customCategoriesKey, jsonList);
  }

  // Generic typed access
  bool getBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  int getInt(String key, {int defaultValue = 0}) =>
      _prefs.getInt(key) ?? defaultValue;

  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  List<String>? getStringList(String key) => _prefs.getStringList(key);

  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  Future<void> remove(String key) => _prefs.remove(key);
}
