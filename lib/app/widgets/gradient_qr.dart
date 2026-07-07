import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrView extends StatelessWidget {
  final String data;
  final double size;
  final Color color;

  const QrView({
    super.key,
    required this.data,
    this.size = 200,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      foregroundColor: color,
      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square),
    );
  }
}
