import 'package:qr_code/app/models/qr_code_model.dart';

sealed class QrState {}

final class QrInitial extends QrState {}

final class QrLoading extends QrState {}

final class QrSuccess extends QrState {
  final List<QrCodeModel> qrCodes;
  QrSuccess({required this.qrCodes});
}

final class QrError extends QrState {
  final String message;
  QrError({required this.message});
}
