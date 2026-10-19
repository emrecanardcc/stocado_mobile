import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CargoEmptyState extends StatelessWidget {
  const CargoEmptyState({super.key});

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
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 38,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Kargo Bulunamadı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bu sekmede listelenecek kargo kaydı bulunmuyor ya da arama kriterlerinize uygun sonuç yok.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
