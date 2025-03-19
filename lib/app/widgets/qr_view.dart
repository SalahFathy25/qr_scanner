import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code/app/models/qr_code_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

Future<dynamic> qrView(
  BuildContext context,
  QrCodeModel qrCode,
  Color qrColor,
  bool isWhatsapp,
) {
  final String displayedLink =
      isWhatsapp ? 'https://wa.me/${qrCode.data}' : qrCode.data;

  return showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Column(
            children: [
              Text(qrCode.title, textAlign: TextAlign.center),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (await canLaunch(displayedLink)) {
                        await launchUrl(Uri.parse(displayedLink));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open link')),
                        );
                      }
                    },
                    child: Text(
                      displayedLink,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.grey),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: displayedLink));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: QrImageView(
                foregroundColor: qrColor,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle),
                data: displayedLink,
                version: QrVersions.auto,
                size: MediaQuery.of(context).size.width * 0.6,
              ),
            ),
          ),
        ),
  );
}
