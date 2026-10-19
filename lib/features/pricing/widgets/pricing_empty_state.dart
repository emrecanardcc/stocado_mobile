import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PricingEmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const PricingEmptyState({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
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
              child: const Icon(Icons.receipt_long_outlined, size: 38, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            const Text(
              'Aktif Tarife Bulunamadı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hesabınıza tanımlı aktif bir fiyat listesi ve kargo anlaşması bulunamadı.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Tarifeleri Yenile', style: TextStyle(fontWeight: FontWeight.w700)),
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
