import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:qr_code/app/models/qr_code_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'whatsapp_qr_state.dart';

class WhatsappQrCubit extends Cubit<WhatsappQrState> {
  static const String _qrCodesKey = 'whatsapp_qr_codes';

  WhatsappQrCubit() : super(WhatsappQrInitial()) {
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
      emit(WhatsappQrSuccess(qrCodes: qrCodes));
    }
  }

  Future<void> addQrCode(String title, String data) async {
    final newQrCode = QrCodeModel(title: title, data: data);
    final currentQrCodes =
        state is WhatsappQrSuccess ? (state as WhatsappQrSuccess).qrCodes : [];

    final updatedQrCodes = List<QrCodeModel>.from(currentQrCodes)
      ..add(newQrCode);
    await _saveQrCodes(updatedQrCodes);
    emit(WhatsappQrSuccess(qrCodes: updatedQrCodes));
  }

  Future<void> deleteQrCode(int index) async {
    if (state is! WhatsappQrSuccess) return;

    final currentQrCodes = List<QrCodeModel>.from(
      (state as WhatsappQrSuccess).qrCodes,
    );
    if (index < 0 || index >= currentQrCodes.length) return;

    currentQrCodes.removeAt(index);
    await _saveQrCodes(currentQrCodes);

    emit(
      currentQrCodes.isEmpty
          ? WhatsappQrInitial()
          : WhatsappQrSuccess(qrCodes: currentQrCodes),
    );
  }

  Future<void> clearAllQrCodes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_qrCodesKey);
    emit(WhatsappQrInitial());
  }

  Future<void> updateQrCode(int index, String newTitle, String newData) async {
    if (state is! WhatsappQrSuccess) return;

    final currentQrCodes = List<QrCodeModel>.from(
      (state as WhatsappQrSuccess).qrCodes,
    );
    if (index < 0 || index >= currentQrCodes.length) return;

    final updatedQrCode = currentQrCodes[index].copyWith(
      title: newTitle,
      data: newData,
    );
    currentQrCodes[index] = updatedQrCode;

    await _saveQrCodes(currentQrCodes);
    emit(WhatsappQrSuccess(qrCodes: currentQrCodes));
  }

  Future<void> _saveQrCodes(List<QrCodeModel> qrCodes) async {
    final prefs = await SharedPreferences.getInstance();
    final qrCodesJson = qrCodes.map((qr) => jsonEncode(qr.toJson())).toList();
    await prefs.setStringList(_qrCodesKey, qrCodesJson);
  }
}
