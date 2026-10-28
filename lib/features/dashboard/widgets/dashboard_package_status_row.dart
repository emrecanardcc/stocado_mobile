import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../models/dashboard_stats_model.dart';

class DashboardPackageStatusRow extends StatelessWidget {
  final DashboardStats? stats;
  final void Function(String? statusFilter)? onStatusTap;

  const DashboardPackageStatusRow({
    super.key,
    required this.stats,
    this.onStatusTap,
  });

  Widget _buildStatusItem({
    required Widget icon,
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7), width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x060F172A),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  AppFormatters.formatNumber(count),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0E1E38),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = stats?.pendingCargos ?? 0;
    final activeCount = stats?.activeCargos ?? 0;
    final deliveredCount = stats?.deliveredToday ?? 0;
    final returnedCount = stats?.returnedCargos ?? 0;
    final problematicCount = stats?.problematicCargos ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        const Text(
          'Kargolarım',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0E1E38),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),

        // 4'lü Yatay Kompakt Durum Kutuları
        Row(
          children: [
            // 1. Hazırlanan (Status 0 / Taslak)
            _buildStatusItem(
              icon: const Icon(Icons.inventory_2_outlined, size: 20, color: Color(0xFF475569)),
              label: 'Hazırlanan',
              count: pendingCount,
              onTap: () => onStatusTap?.call('0'),
            ),
            const SizedBox(width: 8),

            // 2. Yolda (Status 1 / Aktif)
            _buildStatusItem(
              icon: const Icon(Icons.local_shipping_outlined, size: 20, color: Color(0xFF2563EB)),
              label: 'Yolda',
              count: activeCount,
              onTap: () => onStatusTap?.call('1'),
            ),
            const SizedBox(width: 8),

            // 3. Teslim (Status 2 / Tamamlandı)
            _buildStatusItem(
              icon: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              ),
              label: 'Teslim',
              count: deliveredCount,
              onTap: () => onStatusTap?.call('2'),
            ),
            const SizedBox(width: 8),

            // 4. İade (Status 4 / Başarısız)
            _buildStatusItem(
              icon: const Icon(Icons.replay_rounded, size: 20, color: Color(0xFFEA580C)),
              label: 'İade',
              count: returnedCount,
              onTap: () => onStatusTap?.call('4'),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Bilgi / Dikkat Şeridi (Görseldeki Turuncu Uyarı Kutusu - Status 4)
        InkWell(
          onTap: () => onStatusTap?.call(problematicCount > 0 ? '4' : null),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFEDD5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF97316),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    problematicCount > 0
                        ? '$problematicCount gönderi işlem bekliyor'
                        : 'Tüm gönderileriniz sorunsuz ilerliyor',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9A3412),
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFFF97316),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
