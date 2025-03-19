part of 'linkedin_qr_cubit.dart';

sealed class LinkedinQrState {}

final class LinkedinQrInitial extends LinkedinQrState {}

final class LinkedinQrSuccess extends LinkedinQrState {
  final List<QrCodeModel> qrCodes;
  LinkedinQrSuccess({required this.qrCodes});
}
