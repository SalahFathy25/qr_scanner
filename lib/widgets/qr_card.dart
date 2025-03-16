import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code/cubit/qr_cubit.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/qr_code_model.dart';
import 'qr_view.dart';

Widget qrCard({
  required QrCodeModel qrCode,
  required int index,
  required BuildContext context,
  required Function({String? existingTitle, String? existingData, int? index})
  qrBottomSheet,
  required String image,
}) {
  return Dismissible(
    key: UniqueKey(),
    onDismissed: (_) {
      context.read<QrCubit>().deleteQrCode(index);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('QR code deleted')));
    },
    background: Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: ListTile(
          minTileHeight: 80,
          leading: Image.asset(image, width: 50),
          title: Text(qrCode.title),
          subtitle: Text(qrCode.data),
          trailing: QrImageView(
            foregroundColor: Colors.green,
            eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.circle),
            data: qrCode.data,
            version: QrVersions.auto,
            size: 55,
          ),
          onLongPress: () {
            qrBottomSheet(
              existingTitle: qrCode.title,
              existingData: qrCode.data,
              index: index,
            );
          },
          onTap: () async {
            final Uri whatsappLink = Uri.parse('https://wa.me/${qrCode.data}}');
            qrView(context, qrCode, whatsappLink);
          },
        ),
      ),
    ),
  );
}
