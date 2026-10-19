import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/dashboard_stats_model.dart';
import 'metric_card.dart';

class CargoStatsTabView extends StatelessWidget {
  final DashboardStats? stats;

  const CargoStatsTabView({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Paket Durumları',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 12),

        // 6'lı Sayaç Gridi
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: [
            MetricCard(
              title: 'BEKLEYEN PAKETLER',
              count: '${stats?.pendingCargos ?? 0}',
              icon: Icons.hourglass_top,
              color: Colors.amber.shade700,
            ),
            MetricCard(
              title: 'YOLDA OLAN PAKETLER',
              count: '${stats?.activeCargos ?? 0}',
              icon: Icons.local_shipping,
              color: Colors.blue.shade700,
            ),
            MetricCard(
              title: 'TESLİM EDİLEN PAKETLER',
              count: '${stats?.deliveredToday ?? 0}',
              icon: Icons.check_circle,
              color: Colors.green.shade700,
            ),
            MetricCard(
              title: 'SORUNLU PAKETLER',
              count: '${stats?.problematicCargos ?? 0}',
              icon: Icons.warning_amber_rounded,
              color: AppColors.error,
            ),
            MetricCard(
              title: 'GERİ DÖNEN PAKETLER',
              count: '${stats?.returnedCargos ?? 0}',
              icon: Icons.assignment_return,
              color: Colors.purple.shade700,
            ),
            MetricCard(
              title: 'TÜMÜ',
              count: '${stats?.totalCargos ?? 0}',
              icon: Icons.inventory_2,
              color: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Şehir Analiz Kartları
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('EN ÇOK KARGO ALAN', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(stats?.topCity ?? 'Eskişehir / 1182', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('EN AZ KARGO ALAN', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(stats?.leastCity ?? 'Tokat / 1', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
