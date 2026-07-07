import 'dart:convert';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:qr_studio/app/models/qr_code_model.dart';
import 'package:qr_studio/core/services/storage_service.dart';
import 'qr_state.dart';

class QrCubit extends Cubit<QrState> {
  QrCubit(this._storage) : super(QrInitial()) {
    _loadQrCodes();
  }

  final StorageService _storage;

  Future<void> _loadQrCodes() async {
    emit(QrLoading());
    try {
      await _migrateOldData();
      final qrCodes = await _storage.loadQrCodes();
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
      final currentCodes = switch (state) {
        QrSuccess(:final qrCodes) => qrCodes,
        _ => <QrCodeModel>[],
      };

      final newQr = QrCodeModel(
        id: _generateId(),
        title: title,
        data: data,
        category: category,
        colorValue: colorValue,
      );

      final updated = [newQr, ...currentCodes];
      await _storage.saveQrCodes(updated);
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
      if (state case QrSuccess(:final qrCodes)) {
        final currentCodes = List<QrCodeModel>.from(qrCodes);
        final index = currentCodes.indexWhere((q) => q.id == id);
        if (index == -1) return;

        currentCodes[index] = currentCodes[index].copyWith(
          title: title,
          data: data,
          category: category,
          isFavorite: isFavorite,
          colorValue: colorValue,
        );
        await _storage.saveQrCodes(currentCodes);
        emit(QrSuccess(qrCodes: currentCodes));
      }
    } catch (e) {
      emit(QrError(message: 'Failed to update QR code: $e'));
    }
  }

  Future<void> deleteQrCode(String id) async {
    try {
      if (state case QrSuccess(:final qrCodes)) {
        final currentCodes = List<QrCodeModel>.from(qrCodes);
        currentCodes.removeWhere((q) => q.id == id);
        await _storage.saveQrCodes(currentCodes);
        emit(QrSuccess(qrCodes: currentCodes));
      }
    } catch (e) {
      emit(QrError(message: 'Failed to delete QR code: $e'));
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      if (state case QrSuccess(:final qrCodes)) {
        final currentCodes = List<QrCodeModel>.from(qrCodes);
        final index = currentCodes.indexWhere((q) => q.id == id);
        if (index == -1) return;

        currentCodes[index] = currentCodes[index].copyWith(
          isFavorite: !currentCodes[index].isFavorite,
        );
        await _storage.saveQrCodes(currentCodes);
        emit(QrSuccess(qrCodes: currentCodes));
      }
    } catch (e) {
      emit(QrError(message: 'Failed to toggle favorite: $e'));
    }
  }

  List<QrCodeModel> getQrCodesByCategory(String category) {
    if (state case QrSuccess(:final qrCodes)) {
      return qrCodes.where((q) => q.category == category).toList();
    }
    return [];
  }

  List<QrCodeModel> searchQrCodes(String query) {
    if (state case QrSuccess(:final qrCodes)) {
      if (query.isEmpty) return qrCodes;
      final lowerQuery = query.toLowerCase();
      return qrCodes.where(
        (q) =>
            q.title.toLowerCase().contains(lowerQuery) ||
            q.data.toLowerCase().contains(lowerQuery),
      ).toList();
    }
    return [];
  }

  List<QrCodeModel> get favoriteQrCodes {
    if (state case QrSuccess(:final qrCodes)) {
      return qrCodes.where((q) => q.isFavorite).toList();
    }
    return [];
  }

  Future<void> clearAllQrCodes() async {
    try {
      await _storage.saveQrCodes([]);
      emit(QrSuccess(qrCodes: []));
    } catch (e) {
      emit(QrError(message: 'Failed to clear QR codes: $e'));
    }
  }

  Future<void> _migrateOldData() async {
    try {
      final hasMigrated = _storage.getBool('data_migrated');
      if (hasMigrated) return;

      final oldKeys = {
        'whatsapp': 'whatsapp_qr_codes',
        'facebook': 'facebook_qr_codes',
        'instagram': 'instagram_qr_codes',
        'linkedin': 'linked_in_qr_codes',
      };

      final allOldCodes = <QrCodeModel>[];
      for (final entry in oldKeys.entries) {
        final oldJsonList = _storage.getStringList(entry.value) ?? [];
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
        await _storage.remove(entry.value);
      }

      if (allOldCodes.isNotEmpty) {
        final existingCodes = await _storage.loadQrCodes();
        final merged = [...existingCodes, ...allOldCodes];
        await _storage.saveQrCodes(merged);
      }

      await _storage.setBool('data_migrated', true);
    } catch (_) {}
  }
}
