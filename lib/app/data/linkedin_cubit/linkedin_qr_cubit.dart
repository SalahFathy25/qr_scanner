import 'package:bloc/bloc.dart';

import '../../models/qr_code_model.dart';

part 'linkedin_qr_state.dart';

class LinkedinQrCubit extends Cubit<LinkedinQrState> {
  LinkedinQrCubit() : super(LinkedinQrInitial());

  void addQrCode(String title, String data) {
    final newQrCode = QrCodeModel(title: title, data: data);
    final currentQrCodes =
        state is LinkedinQrSuccess ? (state as LinkedinQrSuccess).qrCodes : [];
    emit(LinkedinQrSuccess(qrCodes: List.from(currentQrCodes)..add(newQrCode)));
  }

  void deleteQrCode(int index) {
    if (state is! LinkedinQrSuccess) return;

    final currentQrCodes = List<QrCodeModel>.from(
      (state as LinkedinQrSuccess).qrCodes,
    );
    if (index < 0 || index >= currentQrCodes.length) return;

    currentQrCodes.removeAt(index);
    emit(
      currentQrCodes.isEmpty
          ? LinkedinQrInitial()
          : LinkedinQrSuccess(qrCodes: List<QrCodeModel>.from(currentQrCodes)),
    );
  }

  void clearAllQrCodes() {
    emit(LinkedinQrInitial());
  }

  void updateQrCode(int index, String newTitle, String newData) {
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

    emit(LinkedinQrSuccess(qrCodes: List<QrCodeModel>.from(currentQrCodes)));
  }
}
