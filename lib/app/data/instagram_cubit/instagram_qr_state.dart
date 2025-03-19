part of 'instagram_qr_cubit.dart';

sealed class InstagramQrState {}

final class InstagramQrInitial extends InstagramQrState {}

final class InstagramQrSuccess extends InstagramQrState {
  final List<QrCodeModel> qrCodes;
  InstagramQrSuccess({required this.qrCodes});
}
