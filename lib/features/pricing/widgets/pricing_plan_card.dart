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

    final text = extra != null ? '$label ($extra)' : label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      constraints: const BoxConstraints(maxWidth: 250),
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
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;

    final p02 = plan.zeroTwoDesi > 0 ? plan.zeroTwoDesi : plan.calculatePrice(2);
    final p5 = plan.fiveDesi > 0 ? plan.fiveDesi : plan.calculatePrice(5);
    final p10 = plan.tenDesi > 0 ? plan.tenDesi : plan.calculatePrice(10);
    final p20 = plan.twentyDesi > 0 ? plan.twentyDesi : plan.calculatePrice(20);
    final p30 = plan.thirtyDesi > 0 ? plan.thirtyDesi : plan.calculatePrice(30);

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
                // Başlık: Logo + Aktif Tarife Rozeti
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Text(
                        'AKTİF TARİFE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1D4ED8),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  plan.companyName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
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
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 14),

                // Desi Fiyat Kademeleri
                const Text(
                  'Desi Fiyatları (KDV Dahil):',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildPricePill('0-2 Desi', p02),
                      const SizedBox(width: 6),
                      _buildPricePill('5 Desi', p5),
                      const SizedBox(width: 6),
                      _buildPricePill('10 Desi', p10),
                      const SizedBox(width: 6),
                      _buildPricePill('20 Desi', p20),
                      const SizedBox(width: 6),
                      _buildPricePill('30 Desi', p30),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Ek Ücretler Satırı (İade Bedeli, Artan Desi)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      // İade Bedeli
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.replay_rounded, size: 15, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'İADE BEDELİ',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textMuted,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    plan.returnRate.isNotEmpty ? plan.returnRate : '%50',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 26, color: AppColors.border),
                      const SizedBox(width: 8),
                      // Artan Desi (+1 Desi)
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.add_circle_outline_rounded, size: 15, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ARTAN DESİ (+1)',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textMuted,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    plan.additionalDesi > 0
                                        ? AppFormatters.formatCurrency(plan.additionalDesi)
                                        : '-',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Hizmet Rozetleri
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildFeatureBadge(
                      label: 'Adresten Alım',
                      isAvailable: plan.hasDoorPickup,
                      icon: Icons.home_outlined,
                      activeColor: const Color(0xFF1D4ED8),
                      activeBg: const Color(0xFFDBEAFE),
                    ),
                    _buildFeatureBadge(
                      label: 'Kapıda Ödeme',
                      isAvailable: plan.hasPod,
                      icon: Icons.payments_outlined,
                      extra: plan.hasPodCreditCard ? 'Nakit + Kart' : (plan.hasPod ? 'Sadece Nakit' : null),
                    ),
                    _buildFeatureBadge(
                      label: 'Kontrollü Teslimat',
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
                        'Kapıda Ödeme Nakit Komisyon Tablosu',
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

  Widget _buildPodTierRow(String range, String fee) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            range,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            fee,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPodCommissionTable(PricingPlan plan) {
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
                  'Tahsilat Tutarı',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Kesinti Oranı',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 9.5,
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
          _buildPodTierRow('0 - 1.000 ₺', '15,00 ₺'),
          const SizedBox(height: 4),
          _buildPodTierRow('1.001 - 5.000 ₺', '%1,50'),
          const SizedBox(height: 4),
          _buildPodTierRow('5.001 ₺ ve üzeri', '%2,00'),
          const SizedBox(height: 8),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 8),

          // Plan özelliklerine göre genel bilgi notu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  plan.hasPodCreditCard
                      ? 'Nakit ve tek çekim kredi kartı tahsilatı desteklenmektedir. ${plan.notes}'
                      : 'Yalnızca nakit tahsilat desteklenmektedir. ${plan.notes}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
