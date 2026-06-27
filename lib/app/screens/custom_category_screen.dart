import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code/app/data/custom_category_cubit.dart';

class CustomCategoryScreen extends StatelessWidget {
  const CustomCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 16, right: 16, top: MediaQuery.of(context).padding.top + 8,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Custom Categories',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<CustomCategoryCubit, CustomCategoryState>(
                builder: (context, state) {
                  if (state is CustomCategoriesLoaded) {
                    final custom = state.categories;
                    if (custom.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.category_rounded, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text('No custom categories yet',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: custom.length,
                      itemBuilder: (context, index) {
                        final cat = custom[index];
                        return Dismissible(
                          key: ValueKey(cat.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            context.read<CustomCategoryCubit>().deleteCustomCategory(cat.id);
                          },
                          background: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: cat.color.withAlpha(25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(cat.icon, color: cat.color),
                            ),
                            title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: const Text('Swipe to delete'),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
