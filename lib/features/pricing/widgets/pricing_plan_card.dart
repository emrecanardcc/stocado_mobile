import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../../cargo/widgets/cargo_company_logo.dart';
import '../models/pricing_plan_model.dart';

class PricingPlanCard extends StatefulWidget {
  final PricingPlan plan;

  const PricingPlanCard({
    super.key,
    required this.plan,
  });

  @override
  State<PricingPlanCard> createState() => _PricingPlanCardState();
}

class _PricingPlanCardState extends State<PricingPlanCard> {
  bool _podExpanded = false;

  Widget _buildPricePill(String label, double price) {
    final hasPrice = price > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: hasPrice ? AppColors.primary.withValues(alpha: 0.05) : AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasPrice ? AppColors.primary.withValues(alpha: 0.18) : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            hasPrice ? AppFormatters.formatCurrency(price) : '-',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: hasPrice ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge({
    required String label,
    required bool isAvailable,
    required IconData icon,
    String? extra,
    Color? activeColor,
    Color? activeBg,
  }) {
    final color = isAvailable ? (activeColor ?? const Color(0xFF065F46)) : AppColors.textMuted;
    final bg = isAvailable ? (activeBg ?? AppColors.secondaryLight) : AppColors.surfaceSecondary;
    final borderColor = isAvailable
        ? (activeColor ?? AppColors.secondary).withValues(alpha: 0.3)
        : AppColors.border;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? icon : Icons.remove_circle_outline_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            extra != null ? '$label ($extra)' : label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık: Logo + Şirket + Tarife
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CargoCompanyLogo(
                      companyId: plan.code,
                      companyName: plan.companyName,
                      height: 22,
                      width: 90,
                    ),
                    const Spacer(),
                    // İade Oranı Rozeti
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        'Iade: ${plan.returnRate}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  plan.companyName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                if (plan.tariffName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Tarife: ${plan.tariffName}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 14),

                // Desi Fiyat Kademeleri
                const Text(
                  'Desi Fiyatlari (KDV Dahil):',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildPricePill('0-2 Desi', plan.zeroTwoDesi),
                      const SizedBox(width: 6),
                      _buildPricePill('5 Desi', plan.fiveDesi),
                      const SizedBox(width: 6),
                      _buildPricePill('10 Desi', plan.tenDesi),
                      const SizedBox(width: 6),
                      _buildPricePill('20 Desi', plan.twentyDesi),
                      const SizedBox(width: 6),
                      _buildPricePill('30 Desi', plan.thirtyDesi),
                      if (plan.additionalDesi > 0) ...[
                        const SizedBox(width: 6),
                        _buildPricePill('+1 Ek Desi', plan.additionalDesi),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Hizmet Rozetleri
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildFeatureBadge(
                      label: 'Adresten Alim',
                      isAvailable: plan.hasDoorPickup,
                      icon: Icons.home_outlined,
                      activeColor: const Color(0xFF1D4ED8),
                      activeBg: const Color(0xFFDBEAFE),
                    ),
                    _buildFeatureBadge(
                      label: 'Kapida Odeme',
                      isAvailable: plan.hasPod,
                      icon: Icons.payments_outlined,
                      extra: plan.hasPodCreditCard ? 'Nakit + Kart' : (plan.hasPod ? 'Sadece Nakit' : null),
                    ),
                    _buildFeatureBadge(
                      label: 'Kontrollu Teslimat',
                      isAvailable: plan.hasControlledDelivery,
                      icon: Icons.verified_outlined,
                      activeColor: const Color(0xFF7C3AED),
                      activeBg: const Color(0xFFEDE9FE),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Kapıda Ödeme Komisyon Tablosu (genişletilebilir)
          if (plan.hasPod) ...[
            const Divider(color: AppColors.border, height: 1, indent: 0, endIndent: 0),
            InkWell(
              onTap: () => setState(() => _podExpanded = !_podExpanded),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Kapida Odeme Nakit Komisyon Tablosu',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Icon(
                      _podExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            if (_podExpanded) _buildPodCommissionTable(plan),
          ],
        ],
      ),
    );
  }

  Widget _buildPodCommissionTable(PricingPlan plan) {
    // Statik komisyon satırları (plan notlarından türetilmiş) — gerçek veri
    // API'den gelen plan modelinde dinamik POD komisyon tablosu mevcut değil,
    // bu yüzden hasPod bilgisini ve plan notlarını kullanıyoruz.
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tablo Başlıkları
          const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Tahsilat Tutari',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Kesinti',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 6),

          // Plan özelliklerine göre genel bilgi notu
          Text(
            plan.hasPodCreditCard
                ? 'Nakit ve kredi karti tahsilati desteklenmektedir. Kesin komisyon oranlari icin Stocado ekibiyle iletisime gecin.'
                : 'Yalnizca nakit tahsilat desteklenmektedir. Kesin komisyon oranlari icin Stocado ekibiyle iletisime gecin.',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
