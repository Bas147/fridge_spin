import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../favorites/presentation/screens/favorites_screen.dart';
import '../providers/ingredient_provider.dart';

class DrawerMenu extends ConsumerWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FridgeSpin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'แนะนำสูตรอาหารจากวัตถุดิบที่มี',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('หน้าหลัก'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('รายการโปรด'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('ตั้งค่า'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings screen
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: AppColors.error),
            title: Text(
              'ลบวัตถุดิบทั้งหมด',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              Navigator.pop(context);
              _showClearConfirmation(context, ref);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'เวอร์ชัน 1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('ลบวัตถุดิบทั้งหมด'),
            content: const Text(
              'คุณแน่ใจหรือไม่ที่จะลบวัตถุดิบทั้งหมด? การกระทำนี้ไม่สามารถย้อนกลับได้',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ยกเลิก'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(ingredientProvider.notifier).clearAllIngredients();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ลบวัตถุดิบทั้งหมดแล้ว'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('ลบทั้งหมด'),
              ),
            ],
          ),
    );
  }
}
