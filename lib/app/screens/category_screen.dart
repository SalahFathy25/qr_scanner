import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code/app/data/qr_cubit.dart';
import 'package:qr_code/app/data/qr_state.dart';
import 'package:qr_code/app/models/category_model.dart';
import 'package:qr_code/app/widgets/no_qr.dart';
import 'package:qr_code/app/widgets/qr_bottom_sheet.dart';
import 'package:qr_code/app/widgets/qr_card.dart';
import 'package:qr_code/app/widgets/qr_view.dart';

class CategoryScreen extends StatelessWidget {
  final CategoryModel category;
  final String? highlightId;

  const CategoryScreen({
    super.key,
    required this.category,
    this.highlightId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: BlocBuilder<QrCubit, QrState>(
                builder: (context, state) {
                  if (state is QrLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is QrError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    );
                  }

                  final qrCodes = context.read<QrCubit>().getQrCodesByCategory(category.id);

                  if (qrCodes.isEmpty) {
                    return noQr(message: 'No ${category.name} QR codes');
                  }

                  return ListView.builder(
                    itemCount: qrCodes.length,
                    itemBuilder: (context, index) {
                      final qr = qrCodes[index];
                      return qrCard(
                        qrCode: qr,
                        leadingWidget: category.imagePath != null
                            ? Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  category.imagePath!,
                                  width: 44, height: 44,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : null,
                        onTap: () => qrView(context, qr),
                        onDelete: () => context.read<QrCubit>().deleteQrCode(qr.id),
                        onFavoriteToggle: () =>
                            context.read<QrCubit>().toggleFavorite(qr.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            category.color.withAlpha(30),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: category.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: category.imagePath != null
                      ? Image.asset(category.imagePath!, width: 30, height: 30)
                      : Icon(category.icon, color: category.color, size: 28),
                ),
                const SizedBox(width: 12),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_rounded, size: 30),
                  onPressed: () => showQrBottomSheet(
                    context: context,
                    category: category,
                    onSave: ({required title, required data, required color, int? gradientStart, int? gradientEnd, bool hasLogo = false}) {
                      context.read<QrCubit>().addQrCode(
                        title: title,
                        data: data,
                        category: category.id,
                        colorValue: color,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
