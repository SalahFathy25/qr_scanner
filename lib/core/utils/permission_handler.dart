import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestCameraPermission({BuildContext? context}) async {
  final status = await Permission.camera.request();

  if (status.isGranted) return true;

  if (status.isDenied) {
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(child: Text('Camera permission is needed to scan QR codes')),
          duration: Duration(seconds: 3),
        ),
      );
    }
    return false;
  }

  if (status.isPermanentlyDenied) {
    if (context != null && context.mounted) {
      final shouldOpen = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Camera Permission'),
          content: const Text('Camera permission is permanently denied. Please enable it in settings.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );

      if (shouldOpen == true) {
        await openAppSettings();
      }
    }
    return false;
  }

  return false;
}

Future<bool> requestStoragePermission() async {
  final status = await Permission.storage.request();
  return status.isGranted;
}
