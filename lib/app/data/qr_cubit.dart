import 'dart:convert';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:qr_code/app/models/qr_code_model.dart';
import 'package:qr_code/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'qr_state.dart';

class QrCubit extends Cubit<QrState> {
  QrCubit() : super(QrInitial()) {
    _loadQrCodes();
  }

  Future<void> _loadQrCodes() async {
    emit(QrLoading());
    try {
      await _migrateOldData();
      final prefs = await SharedPreferences.getInstance();
      final qrCodesJson = prefs.getStringList(AppConstants.storageKey) ?? [];
      final qrCodes = qrCodesJson
          .map((json) => QrCodeModel.fromJson(jsonDecode(json)))
          .toList();
      emit(QrSuccess(qrCodes: qrCodes));
    } catch (e) {
      emit(QrError(message: 'Failed to load QR codes: $e'));
    }
  }

  String _generateId() {
    final random = Random();
    return '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(999999)}';
  }

  Future<void> addQrCode({
    required String title,
    required String data,
    required String category,
    int colorValue = 0xFF000000,
  }) async {
    try {
      final currentState = state;
      final currentCodes =
          currentState is QrSuccess ? currentState.qrCodes : <QrCodeModel>[];

      final newQr = QrCodeModel(
        id: _generateId(),
        title: title,
        data: data,
        category: category,
        colorValue: colorValue,
      );

      final updated = List<QrCodeModel>.from(currentCodes)..add(newQr);
      await _saveQrCodes(updated);
      emit(QrSuccess(qrCodes: updated));
    } catch (e) {
      emit(QrError(message: 'Failed to add QR code: $e'));
    }
  }

  Future<void> updateQrCode({
    required String id,
    String? title,
    String? data,
    String? category,
    bool? isFavorite,
    int? colorValue,
  }) async {
    try {
      if (state is! QrSuccess) return;
      final currentCodes = List<QrCodeModel>.from(
        (state as QrSuccess).qrCodes,
      );
      final index = currentCodes.indexWhere((q) => q.id == id);
      if (index == -1) return;

      final updated = currentCodes[index].copyWith(
        title: title,
        data: data,
        category: category,
        isFavorite: isFavorite,
        colorValue: colorValue,
      );
      currentCodes[index] = updated;
      await _saveQrCodes(currentCodes);
      emit(QrSuccess(qrCodes: currentCodes));
    } catch (e) {
      emit(QrError(message: 'Failed to update QR code: $e'));
    }
  }

  Future<void> deleteQrCode(String id) async {
    try {
      if (state is! QrSuccess) return;
      final currentCodes = List<QrCodeModel>.from(
        (state as QrSuccess).qrCodes,
      );
      currentCodes.removeWhere((q) => q.id == id);
      await _saveQrCodes(currentCodes);
      emit(QrSuccess(qrCodes: currentCodes));
    } catch (e) {
      emit(QrError(message: 'Failed to delete QR code: $e'));
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      if (state is! QrSuccess) return;
      final currentCodes = List<QrCodeModel>.from(
        (state as QrSuccess).qrCodes,
      );
      final index = currentCodes.indexWhere((q) => q.id == id);
      if (index == -1) return;

      currentCodes[index] = currentCodes[index].copyWith(
        isFavorite: !currentCodes[index].isFavorite,
      );
      await _saveQrCodes(currentCodes);
      emit(QrSuccess(qrCodes: currentCodes));
    } catch (e) {
      emit(QrError(message: 'Failed to toggle favorite: $e'));
    }
  }

  List<QrCodeModel> getQrCodesByCategory(String category) {
    if (state is! QrSuccess) return [];
    return (state as QrSuccess)
        .qrCodes
        .where((q) => q.category == category)
        .toList();
  }

  List<QrCodeModel> searchQrCodes(String query) {
    if (state is! QrSuccess) return [];
    if (query.isEmpty) return (state as QrSuccess).qrCodes;
    final lowerQuery = query.toLowerCase();
    return (state as QrSuccess)
        .qrCodes
        .where(
          (q) =>
              q.title.toLowerCase().contains(lowerQuery) ||
              q.data.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  List<QrCodeModel> get favoriteQrCodes {
    if (state is! QrSuccess) return [];
    return (state as QrSuccess).qrCodes.where((q) => q.isFavorite).toList();
  }

  Future<void> clearAllQrCodes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.storageKey);
      emit(QrSuccess(qrCodes: []));
    } catch (e) {
      emit(QrError(message: 'Failed to clear QR codes: $e'));
    }
  }

  Future<void> _saveQrCodes(List<QrCodeModel> qrCodes) async {
    final prefs = await SharedPreferences.getInstance();
    final qrCodesJson = qrCodes.map((qr) => jsonEncode(qr.toJson())).toList();
    await prefs.setStringList(AppConstants.storageKey, qrCodesJson);
  }

  Future<void> _migrateOldData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasMigrated = prefs.getBool('data_migrated') ?? false;
      if (hasMigrated) return;

      final oldKeys = {
        'whatsapp': 'whatsapp_qr_codes',
        'facebook': 'facebook_qr_codes',
        'instagram': 'instagram_qr_codes',
        'linkedin': 'linked_in_qr_codes',
      };

      final allOldCodes = <QrCodeModel>[];

      for (final entry in oldKeys.entries) {
        final oldJsonList = prefs.getStringList(entry.value) ?? [];
        for (final jsonStr in oldJsonList) {
          try {
            final oldModel = QrCodeModel.fromJson(jsonDecode(jsonStr));
            allOldCodes.add(
              QrCodeModel(
                id: _generateId(),
                title: oldModel.title,
                data: oldModel.data,
                category: entry.key,
              ),
            );
          } catch (_) {}
        }
        prefs.remove(entry.value);
      }

      if (allOldCodes.isNotEmpty) {
        final existingJson = prefs.getStringList(AppConstants.storageKey) ?? [];
        final existingCodes = existingJson
            .map((j) => QrCodeModel.fromJson(jsonDecode(j)))
            .toList();
        final merged = [...existingCodes, ...allOldCodes];
        final mergedJson =
            merged.map((qr) => jsonEncode(qr.toJson())).toList();
        await prefs.setStringList(AppConstants.storageKey, mergedJson);
      }

      await prefs.setBool('data_migrated', true);
    } catch (_) {}
  }
}
