import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code/app/data/qr_cubit.dart';
import 'package:qr_code/app/data/qr_state.dart';
import 'package:qr_code/app/models/qr_code_model.dart';
import 'package:qr_code/app/widgets/no_qr.dart';
import 'package:qr_code/app/widgets/qr_card.dart';
import 'package:qr_code/app/widgets/qr_view.dart';
import 'package:qr_code/core/constants/app_constants.dart';

class AllQrScreen extends StatefulWidget {
  const AllQrScreen({super.key});

  @override
  State<AllQrScreen> createState() => _AllQrScreenState();
}

class _AllQrScreenState extends State<AllQrScreen> {
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 16, right: 16, top: MediaQuery.of(context).padding.top + 8,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'All QR Codes',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      BlocBuilder<QrCubit, QrState>(
                        builder: (context, state) {
                          if (state is QrSuccess && state.qrCodes.isNotEmpty) {
                            return PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded),
                              onSelected: (value) {
                                if (value == 'clear') {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Clear All?'),
                                      content: const Text('This will delete all QR codes.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            context.read<QrCubit>().clearAllQrCodes();
                                            Navigator.pop(ctx);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text('Delete All'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'clear',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_forever, color: Colors.red, size: 20),
                                      SizedBox(width: 8),
                                      Text('Clear All'),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    onChanged: (v) => setState(() => searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search QR codes...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                searchController.clear();
                                setState(() => searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.brightness == Brightness.dark
                          ? Colors.grey.shade900
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<QrCubit, QrState>(
                builder: (context, state) {
                  if (state is QrLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is QrError) {
                    return Center(child: Text(state.message));
                  }

                  List<QrCodeModel> qrCodes;
                  if (state is QrSuccess) {
                    qrCodes = context.read<QrCubit>().searchQrCodes(searchQuery);
                  } else {
                    qrCodes = [];
                  }

                  if (qrCodes.isEmpty) {
                    if (searchQuery.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text('No results for "$searchQuery"',
                                style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      );
                    }
                    return noQr();
                  }

                  return ListView.builder(
                    itemCount: qrCodes.length,
                    itemBuilder: (context, index) {
                      final qr = qrCodes[index];
                      final cat = AppConstants.builtInCategories.where(
                        (c) => c.id == qr.category,
                      ).firstOrNull;

                      return qrCard(
                        qrCode: qr,
                        leadingWidget: cat != null
                            ? Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: cat.color.withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: cat.imagePath != null
                                    ? Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Image.asset(cat.imagePath!, fit: BoxFit.contain),
                                      )
                                    : Icon(cat.icon, color: cat.color, size: 22),
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
}
