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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'Hesabınıza tanımlı aktif tarife bulunamadı.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Yenile'),
            ),
          ],
        ),
      ),
    );
  }
}
