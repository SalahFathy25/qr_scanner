import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:qr_code/models/qr_code_model.dart';

part 'qr_state.dart';

class QrCubit extends Cubit<QrState> {
  QrCubit() : super(QrInitial());

  void addQrCode(String title, String data) {
    final newQrCode = QrCodeModel(title: title, data: data);
    final currentQrCodes =
        state is QrSuccess ? (state as QrSuccess).qrCodes : [];
    emit(QrSuccess(qrCodes: List.from(currentQrCodes)..add(newQrCode)));
  }

  void deleteQrCode(int index) {
    if (state is! QrSuccess) return;

    final currentQrCodes = List<QrCodeModel>.from((state as QrSuccess).qrCodes);
    if (index < 0 || index >= currentQrCodes.length) return;

    currentQrCodes.removeAt(index);
    emit(
      currentQrCodes.isEmpty
          ? QrInitial()
          : QrSuccess(qrCodes: List<QrCodeModel>.from(currentQrCodes)),
    );
  }

  void clearAllQrCodes() {
    emit(QrInitial());
  }

  void updateQrCode(int index, String newTitle, String newData) {
    if (state is! QrSuccess) return;

    final currentQrCodes = List<QrCodeModel>.from((state as QrSuccess).qrCodes);
    if (index < 0 || index >= currentQrCodes.length) return;

    final updatedQrCode = currentQrCodes[index].copyWith(
      title: newTitle,
      data: newData,
    );
    currentQrCodes[index] = updatedQrCode;

    emit(QrSuccess(qrCodes: List<QrCodeModel>.from(currentQrCodes)));
  }
}
