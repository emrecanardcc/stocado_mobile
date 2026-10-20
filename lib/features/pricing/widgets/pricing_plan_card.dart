import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../models/pricing_plan_model.dart';

class PricingPlanCard extends StatelessWidget {
  final PricingPlan plan;

  const PricingPlanCard({
    super.key,
    required this.plan,
  });

  Widget _buildPricePill(String label, String price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            price,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(String label, bool isAvailable, {String? extra}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable ? AppColors.secondaryLight : AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAvailable ? AppColors.secondary.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded,
            size: 13,
            color: isAvailable ? AppColors.secondary : AppColors.textMuted,
          ),
          const SizedBox(width: 4),
          Text(
            extra != null ? '$label ($extra)' : label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isAvailable ? const Color(0xFF065F46) : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve Tarife Kodu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.local_shipping_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.companyName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Tarife: ${plan.tariffName}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'İade: ${plan.returnRate}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),

            // Fiyat Kademeleri Tablosu (KDV Dahil)
            const Text(
              'Desi Fiyatları (KDV Dahil):',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPricePill('0-2 Desi', AppFormatters.formatCurrency(plan.zeroTwoDesi)),
                  const SizedBox(width: 8),
                  _buildPricePill('5 Desi', AppFormatters.formatCurrency(plan.fiveDesi)),
                  const SizedBox(width: 8),
                  _buildPricePill('10 Desi', AppFormatters.formatCurrency(plan.tenDesi)),
                  const SizedBox(width: 8),
                  _buildPricePill('20 Desi', AppFormatters.formatCurrency(plan.twentyDesi)),
                  const SizedBox(width: 8),
                  _buildPricePill('30 Desi', AppFormatters.formatCurrency(plan.thirtyDesi)),
                  const SizedBox(width: 8),
                  _buildPricePill('+1 Ek Desi', AppFormatters.formatCurrency(plan.additionalDesi)),
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
                  'Kapıda Ödeme',
                  plan.hasPod,
                  extra: plan.hasPodCreditCard ? 'Nakit + Kart' : (plan.hasPod ? 'Sadece Nakit' : null),
                ),
                _buildFeatureBadge('Kontrollü Teslimat', plan.hasControlledDelivery),
                _buildFeatureBadge('Adresten Alım', plan.hasDoorPickup),
              ],
            ),

            // Açıklama / Kurallar
            if (plan.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  plan.notes,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
