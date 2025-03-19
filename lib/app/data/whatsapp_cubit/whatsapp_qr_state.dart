part of 'whatsapp_qr_cubit.dart';

sealed class WhatsappQrState {}

final class WhatsappQrInitial extends WhatsappQrState {}

final class WhatsappQrSuccess extends WhatsappQrState {
  final List<QrCodeModel> qrCodes;
  WhatsappQrSuccess({required this.qrCodes});
}
