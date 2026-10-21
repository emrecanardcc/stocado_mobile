import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../models/dashboard_stats_model.dart';
import '../providers/dashboard_provider.dart';
import 'delivery_success_donut_card.dart';
import 'metric_card.dart';

class CargoStatsTabView extends ConsumerWidget {
  final DashboardStats? stats;

  const CargoStatsTabView({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDays = ref.watch(dashboardProvider.select((s) => s.selectedDays));

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
            PopupMenuButton<int?>(
              initialValue: selectedDays,
              tooltip: 'Dönem Filtrele',
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              onSelected: (days) {
                ref.read(dashboardProvider.notifier).setPeriod(days);
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: null,
                  child: Row(
                    children: [
                      Icon(Icons.all_inclusive_rounded, size: 16, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Tüm Zamanlar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 7,
                  child: Row(
                    children: [
                      Icon(Icons.date_range_rounded, size: 16, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Son 7 Gün', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 30,
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Son 30 Gün', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 90,
                  child: Row(
                    children: [
                      Icon(Icons.event_note_rounded, size: 16, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Son 90 Gün', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.softShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      selectedDays == 7
                          ? 'Son 7 Gün'
                          : selectedDays == 30
                              ? 'Son 30 Gün'
                              : selectedDays == 90
                                  ? 'Son 90 Gün'
                                  : 'Tüm Zamanlar',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down_rounded, size: 18, color: AppColors.textSecondary),
                  ],
                ),
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
      ],
    );
  }
}
