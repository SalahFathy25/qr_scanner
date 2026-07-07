import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_studio/app/app.dart';
import 'package:qr_studio/core/di/app_bootstrap.dart';

Future<void> main() async {
  await AppBootstrap.init();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (_, _) => true;

  runApp(const App());
}
