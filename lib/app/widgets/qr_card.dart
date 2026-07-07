import 'package:flutter/material.dart';
import 'package:qr_studio/app/models/qr_code_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCardItem extends StatelessWidget {
  const QrCardItem({
    super.key,
    required this.qrCode,
    required this.onTap,
    required this.onDelete,
    required this.onFavoriteToggle,
    this.leadingWidget,
  });

  final QrCodeModel qrCode;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onFavoriteToggle;
  final Widget? leadingWidget;

  @override
  Widget build(BuildContext context) {
    final color = Color(qrCode.colorValue);
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(qrCode.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.dividerColor, width: 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  leadingWidget ??
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.qr_code, color: color, size: 28),
                      ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          qrCode.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          qrCode.data,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withAlpha(150),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      qrCode.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: qrCode.isFavorite
                          ? Colors.red
                          : theme.colorScheme.onSurface.withAlpha(100),
                      size: 22,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      foregroundColor: color,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                      ),
                      data: qrCode.data,
                      version: QrVersions.auto,
                      size: 44,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
