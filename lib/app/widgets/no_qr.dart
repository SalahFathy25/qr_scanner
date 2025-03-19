import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Widget noQr() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/qr_scanner.json', height: 220),
          const SizedBox(height: 20),
          Text(
            'No QR codes found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap the plus button to add a QR code.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    ),
  );
}
