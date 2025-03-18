import 'package:bloc/bloc.dart';
import 'package:qr_code/app/models/qr_code_model.dart';

part 'qr_state.dart';

class QrCubit extends Cubit<QrState> {
  QrCubit() : super(QrInitial());

  final Map<String, List<QrCodeModel>> _qrCodesByScreen = {};

  void addQrCode(String screen, String title, String data) {
    final newQrCode = QrCodeModel(title: title, data: data);
    _qrCodesByScreen.putIfAbsent(screen, () => []);
    _qrCodesByScreen[screen]!.add(newQrCode);
    emit(QrSuccess(qrCodesByScreen: Map.from(_qrCodesByScreen)));
  }

  void deleteQrCode(String screen, int index) {
    if (!_qrCodesByScreen.containsKey(screen)) return;

    final qrCodes = _qrCodesByScreen[screen]!;
    if (index < 0 || index >= qrCodes.length) return;

    qrCodes.removeAt(index);
    if (qrCodes.isEmpty) {
      _qrCodesByScreen.remove(screen);
      emit(QrInitial());
    } else {
      emit(QrSuccess(qrCodesByScreen: Map.from(_qrCodesByScreen)));
    }
  }

  void clearQrCodesForScreen(String screen) {
    _qrCodesByScreen.remove(screen);
    emit(_qrCodesByScreen.isEmpty ? QrInitial() : QrSuccess(qrCodesByScreen: Map.from(_qrCodesByScreen)));
  }

  void updateQrCode(String screen, int index, String newTitle, String newData) {
    if (!_qrCodesByScreen.containsKey(screen)) return;

    final qrCodes = _qrCodesByScreen[screen]!;
    if (index < 0 || index >= qrCodes.length) return;

    qrCodes[index] = qrCodes[index].copyWith(title: newTitle, data: newData);
    emit(QrSuccess(qrCodesByScreen: Map.from(_qrCodesByScreen)));
  }
}
