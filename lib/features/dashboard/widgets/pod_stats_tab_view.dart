import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../models/dashboard_stats_model.dart';

class PodStatsTabView extends StatelessWidget {
  final DashboardStats? stats;

  const PodStatsTabView({
    super.key,
    required this.stats,
  });

  Widget _buildSummaryHeroCard() {
    final podVolume = stats?.podTotalVolume ?? 0.0;
    final cargoCount = stats?.podCargoCount ?? 0;
    final returnCount = stats?.podReturnCount ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18), width: 1.2),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.payments_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'KAPIDA ÖDEME HACMİ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'K.Ö. Portföyü',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              AppFormatters.formatCurrency(podVolume),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'K.Ö. Paketleri',
                              style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${AppFormatters.formatNumber(cargoCount)} Adet',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: returnCount > 0 ? AppColors.errorLight.withValues(alpha: 0.5) : AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: returnCount > 0 ? AppColors.error.withValues(alpha: 0.25) : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.assignment_return_outlined, size: 16, color: returnCount > 0 ? AppColors.error : AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'İade Sayısı',
                              style: TextStyle(
                                fontSize: 10,
                                color: returnCount > 0 ? AppColors.error : AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${AppFormatters.formatNumber(returnCount)} Adet',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: returnCount > 0 ? AppColors.error : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color lightColor,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? lightColor.withValues(alpha: 0.6) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight ? color.withValues(alpha: 0.4) : AppColors.border,
          width: isHighlight ? 1.4 : 1,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: lightColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isHighlight ? color : AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Üst Özet Kartı
        _buildSummaryHeroCard(),
        const SizedBox(height: 20),

        // 2. Tahsilat Durumu Kartları (2-kolonlu ferah yapı)
        const Text(
          'Tahsilat Süreci',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Alıcıdan teslimatta tahsil edilen ve teslimat bekleyen tutarlar',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPodMetricCard(
                title: 'TAHSİL EDİLECEK',
                value: AppFormatters.formatCurrency(stats?.podPending),
                subtitle: 'Teslimatta tahsil edilecek',
                icon: Icons.schedule_rounded,
                color: AppColors.warning,
                lightColor: AppColors.warningLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPodMetricCard(
                title: 'TAHSİL EDİLEN',
                value: AppFormatters.formatCurrency(stats?.podCollected),
                subtitle: 'Alıcıdan tahsil edildi',
                icon: Icons.task_alt_rounded,
                color: AppColors.info,
                lightColor: AppColors.infoLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 3. Hesaba Aktarım Kartları (Mutabakat)
        const Text(
          'Hesaba Aktarım & Mutabakat',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Kargo firmalarından Stocado\'ya ve hesabınıza yansıyan bakiye durumu',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPodMetricCard(
                title: 'BANA AKTARILACAK',
                value: AppFormatters.formatCurrency(stats?.podWillPay),
                subtitle: 'Aktarım bekleyen alacak',
                icon: Icons.hourglass_bottom_rounded,
                color: AppColors.primary,
                lightColor: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPodMetricCard(
                title: 'HESABIMA ÖDENEN',
                value: AppFormatters.formatCurrency(stats?.podPaid),
                subtitle: 'Tamamlanan transferler',
                icon: Icons.check_circle_rounded,
                color: AppColors.secondary,
                lightColor: AppColors.secondaryLight,
                isHighlight: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 4. Hizmet & Kargo Kesintisi Şeffaflık Bandı
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.softShadow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.textSecondary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hizmet & Kargo Kesintileri',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'K.Ö. tahsilat komisyonu ve taşıma bedeli kesintileri',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  AppFormatters.formatCurrency(stats?.podDeduction),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
