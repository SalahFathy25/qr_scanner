import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class ScanQrCode extends StatefulWidget {
  const ScanQrCode({super.key});

  @override
  State<ScanQrCode> createState() => _ScanQrCodeState();
}

class _ScanQrCodeState extends State<ScanQrCode> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Expanded(
              flex: 5,
              child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
            ),
            SizedBox(height: 40),
            Expanded(
              flex: 1,
              child: Center(
                child:
                    (result != null)
                        ? Text(
                          'Data: ${result!.code}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : Text(
                          'QR Content Here',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
