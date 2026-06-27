import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_code/app/models/qr_code_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> qrView(
  BuildContext context,
  QrCodeModel qrCode,
) async {
  final color = Color(qrCode.colorValue);
  final GlobalKey repaintKey = GlobalKey();

  String getLaunchableData() {
    switch (qrCode.category) {
      case 'whatsapp':
        return 'https://wa.me/${qrCode.data}';
      case 'email':
        return 'mailto:${qrCode.data}';
      default:
        return qrCode.data.startsWith('http') ? qrCode.data : 'https://${qrCode.data}';
    }
  }

  String displayedData = getLaunchableData();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Column(
        children: [
          Text(qrCode.title, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              qrCode.category.toUpperCase(),
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            key: repaintKey,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(40),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: QrImageView(
                foregroundColor: color,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                ),
                data: displayedData,
                version: QrVersions.auto,
                size: 220,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: () async {
                    final uri = Uri.tryParse(displayedData);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  child: Text(
                    displayedData,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: Colors.grey),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: displayedData));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Center(child: Text('Copied!'))),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: () async {
                  try {
                    final boundary = repaintKey.currentContext?.findRenderObject();
                    if (boundary == null || boundary is! RenderRepaintBoundary) return;
                    final image = await boundary.toImage(pixelRatio: 3);
                    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                    if (byteData == null) return;
                    final dir = await getTemporaryDirectory();
                    final file = File('${dir.path}/qr_${qrCode.id}.png');
                    await file.writeAsBytes(byteData.buffer.asUint8List());
                    await Share.shareXFiles(
                      [XFile(file.path)],
                      text: qrCode.title,
                    );
                  } catch (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Center(child: Text('Failed to share'))),
                    );
                  }
                },
              ),
              _actionButton(
                icon: Icons.open_in_new_rounded,
                label: 'Open',
                onTap: () async {
                  final uri = Uri.tryParse(displayedData);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Widget _actionButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        ],
      ),
    ),
  );
}
