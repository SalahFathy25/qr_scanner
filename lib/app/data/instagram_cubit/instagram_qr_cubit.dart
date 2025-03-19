import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/qr_code_model.dart';

part 'instagram_qr_state.dart';

class InstagramQrCubit extends Cubit<InstagramQrState> {
  static const String _qrCodesKey = 'qr_codes';

  InstagramQrCubit() : super(InstagramQrInitial()) {
    _loadQrCodes();
  }

  Future<void> _loadQrCodes() async {
    final prefs = await SharedPreferences.getInstance();
    final qrCodesJson = prefs.getStringList(_qrCodesKey) ?? [];

    final qrCodes =
        qrCodesJson
            .map((json) => QrCodeModel.fromJson(jsonDecode(json)))
            .toList();

    if (qrCodes.isNotEmpty) {
      emit(InstagramQrSuccess(qrCodes: qrCodes));
    }
  }

  Future<void> addQrCode(String title, String data) async {
    final newQrCode = QrCodeModel(title: title, data: data);
    final currentQrCodes =
        state is InstagramQrSuccess
            ? (state as InstagramQrSuccess).qrCodes
            : [];

    final updatedQrCodes = List<QrCodeModel>.from(currentQrCodes)
      ..add(newQrCode);
    await _saveQrCodes(updatedQrCodes);
    emit(InstagramQrSuccess(qrCodes: updatedQrCodes));
  }

  Future<void> deleteQrCode(int index) async {
    if (state is! InstagramQrSuccess) return;

    final currentQrCodes = List<QrCodeModel>.from(
      (state as InstagramQrSuccess).qrCodes,
    );
    if (index < 0 || index >= currentQrCodes.length) return;

    currentQrCodes.removeAt(index);
    await _saveQrCodes(currentQrCodes);

    emit(
      currentQrCodes.isEmpty
          ? InstagramQrInitial()
          : InstagramQrSuccess(qrCodes: currentQrCodes),
    );
  }

  Future<void> clearAllQrCodes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_qrCodesKey);
    emit(InstagramQrInitial());
  }

  Future<void> updateQrCode(int index, String newTitle, String newData) async {
    if (state is! InstagramQrSuccess) return;

    final currentQrCodes = List<QrCodeModel>.from(
      (state as InstagramQrSuccess).qrCodes,
    );
    if (index < 0 || index >= currentQrCodes.length) return;

    final updatedQrCode = currentQrCodes[index].copyWith(
      title: newTitle,
      data: newData,
    );
    currentQrCodes[index] = updatedQrCode;

    await _saveQrCodes(currentQrCodes);
    emit(InstagramQrSuccess(qrCodes: currentQrCodes));
  }

  Future<void> _saveQrCodes(List<QrCodeModel> qrCodes) async {
    final prefs = await SharedPreferences.getInstance();
    final qrCodesJson = qrCodes.map((qr) => jsonEncode(qr.toJson())).toList();
    await prefs.setStringList(_qrCodesKey, qrCodesJson);
  }
}
