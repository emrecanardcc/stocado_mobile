import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../models/dashboard_stats_model.dart';

class DeliverySuccessDonutCard extends StatefulWidget {
  final DashboardStats? stats;

  const DeliverySuccessDonutCard({
    super.key,
    required this.stats,
  });

  @override
  State<DeliverySuccessDonutCard> createState() => _DeliverySuccessDonutCardState();
}

class _DeliverySuccessDonutCardState extends State<DeliverySuccessDonutCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _progressAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant DeliverySuccessDonutCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stats != widget.stats) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildLegendRow({
    required Color color,
    required String label,
    required String count,
    required String percentage,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          count,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            percentage,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = widget.stats;

    // Metrik hesaplamaları
    final deliveredCount = stats?.deliveredToday ?? 0;
    final activeCount = stats?.activeCargos ?? 0;
    final pendingCount = (stats?.pendingCargos ?? 0) +
        (stats?.problematicCargos ?? 0) +
        (stats?.returnedCargos ?? 0);
    final totalCount = stats?.totalCargos ?? (deliveredCount + activeCount + pendingCount);

    final sum = deliveredCount + activeCount + pendingCount;
    final deliveredRatio = sum > 0 ? (deliveredCount / sum) : 0.0;
    final activeRatio = sum > 0 ? (activeCount / sum) : 0.0;
    final pendingRatio = sum > 0 ? (pendingCount / sum) : 0.0;

    // Başarı Yüzdesi
    double successRate = 0.0;
    if (stats?.deliveryRate != null && stats!.deliveryRate > 0) {
      successRate = stats.deliveryRate > 1.0 ? stats.deliveryRate : (stats.deliveryRate * 100);
    } else if (sum > 0) {
      successRate = deliveredRatio * 100;
    }

    final deliveredPercentStr = '%${(deliveredRatio * 100).toStringAsFixed(0)}';
    final activePercentStr = '%${(activeRatio * 100).toStringAsFixed(0)}';
    final pendingPercentStr = '%${(pendingRatio * 100).toStringAsFixed(0)}';
    final successRateStr = '%${successRate.toStringAsFixed(0)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve Rozet
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.pie_chart_outline_rounded,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teslimat Başarı Oranı',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Paket başarı ve dağıtım performansı',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Canlı',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Halka Grafik + Dağılım Listesi
          Row(
            children: [
              // Sol: Animasyonlu Halka Grafik
              SizedBox(
                width: 104,
                height: 104,
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _DonutChartPainter(
                        progress: _progressAnimation.value,
                        deliveredRatio: deliveredRatio,
                        activeRatio: activeRatio,
                        pendingRatio: pendingRatio,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              successRateStr,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const Text(
                              'BAŞARI',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Sağ: Dağılım Göstergesi (Legend)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendRow(
                      color: AppColors.secondary,
                      label: 'Teslim Edildi',
                      count: AppFormatters.formatNumber(deliveredCount),
                      percentage: deliveredPercentStr,
                    ),
                    const SizedBox(height: 8),
                    _buildLegendRow(
                      color: AppColors.info,
                      label: 'Yolda / Dağıtımda',
                      count: AppFormatters.formatNumber(activeCount),
                      percentage: activePercentStr,
                    ),
                    const SizedBox(height: 8),
                    _buildLegendRow(
                      color: AppColors.warning,
                      label: 'Bekleyen / İade',
                      count: AppFormatters.formatNumber(pendingCount),
                      percentage: pendingPercentStr,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Alt Bilgi Şeridi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'Toplam Paket Hacmi: ${AppFormatters.formatNumber(totalCount)} Adet',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  successRate >= 90 ? 'Mükemmel Performans' : 'Normal Dağıtım',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: successRate >= 90 ? AppColors.secondary : AppColors.info,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double progress;
  final double deliveredRatio;
  final double activeRatio;
  final double pendingRatio;

  _DonutChartPainter({
    required this.progress,
    required this.deliveredRatio,
    required this.activeRatio,
    required this.pendingRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 9.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Arka Plan Taban Halkası (Soft Slate)
    final bgPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    if (deliveredRatio + activeRatio + pendingRatio <= 0) return;

    // Açı Hesaplamaları
    const startAngle = -math.pi / 2; // Saat 12 yönü
    final totalSweep = 2 * math.pi * progress;

    final deliveredSweep = totalSweep * deliveredRatio;
    final activeSweep = totalSweep * activeRatio;
    final pendingSweep = totalSweep * pendingRatio;

    // 1. Teslim Edilenler (Yeşil)
    if (deliveredSweep > 0) {
      final deliveredPaint = Paint()
        ..color = AppColors.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, deliveredSweep, false, deliveredPaint);
    }

    // 2. Yolda Olanlar (Mavi)
    if (activeSweep > 0) {
      final activePaint = Paint()
        ..color = AppColors.info
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle + deliveredSweep, activeSweep, false, activePaint);
    }

    // 3. Bekleyenler / Sorunlu (Turuncu)
    if (pendingSweep > 0) {
      final pendingPaint = Paint()
        ..color = AppColors.warning
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle + deliveredSweep + activeSweep, pendingSweep, false, pendingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.deliveredRatio != deliveredRatio ||
        oldDelegate.activeRatio != activeRatio ||
        oldDelegate.pendingRatio != pendingRatio;
  }
}
