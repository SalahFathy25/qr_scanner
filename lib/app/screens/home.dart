import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code/app/data/custom_category_cubit.dart';
import 'package:qr_code/app/data/qr_cubit.dart';
import 'package:qr_code/app/data/scan_history_cubit.dart';
import 'package:qr_code/app/models/category_model.dart';
import 'package:qr_code/app/models/qr_code_model.dart';
import 'package:qr_code/app/screens/all_qr_screen.dart';
import 'package:qr_code/app/screens/batch_generate_screen.dart';
import 'package:qr_code/app/screens/category_screen.dart';
import 'package:qr_code/app/screens/scan_qr_code.dart';
import 'package:qr_code/app/screens/settings_screen.dart';
import 'package:qr_code/core/constants/app_constants.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeBody();
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  int _crossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 900) return 6;
    if (width > 600) return 5;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text(AppConstants.appName, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24)),
              floating: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.batch_prediction_rounded, size: 24),
                  tooltip: 'Batch Generate',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(
                    value: context.read<QrCubit>(),
                    child: BatchGenerateScreen(
                      onGenerate: (title, data, category) {
                        context.read<QrCubit>().addQrCode(title: title, data: data, category: category);
                      },
                    ),
                  ))),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 26),
                  tooltip: 'Scan QR',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(
                    value: context.read<ScanHistoryCubit>(),
                    child: const ScanQrCode(),
                  ))),
                ),
                IconButton(
                  icon: const Icon(Icons.search_rounded, size: 26),
                  tooltip: 'Search',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(
                    value: context.read<QrCubit>(),
                    child: const AllQrScreen(),
                  ))),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_rounded, size: 24),
                  tooltip: 'Settings',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  tooltip: 'More',
                  onSelected: (v) {
                    if (v == 'custom_cats') {
                      // Trigger custom category management
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'custom_cats', child: ListTile(leading: Icon(Icons.category_outlined), title: Text('Manage Categories'), dense: true)),
                  ],
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildHeader(context, 'Social Media'),
                  const SizedBox(height: 12),
                  _buildCategoryRow(context, AppConstants.socialMediaCategories),
                  const SizedBox(height: 24),
                  _buildHeader(context, 'More Types'),
                  const SizedBox(height: 12),
                  _buildCategoryGrid(context),
                  const SizedBox(height: 24),
                  _buildHeader(context, 'Favorites'),
                  const SizedBox(height: 12),
                  _buildFavoriteList(context),
                  const SizedBox(height: 30),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Row(children: [
      Container(width: 4, height: 20, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
    ]);
  }

  Widget _buildCategoryRow(BuildContext context, List<CategoryModel> categories) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return _CategoryCard(category: cat, onTap: () => _openCategory(context, cat));
        },
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    final customCubit = context.watch<CustomCategoryCubit>();
    final allCats = [
      ...AppConstants.utilityCategories,
      ...customCubit.getAllCategories().where((c) => !c.isBuiltIn),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allCats.length + 1,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount(context),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        if (index == allCats.length) return _buildAddCustomCategory(context);
        return _MiniCategoryCard(category: allCats[index], onTap: () => _openCategory(context, allCats[index]));
      },
    );
  }

  Widget _buildAddCustomCategory(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddCategoryDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withAlpha(15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withAlpha(40), width: 1.5, strokeAlign: BorderSide.strokeAlignInside),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
          const SizedBox(height: 4),
          Text('Custom', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _buildFavoriteList(BuildContext context) {
    final qrCubit = context.watch<QrCubit>();
    final favorites = qrCubit.favoriteQrCodes;

    if (favorites.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('No favorites yet', style: TextStyle(color: Colors.grey.shade500, fontSize: 14))),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _FavoriteMiniCard(qrCode: favorites[index]),
      ),
    );
  }

  void _openCategory(BuildContext context, CategoryModel category) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<QrCubit>()),
          BlocProvider.value(value: context.read<CustomCategoryCubit>()),
        ],
        child: CategoryScreen(category: category),
      ),
    ));
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    IconData selectedIcon = Icons.category;
    int selectedColor = 0xFF6C63FF;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('New Custom Category'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameController, decoration: InputDecoration(hintText: 'Category name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _iconBtn(Icons.category, selectedIcon, () => setState(() => selectedIcon = Icons.category)),
            _iconBtn(Icons.star, selectedIcon, () => setState(() => selectedIcon = Icons.star)),
            _iconBtn(Icons.favorite, selectedIcon, () => setState(() => selectedIcon = Icons.favorite)),
            _iconBtn(Icons.code, selectedIcon, () => setState(() => selectedIcon = Icons.code)),
            _iconBtn(Icons.shopping_cart, selectedIcon, () => setState(() => selectedIcon = Icons.shopping_cart)),
            _iconBtn(Icons.music_note, selectedIcon, () => setState(() => selectedIcon = Icons.music_note)),
          ]),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _colorDot(0xFF6C63FF, selectedColor, (c) => setState(() => selectedColor = c)),
            _colorDot(0xFFE53935, selectedColor, (c) => setState(() => selectedColor = c)),
            _colorDot(0xFF43A047, selectedColor, (c) => setState(() => selectedColor = c)),
            _colorDot(0xFFFB8C00, selectedColor, (c) => setState(() => selectedColor = c)),
            _colorDot(0xFF1E88E5, selectedColor, (c) => setState(() => selectedColor = c)),
            _colorDot(0xFF7B1FA2, selectedColor, (c) => setState(() => selectedColor = c)),
          ]),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () {
            if (nameController.text.isNotEmpty) {
              context.read<CustomCategoryCubit>().addCustomCategory(nameController.text, selectedIcon, selectedColor);
              Navigator.pop(ctx);
            }
          }, child: const Text('Create')),
        ],
      )),
    );
  }

  Widget _iconBtn(IconData icon, IconData selected, VoidCallback onTap) {
    final isSelected = icon == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF).withAlpha(30) : null,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: const Color(0xFF6C63FF)) : null,
        ),
        child: Icon(icon, size: 24, color: isSelected ? const Color(0xFF6C63FF) : Colors.grey),
      ),
    );
  }

  Widget _colorDot(int color, int selected, void Function(int) onTap) {
    final isSelected = color == selected;
    return GestureDetector(
      onTap: () => onTap(color),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: Color(color), shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: isSelected ? [BoxShadow(color: Color(color).withAlpha(100), blurRadius: 6)] : null,
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: category.color.withAlpha(25), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: category.color.withAlpha(25), borderRadius: BorderRadius.circular(16)),
            child: category.imagePath != null
                ? Padding(padding: const EdgeInsets.all(10), child: Image.asset(category.imagePath!, fit: BoxFit.contain))
                : Icon(category.icon, color: category.color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(category.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _MiniCategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  const _MiniCategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: category.color.withAlpha(20), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: category.color.withAlpha(25), borderRadius: BorderRadius.circular(14)),
            child: Icon(category.icon, color: category.color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(category.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _FavoriteMiniCard extends StatelessWidget {
  final QrCodeModel qrCode;
  const _FavoriteMiniCard({required this.qrCode});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryScreen(
          category: AppConstants.builtInCategories.firstWhere(
            (c) => c.id == qrCode.category, orElse: () => AppConstants.builtInCategories.last),
          highlightId: qrCode.id,
        )));
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.favorite_rounded, color: Colors.red.shade400, size: 18),
          const SizedBox(height: 8),
          Text(qrCode.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(qrCode.data, style: TextStyle(fontSize: 11, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}
