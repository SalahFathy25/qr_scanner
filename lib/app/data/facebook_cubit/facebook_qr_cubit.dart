import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/qr_code_model.dart';

part 'facebook_qr_state.dart';

class FacebookQrCubit extends Cubit<FacebookQrState> {
  static const String _qrCodesKey = 'qr_codes';

  FacebookQrCubit() : super(FacebookQrInitial()) {
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
      emit(FacebookQrSuccess(qrCodes: qrCodes));
    }
  }

  Future<void> addQrCode(String title, String data) async {
    final newQrCode = QrCodeModel(title: title, data: data);
    final currentQrCodes =
        state is FacebookQrSuccess ? (state as FacebookQrSuccess).qrCodes : [];

    final updatedQrCodes = List<QrCodeModel>.from(currentQrCodes)
      ..add(newQrCode);
    await _saveQrCodes(updatedQrCodes);
    emit(FacebookQrSuccess(qrCodes: updatedQrCodes));
  }

  Future<void> deleteQrCode(int index) async {
    if (state is! FacebookQrSuccess) return;

    final currentQrCodes = List<QrCodeModel>.from(
      (state as FacebookQrSuccess).qrCodes,
    );
    if (index < 0 || index >= currentQrCodes.length) return;

    currentQrCodes.removeAt(index);
    await _saveQrCodes(currentQrCodes);

    emit(
      currentQrCodes.isEmpty
          ? FacebookQrInitial()
          : FacebookQrSuccess(qrCodes: currentQrCodes),
    );
  }

  Future<void> clearAllQrCodes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_qrCodesKey);
    emit(FacebookQrInitial());
  }

  Future<void> updateQrCode(int index, String newTitle, String newData) async {
    if (state is! FacebookQrSuccess) return;

    final currentQrCodes = List<QrCodeModel>.from(
      (state as FacebookQrSuccess).qrCodes,
    );
    if (index < 0 || index >= currentQrCodes.length) return;

    final updatedQrCode = currentQrCodes[index].copyWith(
      title: newTitle,
      data: newData,
    );
    currentQrCodes[index] = updatedQrCode;

    await _saveQrCodes(currentQrCodes);
    emit(FacebookQrSuccess(qrCodes: currentQrCodes));
  }

  Future<void> _saveQrCodes(List<QrCodeModel> qrCodes) async {
    final prefs = await SharedPreferences.getInstance();
    final qrCodesJson = qrCodes.map((qr) => jsonEncode(qr.toJson())).toList();
    await prefs.setStringList(_qrCodesKey, qrCodesJson);
  }
}
