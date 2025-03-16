part of 'qr_cubit.dart';

@immutable
sealed class QrState {}

final class QrInitial extends QrState {}

final class QrSuccess extends QrState {
  final List<QrCodeModel> qrCodes;
  QrSuccess({required this.qrCodes});
}
