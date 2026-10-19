import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
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
          'Finansal Özet',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 12),

        FinanceRowCard(
          title: 'TOPLAM ÖDENEN / YÜKLENEN',
          amount: '₺ ${stats != null ? stats!.totalPaid.toStringAsFixed(2) : '0,00'}',
          icon: Icons.arrow_downward,
          color: Colors.green,
        ),
        const SizedBox(height: 10),
        FinanceRowCard(
          title: 'HARCANAN (GİDERLER)',
          amount: '₺ ${stats != null ? stats!.totalExpenses.toStringAsFixed(2) : '0,00'}',
          icon: Icons.arrow_upward,
          color: Colors.red,
        ),
        const SizedBox(height: 10),
        FinanceRowCard(
          title: 'MEVCUT KULLANILABİLİR BAKİYE',
          amount: '₺ ${currentBalance.toStringAsFixed(2)}',
          icon: Icons.wallet,
          color: AppColors.primary,
        ),
      ],
    );
  }
}
