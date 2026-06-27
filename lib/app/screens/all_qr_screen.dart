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
  String _sortBy = 'newest';
  String? _filterCategory;

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
        child: Column(children: [
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: MediaQuery.of(context).padding.top + 8),
            child: Column(children: [
              Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
                const Text('All QR Codes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const Spacer(),
              ]),
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                onChanged: (v) => setState(() => searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search QR codes...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: searchQuery.isNotEmpty ? IconButton(
                    icon: const Icon(Icons.clear_rounded), onPressed: () { searchController.clear(); setState(() => searchQuery = ''); }) : null,
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                _filterChip(Icons.sort_rounded, 'Sort: ${_sortBy[0].toUpperCase()}${_sortBy.substring(1)}', () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, children: [
                      const SizedBox(height: 16),
                      const Text('Sort by', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ...['newest', 'oldest', 'name', 'category'].map((s) => ListTile(
                        title: Text(s[0].toUpperCase() + s.substring(1)),
                        trailing: _sortBy == s ? const Icon(Icons.check, color: Color(0xFF6C63FF)) : null,
                        onTap: () { setState(() => _sortBy = s); Navigator.pop(ctx); },
                      )),
                    ]),
                  );
                }),
                const SizedBox(width: 8),
                _filterChip(Icons.filter_list_rounded, _filterCategory ?? 'All Categories', () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, children: [
                      const SizedBox(height: 16),
                      const Text('Filter by category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ListTile(
                        title: const Text('All'),
                        trailing: _filterCategory == null ? const Icon(Icons.check, color: Color(0xFF6C63FF)) : null,
                        onTap: () { setState(() => _filterCategory = null); Navigator.pop(ctx); },
                      ),
                      ...AppConstants.builtInCategories.map((c) => ListTile(
                        leading: Icon(c.icon, color: c.color, size: 22),
                        title: Text(c.name),
                        trailing: _filterCategory == c.id ? const Icon(Icons.check, color: Color(0xFF6C63FF)) : null,
                        onTap: () { setState(() => _filterCategory = c.id); Navigator.pop(ctx); },
                      )),
                    ]),
                  );
                }),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.file_upload_outlined, size: 18),
                  label: const Text('Export'),
                  onPressed: () {
                    final cubit = context.read<QrCubit>();
                    if (cubit.state is QrSuccess) {
                      // Export trigger - would be handled by ExportImportCubit
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Center(child: Text('Export feature ready. Use menu on home screen.'))));
                    }
                  },
                ),
              ]),
              const SizedBox(height: 8),
            ]),
          ),
          Expanded(
            child: BlocBuilder<QrCubit, QrState>(builder: (context, state) {
              if (state is QrLoading) return const Center(child: CircularProgressIndicator());
              if (state is QrError) return Center(child: Padding(padding: const EdgeInsets.all(20),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade400),
                  const SizedBox(height: 12),
                  Text(state.message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () => context.read<QrCubit>().getQrCodesByCategory(''), child: const Text('Retry')),
                ])));

              List<QrCodeModel> qrCodes = [];
              if (state is QrSuccess) {
                qrCodes = context.read<QrCubit>().searchQrCodes(searchQuery);
                if (_filterCategory != null) {
                  qrCodes = qrCodes.where((q) => q.category == _filterCategory).toList();
                }
                qrCodes = _sortCodes(qrCodes);
              }

              if (qrCodes.isEmpty) {
                if (searchQuery.isNotEmpty) {
                  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text('No results for "$searchQuery"', style: TextStyle(color: Colors.grey.shade600)),
                  ]));
                }
                return noQr();
              }

              return ListView.builder(
                itemCount: qrCodes.length,
                itemBuilder: (context, index) {
                  final qr = qrCodes[index];
                  final cat = AppConstants.builtInCategories.where((c) => c.id == qr.category).firstOrNull;

                  return qrCard(
                    qrCode: qr,
                    leadingWidget: cat != null
                        ? Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(color: cat.color.withAlpha(25), borderRadius: BorderRadius.circular(12)),
                            child: cat.imagePath != null
                                ? Padding(padding: const EdgeInsets.all(8), child: Image.asset(cat.imagePath!, fit: BoxFit.contain))
                                : Icon(cat.icon, color: cat.color, size: 22),
                          )
                        : null,
                    onTap: () => qrView(context, qr),
                    onDelete: () => context.read<QrCubit>().deleteQrCode(qr.id),
                    onFavoriteToggle: () => context.read<QrCubit>().toggleFavorite(qr.id),
                  );
                },
              );
            }),
          ),
        ]),
      ),
    );
  }

  Widget _filterChip(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ]),
      ),
    );
  }

  List<QrCodeModel> _sortCodes(List<QrCodeModel> codes) {
    switch (_sortBy) {
      case 'newest': return codes..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case 'oldest': return codes..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case 'name': return codes..sort((a, b) => a.title.compareTo(b.title));
      case 'category': return codes..sort((a, b) => a.category.compareTo(b.category));
      default: return codes;
    }
  }
}
