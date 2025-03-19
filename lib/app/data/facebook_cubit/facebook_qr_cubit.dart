import 'package:bloc/bloc.dart';

import '../../models/qr_code_model.dart';

part 'facebook_qr_state.dart';

class FacebookQrCubit extends Cubit<FacebookQrState> {
  FacebookQrCubit() : super(FacebookQrInitial());

  void addQrCode(String title, String data) {
    final newQrCode = QrCodeModel(title: title, data: data);
    final currentQrCodes =
        state is FacebookQrSuccess ? (state as FacebookQrSuccess).qrCodes : [];
    emit(FacebookQrSuccess(qrCodes: List.from(currentQrCodes)..add(newQrCode)));
  }

  void deleteQrCode(int index) {
    if (state is! FacebookQrSuccess) return;

    final currentQrCodes = List<QrCodeModel>.from(
      (state as FacebookQrSuccess).qrCodes,
    );
    if (index < 0 || index >= currentQrCodes.length) return;

    currentQrCodes.removeAt(index);
    emit(
      currentQrCodes.isEmpty
          ? FacebookQrInitial()
          : FacebookQrSuccess(qrCodes: List<QrCodeModel>.from(currentQrCodes)),
    );
  }

  void clearAllQrCodes() {
    emit(FacebookQrInitial());
  }

  void updateQrCode(int index, String newTitle, String newData) {
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

    emit(FacebookQrSuccess(qrCodes: List<QrCodeModel>.from(currentQrCodes)));
  }
}
