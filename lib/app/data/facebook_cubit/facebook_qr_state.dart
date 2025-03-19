part of 'facebook_qr_cubit.dart';

sealed class FacebookQrState {}

final class FacebookQrInitial extends FacebookQrState {}

final class FacebookQrSuccess extends FacebookQrState {
  final List<QrCodeModel> qrCodes;
  FacebookQrSuccess({required this.qrCodes});
}
