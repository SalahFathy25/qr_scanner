import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_studio/app/models/qr_code_model.dart';
import 'package:qr_studio/app/widgets/gradient_qr.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class QrViewDialog extends StatelessWidget {
  final QrCodeModel qrCode;
  final VoidCallback? onEdit;

  const QrViewDialog({super.key, required this.qrCode, this.onEdit});

  static Future<bool?> show(BuildContext context, QrCodeModel qrCode, {VoidCallback? onEdit}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => QrViewDialog(qrCode: qrCode, onEdit: onEdit),
    );
  }

  Color get _color => Color(qrCode.colorValue);

  String get _launchableData {
    return switch (qrCode.category) {
      'whatsapp' => 'https://wa.me/${qrCode.data}',
      'email' || 'sms' => qrCode.data,
      _ => qrCode.data.startsWith('http') ? qrCode.data : 'https://${qrCode.data}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final displayedData = _launchableData;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: _QrViewContent(
        qrCode: qrCode,
        color: _color,
        displayedData: displayedData,
      ),
    );
  }
}

class _QrViewContent extends StatefulWidget {
  const _QrViewContent({
    required this.qrCode,
    required this.color,
    required this.displayedData,
  });

  final QrCodeModel qrCode;
  final Color color;
  final String displayedData;

  @override
  State<_QrViewContent> createState() => _QrViewContentState();
}

class _QrViewContentState extends State<_QrViewContent> {
  final GlobalKey _repaintKey = GlobalKey();

  Future<void> _captureAndShare() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject();
      if (boundary == null || boundary is! RenderRepaintBoundary) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/qr_${widget.qrCode.id}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      await Share.shareXFiles(
        [XFile(file.path)],
        text: widget.qrCode.title,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Center(child: Text('Failed to share'))),
        );
      }
    }
  }

  Future<void> _captureAndSave() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject();
      if (boundary == null || boundary is! RenderRepaintBoundary) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/QR_${widget.qrCode.title}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Center(child: Text('Saved!'))),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Center(child: Text('Failed to save'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Column(
            children: [
              Text(
                widget.qrCode.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.color.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.qrCode.category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: RepaintBoundary(
            key: _repaintKey,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withAlpha(40),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: QrView(
                data: widget.displayedData,
                size: 220,
                color: widget.color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: () async {
                    final uri = Uri.tryParse(widget.displayedData);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  child: Text(
                    widget.displayedData,
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
                  Clipboard.setData(
                    ClipboardData(text: widget.displayedData),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Center(child: Text('Copied!'))),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  onTap: _captureAndShare,
                ),
                _ActionButton(
                  icon: Icons.open_in_new_rounded,
                  label: 'Open',
                  onTap: () async {
                    final uri = Uri.tryParse(widget.displayedData);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
                _ActionButton(
                  icon: Icons.save_alt_rounded,
                  label: 'Save',
                  onTap: _captureAndSave,
                ),
                _ActionButton(
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  onTap: () {
                    Navigator.pop(context, true);
                  },
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
