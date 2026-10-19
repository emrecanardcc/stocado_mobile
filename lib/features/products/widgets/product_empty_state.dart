import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProductEmptyState extends StatelessWidget {
  final VoidCallback onAddProduct;

  const ProductEmptyState({
    super.key,
    required this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceSecondary,
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: const Icon(Icons.inventory_2_outlined, size: 38, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            const Text(
              'Ürün Bulunamadı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Henüz kayıtlı bir ürününüz yok veya arama kriterinize uygun ürün bulunamadı.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAddProduct,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Yeni Ürün Ekle', style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(180, 46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
