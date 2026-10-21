import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../models/dashboard_stats_model.dart';
import 'delivery_success_donut_card.dart';
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
        // Teslimat Başarı Halkası (Kullanıcının Onayladığı Dairesel Analitik Grafik)
        DeliverySuccessDonutCard(stats: stats),
        const SizedBox(height: 18),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Paket Durumları',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
                  SizedBox(width: 4),
                  Text(
                    'Tüm Zamanlar',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 6'lı Sayaç Gridi (Web Paneli Birebir Eşleşmesi)
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.85,
          children: [
            MetricCard(
              title: 'BEKLEYEN PAKETLER',
              count: AppFormatters.formatNumber(stats?.pendingCargos),
              icon: Icons.inventory_2_outlined,
              color: AppColors.warning,
              backgroundColor: AppColors.warningLight,
            ),
            MetricCard(
              title: 'YOLDA OLAN PAKETLER',
              count: AppFormatters.formatNumber(stats?.activeCargos),
              icon: Icons.local_shipping_outlined,
              color: AppColors.info,
              backgroundColor: AppColors.infoLight,
            ),
            MetricCard(
              title: 'TESLİM EDİLEN PAKETLER',
              count: AppFormatters.formatNumber(stats?.deliveredToday),
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.secondary,
              backgroundColor: AppColors.secondaryLight,
            ),
            MetricCard(
              title: 'SORUNLU PAKETLER',
              count: AppFormatters.formatNumber(stats?.problematicCargos),
              icon: Icons.warning_amber_rounded,
              color: AppColors.error,
              backgroundColor: AppColors.errorLight,
            ),
            MetricCard(
              title: 'GERİ DÖNEN PAKETLER',
              count: AppFormatters.formatNumber(stats?.returnedCargos),
              icon: Icons.replay_rounded,
              color: AppColors.returned,
              backgroundColor: AppColors.returnedLight,
            ),
            MetricCard(
              title: 'TÜMÜ',
              count: AppFormatters.formatNumber(stats?.totalCargos),
              icon: Icons.format_list_bulleted_rounded,
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withValues(alpha: 0.08),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Şehir Analiz Kartları
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.trending_up, size: 14, color: AppColors.secondary),
                        SizedBox(width: 4),
                        Text(
                          'EN ÇOK KARGO ALAN',
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stats?.topCity ?? 'Eskişehir / 1182',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                        SizedBox(width: 4),
                        Text(
                          'EN AZ KARGO ALAN',
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stats?.leastCity ?? 'Tokat / 1',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
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
