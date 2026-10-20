import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.15,
          children: [
            SmallStatCard(
              title: 'KARGO SAYISI',
              value: AppFormatters.formatNumber(stats?.podCargoCount),
              icon: Icons.local_shipping_outlined,
            ),
            SmallStatCard(
              title: 'TAHSİL EDİLECEK',
              value: AppFormatters.formatCurrency(stats?.podPending),
              icon: Icons.pending_actions_rounded,
            ),
            SmallStatCard(
              title: 'TAHSİL EDİLEN',
              value: AppFormatters.formatCurrency(stats?.podCollected),
              icon: Icons.check_circle_outline_rounded,
            ),
          ],
        ),
        const SizedBox(height: 20),

        const Text(
          'Ödeme Durumu',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.15,
          children: [
            SmallStatCard(
              title: 'TOPLAM KESİNTİ',
              value: AppFormatters.formatCurrency(stats?.podDeduction),
              icon: Icons.percent_rounded,
            ),
            SmallStatCard(
              title: 'BANA ÖDENECEK',
              value: AppFormatters.formatCurrency(stats?.podWillPay),
              icon: Icons.hourglass_bottom_rounded,
            ),
            SmallStatCard(
              title: 'BANA ÖDENEN',
              value: AppFormatters.formatCurrency(stats?.podPaid),
              icon: Icons.done_all_rounded,
              isHighlight: true,
            ),
          ],
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.softShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.reply_all_rounded, size: 16, color: AppColors.error),
                  const SizedBox(width: 6),
                  Text(
                    'İade Sayısı: ${AppFormatters.formatNumber(stats?.podReturnCount)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.error, fontSize: 13),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.account_balance_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Toplam K.Ö Hacmi: ${AppFormatters.formatCurrency(stats?.podTotalVolume)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
