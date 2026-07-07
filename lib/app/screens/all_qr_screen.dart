import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_studio/app/data/qr_cubit.dart';
import 'package:qr_studio/app/data/qr_state.dart';
import 'package:qr_studio/app/models/qr_code_model.dart';
import 'package:qr_studio/app/widgets/no_qr.dart';
import 'package:qr_studio/app/widgets/qr_bottom_sheet.dart';
import 'package:qr_studio/app/widgets/qr_card.dart';
import 'package:qr_studio/app/widgets/qr_view.dart';
import 'package:qr_studio/core/constants/app_constants.dart';
import 'package:qr_studio/core/extensions/context_extensions.dart';

enum SortOption { newest, oldest, name, category }

class AllQrScreen extends StatefulWidget {
  const AllQrScreen({super.key});

  @override
  State<AllQrScreen> createState() => _AllQrScreenState();
}

class _AllQrScreenState extends State<AllQrScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  SortOption _sortBy = SortOption.newest;
  String? _filterCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: BlocBuilder<QrCubit, QrState>(
                builder: (context, state) {
                  return switch (state) {
                    QrLoading() => const Center(child: CircularProgressIndicator()),
                    QrError(:final message) => _buildError(context, message),
                    QrSuccess() => _buildList(context),
                    _ => const SizedBox.shrink(),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: context.topPadding + 8,
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
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search QR codes...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: context.isDark
                  ? Colors.grey.shade900
                  : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildFilterRow(context),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return Row(
      children: [
        _FilterChip(
          icon: Icons.sort_rounded,
          label: 'Sort: ${_sortBy.name[0].toUpperCase()}${_sortBy.name.substring(1)}',
          onTap: () => _showSortSheet(context),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          icon: Icons.filter_list_rounded,
          label: _filterCategory ?? 'All Categories',
          onTap: () => _showFilterSheet(context),
        ),
        const Spacer(),
        TextButton.icon(
          icon: const Icon(Icons.file_upload_outlined, size: 18),
          label: const Text('Export'),
          onPressed: () {
            context.showSnackBar(
              'Export feature ready. Use menu on home screen.',
            );
          },
        ),
      ],
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Sort by',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...SortOption.values.map(
            (s) => ListTile(
              title: Text(s.name[0].toUpperCase() + s.name.substring(1)),
              trailing: _sortBy == s
                  ? const Icon(Icons.check, color: Color(0xFF6C63FF))
                  : null,
              onTap: () {
                setState(() => _sortBy = s);
                Navigator.pop(ctx);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Filter by category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ListTile(
            title: const Text('All'),
            trailing: _filterCategory == null
                ? const Icon(Icons.check, color: Color(0xFF6C63FF))
                : null,
            onTap: () {
              setState(() => _filterCategory = null);
              Navigator.pop(ctx);
            },
          ),
          ...AppConstants.builtInCategories.map(
            (c) => ListTile(
              leading: Icon(c.icon, color: c.color, size: 22),
              title: Text(c.name),
              trailing: _filterCategory == c.id
                  ? const Icon(Icons.check, color: Color(0xFF6C63FF))
                  : null,
              onTap: () {
                setState(() => _filterCategory = c.id);
                Navigator.pop(ctx);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    List<QrCodeModel> qrCodes = context.read<QrCubit>().searchQrCodes(_searchQuery);

    if (_filterCategory != null) {
      qrCodes = qrCodes.where((q) => q.category == _filterCategory).toList();
    }
    qrCodes = _sortCodes(qrCodes);

    if (qrCodes.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No results for "$_searchQuery"',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }
      return const EmptyQrWidget();
    }

    return ListView.builder(
      itemCount: qrCodes.length,
      itemBuilder: (context, index) {
        final qr = qrCodes[index];
        final cat = AppConstants.builtInCategories
            .where((c) => c.id == qr.category)
            .firstOrNull;

        return QrCardItem(
          qrCode: qr,
          leadingWidget: cat != null
              ? Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cat.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: cat.imagePath != null
                      ? Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            cat.imagePath!,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Icon(cat.icon, color: cat.color, size: 22),
                )
              : null,
          onTap: () async {
            final edit = await QrViewDialog.show(context, qr);
            if (edit == true && context.mounted && cat != null) {
              QrBottomSheet.show(
                context: context,
                category: cat,
                existingTitle: qr.title,
                existingData: qr.data,
                existingColor: qr.colorValue,
                onSave: ({
                  required title,
                  required data,
                  required color,
                }) {
                  context.read<QrCubit>().updateQrCode(
                    id: qr.id,
                    title: title,
                    data: data,
                    colorValue: color,
                  );
                },
              );
            }
          },
          onDelete: () {
            context.read<QrCubit>().deleteQrCode(qr.id);
            context.showSnackBar('QR code deleted');
          },
          onFavoriteToggle: () =>
              context.read<QrCubit>().toggleFavorite(qr.id),
        );
      },
    );
  }

  List<QrCodeModel> _sortCodes(List<QrCodeModel> codes) {
    final sorted = List<QrCodeModel>.from(codes);
    switch (_sortBy) {
      case SortOption.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SortOption.oldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case SortOption.name:
        sorted.sort((a, b) => a.title.compareTo(b.title));
      case SortOption.category:
        sorted.sort((a, b) => a.category.compareTo(b.category));
    }
    return sorted;
  }
}

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FilterChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: context.isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
