import 'package:bloc/bloc.dart';
import 'package:qr_code/app/models/qr_code_model.dart';

part 'whatsapp_qr_state.dart';


class WhatsappQrCubit extends Cubit<WhatsappQrState> {
  WhatsappQrCubit() : super(WhatsappQrInitial());

  void addQrCode(String title, String data) {
    final newQrCode = QrCodeModel(title: title, data: data );
    final currentQrCodes =
        state is WhatsappQrSuccess ? (state as WhatsappQrSuccess).qrCodes : [];
    emit(WhatsappQrSuccess(qrCodes: List.from(currentQrCodes)..add(newQrCode)));
  }

  void deleteQrCode(int index) {
    if (state is! WhatsappQrSuccess) return;

    final currentQrCodes = List<QrCodeModel>.from((state as WhatsappQrSuccess).qrCodes);
    if (index < 0 || index >= currentQrCodes.length) return;

    currentQrCodes.removeAt(index);
    emit(
      currentQrCodes.isEmpty
          ? WhatsappQrInitial()
          : WhatsappQrSuccess(qrCodes: List<QrCodeModel>.from(currentQrCodes)),
    );
  }

  void clearAllQrCodes() {
    emit(WhatsappQrInitial());
  }

  void updateQrCode(int index, String newTitle, String newData) {
    if (state is! WhatsappQrSuccess) return;

    final currentQrCodes = List<QrCodeModel>.from((state as WhatsappQrSuccess).qrCodes);
    if (index < 0 || index >= currentQrCodes.length) return;

    final updatedQrCode = currentQrCodes[index].copyWith(
      title: newTitle,
      data: newData,
    );
    currentQrCodes[index] = updatedQrCode;

    emit(WhatsappQrSuccess(qrCodes: List<QrCodeModel>.from(currentQrCodes)));
  }
}
