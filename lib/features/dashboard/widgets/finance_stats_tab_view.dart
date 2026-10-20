import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../models/dashboard_stats_model.dart';
import 'metric_card.dart';

class FinanceStatsTabView extends StatelessWidget {
  final DashboardStats? stats;
  final double currentBalance;

  const FinanceStatsTabView({
    super.key,
    required this.stats,
    required this.currentBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Finansal Özet & Hareketler',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),

        FinanceRowCard(
          title: 'TOPLAM ÖDENEN / YÜKLENEN',
          amount: AppFormatters.formatCurrency(stats?.totalPaid),
          icon: Icons.arrow_downward_rounded,
          color: AppColors.secondary,
        ),
        const SizedBox(height: 10),
        FinanceRowCard(
          title: 'HARCANAN (GİDERLER)',
          amount: AppFormatters.formatCurrency(stats?.totalExpenses),
          icon: Icons.arrow_upward_rounded,
          color: AppColors.error,
        ),
        const SizedBox(height: 10),
        FinanceRowCard(
          title: 'MEVCUT KULLANILABİLİR BAKİYE',
          amount: AppFormatters.formatCurrency(currentBalance),
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.primary,
        ),
      ],
    );
  }
}
