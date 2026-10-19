import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/pricing_plan_model.dart';

class PricingPlanCard extends StatelessWidget {
  final PricingPlan plan;

  const PricingPlanCard({
    super.key,
    required this.plan,
  });

  Widget _buildPricePill(String label, String price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.blue.shade900)),
          const SizedBox(height: 2),
          Text(price, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(String label, bool isAvailable, {String? extra}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isAvailable ? Colors.green.shade200 : Colors.red.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            size: 13,
            color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            extra != null ? '$label ($extra)' : label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isAvailable ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
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
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.local_shipping, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.companyName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'İade: ${plan.returnRate}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Fiyat Kademeleri Tablosu (KDV Dahil)
            const Text(
              'Desi Fiyatları (KDV Dahil):',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPricePill('0-2 Desi', '₺ ${plan.zeroTwoDesi.toStringAsFixed(2)}'),
                  const SizedBox(width: 8),
                  _buildPricePill('5 Desi', '₺ ${plan.fiveDesi.toStringAsFixed(2)}'),
                  const SizedBox(width: 8),
                  _buildPricePill('10 Desi', '₺ ${plan.tenDesi.toStringAsFixed(2)}'),
                  const SizedBox(width: 8),
                  _buildPricePill('20 Desi', '₺ ${plan.twentyDesi.toStringAsFixed(2)}'),
                  const SizedBox(width: 8),
                  _buildPricePill('30 Desi', '₺ ${plan.thirtyDesi.toStringAsFixed(2)}'),
                  const SizedBox(width: 8),
                  _buildPricePill('+1 Ek Desi', '₺ ${plan.additionalDesi.toStringAsFixed(2)}'),
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
            const SizedBox(height: 10),

            // Açıklama / Kurallar
            if (plan.notes.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  plan.notes,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
