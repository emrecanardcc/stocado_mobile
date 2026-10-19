import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/dashboard_stats_model.dart';
import 'metric_card.dart';

class PodStatsTabView extends StatelessWidget {
  final DashboardStats? stats;

  const PodStatsTabView({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tahsilat Verileri',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.1,
          children: [
            SmallStatCard(
              title: 'KARGO SAYISI',
              value: '${stats?.podCargoCount ?? 0}',
              icon: Icons.local_shipping_outlined,
            ),
            SmallStatCard(
              title: 'TAHSİL EDİLECEK',
              value: '₺ ${stats != null ? stats!.podPending.toStringAsFixed(2) : '0,00'}',
              icon: Icons.pending_actions,
            ),
            SmallStatCard(
              title: 'TAHSİL EDİLEN',
              value: '₺ ${stats != null ? stats!.podCollected.toStringAsFixed(2) : '0,00'}',
              icon: Icons.check_circle_outline,
            ),
          ],
        ),
        const SizedBox(height: 20),

        const Text(
          'Ödeme Durumu',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.1,
          children: [
            SmallStatCard(
              title: 'TOPLAM KESİNTİ',
              value: '₺ ${stats != null ? stats!.podDeduction.toStringAsFixed(2) : '0,00'}',
              icon: Icons.percent,
            ),
            SmallStatCard(
              title: 'BANA ÖDENECEK',
              value: '₺ ${stats != null ? stats!.podWillPay.toStringAsFixed(2) : '0,00'}',
              icon: Icons.hourglass_bottom,
            ),
            SmallStatCard(
              title: 'BANA ÖDENEN',
              value: '₺ ${stats != null ? stats!.podPaid.toStringAsFixed(2) : '0,00'}',
              icon: Icons.done_all,
              isHighlight: true,
            ),
          ],
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('İade Sayısı: ${stats?.podReturnCount ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
              Text('Toplam K.Ö Hacmi: ₺ ${stats != null ? stats!.podTotalVolume.toStringAsFixed(2) : '0,00'}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
        ),
      ],
    );
  }
}
