import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_studio/app/data/custom_category_cubit.dart';
import 'package:qr_studio/app/data/export_import_cubit.dart';
import 'package:qr_studio/app/data/qr_cubit.dart';
import 'package:qr_studio/app/data/scan_history_cubit.dart';
import 'package:qr_studio/app/models/category_model.dart';
import 'package:qr_studio/app/models/qr_code_model.dart';
import 'package:qr_studio/app/screens/all_qr_screen.dart';
import 'package:qr_studio/app/screens/category_screen.dart';
import 'package:qr_studio/app/screens/scan_qr_code.dart';
import 'package:qr_studio/app/screens/settings_screen.dart';
import 'package:qr_studio/core/constants/app_constants.dart';
import 'package:qr_studio/core/extensions/context_extensions.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeBody();
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text(
                AppConstants.appName,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
              ),
              floating: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 26),
                  tooltip: 'Scan QR',
                  onPressed: () => _openScanner(context),
                ),
                IconButton(
                  icon: const Icon(Icons.search_rounded, size: 26),
                  tooltip: 'Search',
                  onPressed: () => _openAllQr(context),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_rounded, size: 24),
                  tooltip: 'Settings',
                  onPressed: () => _openSettings(context),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader('Social Media'),
                    const SizedBox(height: 12),
                    _CategoryRow(
                      categories: AppConstants.socialMediaCategories,
                      onTap: (cat) => _openCategory(context, cat),
                    ),
                    const SizedBox(height: 24),
                    _SectionHeader('More Types'),
                    const SizedBox(height: 12),
                    _CategoryGrid(
                      onTap: (cat) => _openCategory(context, cat),
                      onAddTap: () => _showAddCategoryDialog(context),
                    ),
                    const SizedBox(height: 24),
                    _SectionHeader('Favorites'),
                    const SizedBox(height: 12),
                    _FavoriteList(
                      onTap: (qr) => _openCategoryWithHighlight(context, qr),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ScanHistoryCubit>(),
          child: const ScanQrCode(),
        ),
      ),
    );
  }

  void _openAllQr(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<QrCubit>(),
          child: const AllQrScreen(),
        ),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<QrCubit>()),
            BlocProvider.value(value: context.read<ScanHistoryCubit>()),
            BlocProvider(create: (_) => ExportImportCubit()),
          ],
          child: const SettingsScreen(),
        ),
      ),
    );
  }

  void _openCategory(BuildContext context, CategoryModel category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<QrCubit>()),
            BlocProvider.value(value: context.read<CustomCategoryCubit>()),
          ],
          child: CategoryScreen(category: category),
        ),
      ),
    );
  }

  void _openCategoryWithHighlight(BuildContext context, QrCodeModel qr) {
    final category = AppConstants.builtInCategories.firstWhere(
      (c) => c.id == qr.category,
      orElse: () => AppConstants.builtInCategories.last,
    );
    _openCategory(context, category);
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _AddCategoryDialog(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: context.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final List<CategoryModel> categories;
  final void Function(CategoryModel) onTap;

  const _CategoryRow({required this.categories, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return _CategoryCard(category: cat, onTap: () => onTap(cat));
        },
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
    final theme = context.theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: category.color.withAlpha(25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category.color.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: category.imagePath != null
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        category.imagePath!,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Icon(category.icon, color: category.color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final void Function(CategoryModel) onTap;
  final VoidCallback onAddTap;

  const _CategoryGrid({required this.onTap, required this.onAddTap});

  int _crossAxisCount(BuildContext context) {
    if (context.isWide) return 6;
    if (context.isMedium) return 5;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
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
        if (index == allCats.length) {
          return _AddCustomCategoryCard(onTap: onAddTap);
        }
        return _MiniCategoryCard(
          category: allCats[index],
          onTap: () => onTap(allCats[index]),
        );
      },
    );
  }
}

class _MiniCategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  const _MiniCategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: category.color.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.color.withAlpha(25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(category.icon, color: category.color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCustomCategoryCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddCustomCategoryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withAlpha(15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withAlpha(40),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded,
                color: theme.colorScheme.primary, size: 28),
            const SizedBox(height: 4),
            Text(
              'Custom',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteList extends StatelessWidget {
  final void Function(QrCodeModel) onTap;
  const _FavoriteList({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final qrCubit = context.watch<QrCubit>();
    final favorites = qrCubit.favoriteQrCodes;

    if (favorites.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'No favorites yet',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final qr = favorites[index];
          return _FavoriteMiniCard(qrCode: qr, onTap: () => onTap(qr));
        },
      ),
    );
  }
}

class _FavoriteMiniCard extends StatelessWidget {
  final QrCodeModel qrCode;
  final VoidCallback onTap;
  const _FavoriteMiniCard({required this.qrCode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_rounded, color: Colors.red.shade400, size: 18),
            const SizedBox(height: 8),
            Text(
              qrCode.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              qrCode.data,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCategoryDialog extends StatefulWidget {
  const _AddCategoryDialog();

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.category;
  int _selectedColor = 0xFF6C63FF;

  static const _icons = [
    Icons.category,
    Icons.star,
    Icons.favorite,
    Icons.code,
    Icons.shopping_cart,
    Icons.music_note,
  ];

  static const _colors = [
    0xFF6C63FF,
    0xFFE53935,
    0xFF43A047,
    0xFFFB8C00,
    0xFF1E88E5,
    0xFF7B1FA2,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('New Custom Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Category name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _icons
                .map(
                  (icon) => _IconButton(
                    icon: icon,
                    isSelected: icon == _selectedIcon,
                    onTap: () => setState(() => _selectedIcon = icon),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _colors
                .map(
                  (c) => _ColorDot(
                    color: c,
                    isSelected: c == _selectedColor,
                    onTap: () => setState(() => _selectedColor = c),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              context
                  .read<CustomCategoryCubit>()
                  .addCustomCategory(
                    _nameController.text,
                    _selectedIcon,
                    _selectedColor,
                  );
              Navigator.pop(context);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C63FF).withAlpha(30)
              : null,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: const Color(0xFF6C63FF))
              : null,
        ),
        child: Icon(
          icon,
          size: 24,
          color: isSelected ? const Color(0xFF6C63FF) : Colors.grey,
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final int color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorDot({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Color(color),
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(color).withAlpha(100),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : null,
      ),
    );
  }
}
