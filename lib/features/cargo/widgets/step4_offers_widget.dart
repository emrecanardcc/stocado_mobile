import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/create_cargo_provider.dart';

class Step4OffersWidget extends StatelessWidget {
  final CreateCargoState state;
  final CreateCargoNotifier notifier;

  const Step4OffersWidget({
    super.key,
    required this.state,
    required this.notifier,
  });

  Widget _buildSummaryRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
                color: isHighlight ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Firma Teklifleri',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            TextButton.icon(
              onPressed: state.isLoadingOffers ? null : () => notifier.calculateOffers(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Yenile'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (state.isLoadingOffers)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
                  SizedBox(height: 14),
                  Text(
                    'Anlık kargo teklifleri hesaplanıyor...',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else if (state.offers.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.warningLight,
                  ),
                  child: const Icon(Icons.calculate_outlined, color: AppColors.warning, size: 32),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Teklifleri Görmek İçin Hesaplayın',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Girdiğiniz paket ölçüleri ve adreslere göre firmaların fiyat tekliflerini anında getirin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => notifier.calculateOffers(),
                  icon: const Icon(Icons.bolt, size: 18),
                  label: const Text('Teklifleri Hesapla'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(200, 44),
                  ),
                ),
              ],
            ),
          )
        else ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.offers.length,
            itemBuilder: (context, index) {
              final offer = state.offers[index];
              final isSelected = state.selectedOffer?.cargoCompany.id == offer.cargoCompany.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: const BoxDecoration(
                  boxShadow: AppColors.softShadow,
                ),
                child: Material(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.04) : AppColors.surface,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => notifier.selectOffer(offer),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceSecondary,
                            ),
                            child: Icon(
                              Icons.local_shipping_rounded,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  offer.cargoCompany.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tahmini 1-3 İş Günü • ${state.desi.toStringAsFixed(1)} Desi',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₺${offer.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                color: isSelected ? AppColors.primary : AppColors.textMuted,
                                size: 22,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
        ],

        // Özet Tablosu
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.assignment_outlined, size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Gönderi Özeti',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 8),
              _buildSummaryRow('Yön', state.direction == 'send' ? 'Kargo Gönder' : 'Kargo Bana Gelsin'),
              _buildSummaryRow('Gönderici Adresi', state.selectedSenderAddress?.displayName ?? '-'),
              _buildSummaryRow('Alıcı', state.recipientName.isNotEmpty ? state.recipientName : '-'),
              _buildSummaryRow('Alıcı Telefon', state.recipientPhone.isNotEmpty ? state.recipientPhone : '-'),
              _buildSummaryRow('Hedef', '${state.selectedDistrict?.name ?? ""}, ${state.selectedCity?.name ?? ""}'),
              _buildSummaryRow('Desi', '${state.desi.toStringAsFixed(2)} Desi'),
              if (state.payOnDelivery) ...[
                _buildSummaryRow(
                  'Kapıda Ödeme',
                  '₺${state.payOnDeliveryAmount.toStringAsFixed(2)} (${state.payOnDeliveryType == 'cash' ? 'Nakit' : 'Kredi Kartı'})',
                  isHighlight: true,
                ),
                if (state.canOffsetCargoFee)
                  _buildSummaryRow('Kargo Ücreti Mahsubu', 'Kapıda ödemeden kesilecek'),
              ],
              if (state.receiverPays)
                _buildSummaryRow('Ödeme Şekli', 'Kapıda Alıcı Ödemeli', isHighlight: true),
              if (state.controlledDelivery)
                _buildSummaryRow('Özel Hizmet', 'Kontrollü Teslimat (PTT)', isHighlight: true),
              if (state.selectedOffer != null)
                _buildSummaryRow(
                  'Seçili Firma',
                  '${state.selectedOffer!.cargoCompany.title} (₺${state.selectedOffer!.price.toStringAsFixed(2)})',
                  isHighlight: true,
                ),
              _buildSummaryRow('Kargo Durumu', state.isDraft ? 'Taslak Olarak Kaydedilecek' : 'Aktif Kargo Oluşturulacak'),
            ],
          ),
        ),
      ],
    );
  }
}
