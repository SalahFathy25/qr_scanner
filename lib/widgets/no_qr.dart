import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Widget noQr() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/lottie/qr_scanner.json', height: 200),
        const Text(
          'No QR codes found. Tap the plus button to add a QR code.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
