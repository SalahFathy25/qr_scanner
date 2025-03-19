import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanQrCode extends StatefulWidget {
  const ScanQrCode({super.key});

  @override
  State<ScanQrCode> createState() => _ScanQrCodeState();
}

class _ScanQrCodeState extends State<ScanQrCode> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isDialogOpen = false;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      if (Platform.isAndroid) {
        controller!.pauseCamera();
      } else if (Platform.isIOS) {
        controller!.resumeCamera();
      }
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!isDialogOpen && (result == null || result!.code != scanData.code)) {
        setState(() {
          result = scanData;
        });

        String qrCode = scanData.code!;
        Uri? qrUri = Uri.tryParse(qrCode);

        if (qrUri != null && (qrUri.scheme == 'http' || qrUri.scheme == 'https')) {
          // If valid URL, launch immediately
          if (await canLaunchUrl(qrUri)) {
            await launchUrl(qrUri);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Center(child: Text("Could not open link"))),
            );
          }
        } else {
          // If not a URL, show QR dialog
          _showQRDialog(qrCode);
        }
      }
    });
  }

  Future<void> _showQRDialog(String qrCode) async {
    setState(() => isDialogOpen = true);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("QR Code Scanned", textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      qrCode,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 15, color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.grey),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: qrCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Center(child: Text("Copied to clipboard"))),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              QrImageView(
                foregroundColor: Colors.black,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle),
                data: qrCode,
                version: QrVersions.auto,
                size: 200,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => isDialogOpen = false);
                controller?.resumeCamera();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Scan a QR code',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
