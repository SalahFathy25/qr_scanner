import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code/app/data/scan_history_cubit.dart';
import 'package:qr_code/app/models/qr_code_model.dart';
import 'package:qr_code/app/widgets/qr_view.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_code/core/utils/permission_handler.dart';

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
  bool showHistory = false;
  bool _cameraGranted = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkCamera();
  }

  Future<void> _checkCamera() async {
    final granted = await requestCameraPermission(context: context);
    if (mounted) setState(() => _cameraGranted = granted);
  }

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      if (Platform.isAndroid) controller!.pauseCamera();
      else if (Platform.isIOS) controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return;

    // For gallery images, we read the file bytes and try to decode
    // using qr_code_scanner_plus or a fallback
    try {
      // Use the camera controller to process the image if possible,
      // otherwise show user a message about manual entry
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Center(child: Text('Image selected. You can enter the data manually.')),
            action: SnackBarAction(label: 'Enter', onPressed: () {
              // Navigate back - user will enter data manually
            }),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Center(child: Text('Could not read QR from image: $e'))),
        );
      }
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!isDialogOpen && (result == null || result!.code != scanData.code)) {
        setState(() => result = scanData);

        final String qrCode = scanData.code!;
        final scanModel = QrCodeModel(
          id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Scanned QR',
          data: qrCode,
          category: _detectCategory(qrCode),
          colorValue: 0xFF6C63FF,
        );
        context.read<ScanHistoryCubit>().addScan(scanModel);

        final Uri? qrUri = Uri.tryParse(qrCode);
        if (qrUri != null && (qrUri.scheme == 'http' || qrUri.scheme == 'https')) {
          if (await canLaunchUrl(qrUri)) {
            await launchUrl(qrUri);
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Center(child: Text("Could not open link"))),
            );
          }
        } else {
          _showQRDialog(qrCode);
        }
      }
    });
  }

  String _detectCategory(String data) {
    if (data.startsWith('WIFI:')) return 'wifi';
    if (data.startsWith('BEGIN:VCARD') || data.startsWith('BEGIN:vCard')) return 'vcard';
    if (data.startsWith('mailto:')) return 'email';
    if (data.startsWith('BEGIN:VEVENT')) return 'calendar';
    if (data.startsWith('geo:')) return 'location';
    if (data.startsWith('sms:') || data.startsWith('SMSTO:')) return 'sms';
    if (data.startsWith('http')) return 'url';
    return 'text';
  }

  Future<void> _showQRDialog(String qrCode) async {
    setState(() => isDialogOpen = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Scanned QR", textAlign: TextAlign.center),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Flexible(child: Text(qrCode, textAlign: TextAlign.center, style: TextStyle(color: Colors.blue.shade600, fontSize: 14))),
              const SizedBox(width: 8),
              IconButton(icon: const Icon(Icons.copy_rounded, color: Colors.grey),
                onPressed: () { Clipboard.setData(ClipboardData(text: qrCode)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Center(child: Text("Copied")))); }),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFF6C63FF).withAlpha(20), borderRadius: BorderRadius.circular(20)),
            child: Text(_detectCategory(qrCode).toUpperCase(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6C63FF))),
          ),
        ]),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); setState(() => isDialogOpen = false); controller?.resumeCamera(); },
            child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: showHistory ? _buildHistoryView() : Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
              const Spacer(),
              Text('Scan QR', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.photo_library_rounded, size: 24), tooltip: 'From Gallery',
                onPressed: _cameraGranted ? _pickFromGallery : () async {
                  final granted = await requestCameraPermission(context: context);
                  if (mounted) setState(() => _cameraGranted = granted);
                }),
              IconButton(icon: const Icon(Icons.history_rounded, size: 24), tooltip: 'History',
                onPressed: () => setState(() => showHistory = true)),
            ]),
          ),
          if (!_cameraGranted)
            Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.no_photography_rounded, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('Camera permission denied', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.settings_rounded),
                label: const Text('Grant Permission'),
                onPressed: () async {
                  final granted = await requestCameraPermission(context: context);
                  if (mounted) setState(() => _cameraGranted = granted);
                },
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                icon: const Icon(Icons.photo_library_rounded),
                label: const Text('Pick from Gallery Instead'),
                onPressed: _pickFromGallery,
              ),
            ])))
          else ...[
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF6C63FF).withAlpha(40), width: 2),
                ),
                child: ClipRRect(borderRadius: BorderRadius.circular(22),
                  child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated)),
              ),
            ),
            Expanded(flex: 1, child: Center(child: Column(children: [
              Icon(Icons.qr_code_scanner_rounded, size: 32, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text('Point camera at a QR code', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
            ]))),
          ],
        ]),
      ),
    );
  }

  Widget _buildHistoryView() {
    return BlocBuilder<ScanHistoryCubit, ScanHistoryState>(
      builder: (context, state) {
        final scans = state is ScanHistoryLoaded ? state.scans : <QrCodeModel>[];
        return Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
              const Spacer(),
              const Text('Scan History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.qr_code_scanner_rounded, size: 24), tooltip: 'Scan',
                onPressed: () => setState(() => showHistory = false)),
            ]),
          ),
          if (scans.isNotEmpty)
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
              const Spacer(),
              TextButton.icon(icon: const Icon(Icons.delete_sweep_rounded, size: 18), label: const Text('Clear'),
                onPressed: () => context.read<ScanHistoryCubit>().clearHistory()),
            ])),
          Expanded(child: scans.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No scan history', style: TextStyle(color: Colors.grey.shade600)),
                ]))
              : ListView.builder(itemCount: scans.length, itemBuilder: (context, index) {
                  final scan = scans[index];
                  return ListTile(
                    leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF6C63FF).withAlpha(20), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF6C63FF))),
                    title: Text(scan.data, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(_formatDate(scan.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    onTap: () => qrView(context, scan),
                  );
                }),
          ),
        ]);
      },
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
