import 'package:bloc/bloc.dart';

import '../../models/qr_code_model.dart';

part 'instagram_qr_state.dart';

class InstagramQrCubit extends Cubit<InstagramQrState> {
  InstagramQrCubit() : super(InstagramQrInitial());

  void addQrCode(String title, String data) {
    final newQrCode = QrCodeModel(title: title, data: data);
    final currentQrCodes =
        state is InstagramQrSuccess
            ? (state as InstagramQrSuccess).qrCodes
            : [];
    emit(
      InstagramQrSuccess(qrCodes: List.from(currentQrCodes)..add(newQrCode)),
    );
  }

  void deleteQrCode(int index) {
    if (state is! InstagramQrSuccess) return;

    final currentQrCodes = List<QrCodeModel>.from(
      (state as InstagramQrSuccess).qrCodes,
    );
    if (index < 0 || index >= currentQrCodes.length) return;

    currentQrCodes.removeAt(index);
    emit(
      currentQrCodes.isEmpty
          ? InstagramQrInitial()
          : InstagramQrSuccess(qrCodes: List<QrCodeModel>.from(currentQrCodes)),
    );
  }

  void clearAllQrCodes() {
    emit(InstagramQrInitial());
  }

  void updateQrCode(int index, String newTitle, String newData) {
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

    emit(InstagramQrSuccess(qrCodes: List<QrCodeModel>.from(currentQrCodes)));
  }
}
