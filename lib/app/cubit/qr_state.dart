part of 'qr_cubit.dart';

abstract class QrState {}

class QrInitial extends QrState {}

class QrSuccess extends QrState {
  final Map<String, List<QrCodeModel>> qrCodesByScreen;
  QrSuccess({required this.qrCodesByScreen});
}
