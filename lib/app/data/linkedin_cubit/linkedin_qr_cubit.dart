import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/qr_code_model.dart';

part 'linkedin_qr_state.dart';

class LinkedinQrCubit extends Cubit<LinkedinQrState> {
  static const String _qrCodesKey = 'qr_codes';

  LinkedinQrCubit() : super(LinkedinQrInitial()) {
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
      emit(LinkedinQrSuccess(qrCodes: qrCodes));
    }
  }

  Future<void> addQrCode(String title, String data) async {
    final newQrCode = QrCodeModel(title: title, data: data);
    final currentQrCodes =
        state is LinkedinQrSuccess ? (state as LinkedinQrSuccess).qrCodes : [];

    final updatedQrCodes = List<QrCodeModel>.from(currentQrCodes)
      ..add(newQrCode);
    await _saveQrCodes(updatedQrCodes);
    emit(LinkedinQrSuccess(qrCodes: updatedQrCodes));
  }

  Future<void> deleteQrCode(int index) async {
    if (state is! LinkedinQrSuccess) return;

    final currentQrCodes = List<QrCodeModel>.from(
      (state as LinkedinQrSuccess).qrCodes,
    );
    if (index < 0 || index >= currentQrCodes.length) return;

    currentQrCodes.removeAt(index);
    await _saveQrCodes(currentQrCodes);

    emit(
      currentQrCodes.isEmpty
          ? LinkedinQrInitial()
          : LinkedinQrSuccess(qrCodes: currentQrCodes),
    );
  }

  Future<void> clearAllQrCodes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_qrCodesKey);
    emit(LinkedinQrInitial());
  }

  Future<void> updateQrCode(int index, String newTitle, String newData) async {
    if (state is! LinkedinQrSuccess) return;

    final currentQrCodes = List<QrCodeModel>.from(
      (state as LinkedinQrSuccess).qrCodes,
    );
    if (index < 0 || index >= currentQrCodes.length) return;

    final updatedQrCode = currentQrCodes[index].copyWith(
      title: newTitle,
      data: newData,
    );
    currentQrCodes[index] = updatedQrCode;

    await _saveQrCodes(currentQrCodes);
    emit(LinkedinQrSuccess(qrCodes: currentQrCodes));
  }

  Future<void> _saveQrCodes(List<QrCodeModel> qrCodes) async {
    final prefs = await SharedPreferences.getInstance();
    final qrCodesJson = qrCodes.map((qr) => jsonEncode(qr.toJson())).toList();
    await prefs.setStringList(_qrCodesKey, qrCodesJson);
  }
}
