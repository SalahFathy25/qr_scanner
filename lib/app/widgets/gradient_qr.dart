import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GradientQrView extends StatelessWidget {
  final String data;
  final double size;
  final Color color;
  final Color? gradientStart;
  final Color? gradientEnd;

  const GradientQrView({
    super.key,
    required this.data,
    this.size = 200,
    this.color = Colors.black,
    this.gradientStart,
    this.gradientEnd,
  });

  @override
  Widget build(BuildContext context) {
    final hasGradient = gradientStart != null && gradientEnd != null;

    if (!hasGradient) {
      return QrImageView(
        data: data,
        version: QrVersions.auto,
        size: size,
        foregroundColor: color,
        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square),
      );
    }

    return ShaderBuilder(
      size: size,
      data: data,
      gradientStart: gradientStart!,
      gradientEnd: gradientEnd!,
      color: color,
    );
  }
}

class ShaderBuilder extends StatelessWidget {
  final double size;
  final String data;
  final Color gradientStart;
  final Color gradientEnd;
  final Color color;

  const ShaderBuilder({
    super.key,
    required this.size,
    required this.data,
    required this.gradientStart,
    required this.gradientEnd,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ).createShader(bounds);
      },
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: size,
        foregroundColor: Colors.white,
        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square),
      ),
    );
  }
}

class QrWithLogo extends StatelessWidget {
  final String data;
  final double size;
  final Color color;
  final Color? gradientStart;
  final Color? gradientEnd;
  final Widget? logo;
  final double logoSize;

  const QrWithLogo({
    super.key,
    required this.data,
    this.size = 200,
    this.color = Colors.black,
    this.gradientStart,
    this.gradientEnd,
    this.logo,
    this.logoSize = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GradientQrView(
          data: data,
          size: size,
          color: color,
          gradientStart: gradientStart,
          gradientEnd: gradientEnd,
        ),
        if (logo != null)
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 8),
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: logo,
          ),
      ],
    );
  }
}
