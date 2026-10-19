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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isHighlight ? AppColors.warning : AppColors.textPrimary,
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
              'Tekliflerim',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            TextButton.icon(
              onPressed: state.isLoadingOffers ? null : () => notifier.calculateOffers(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Teklifleri Yenile'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (state.isLoadingOffers)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Fiyat teklifleri sorgulanıyor...'),
                ],
              ),
            ),
          )
        else if (state.offers.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Column(
              children: [
                const Icon(Icons.info_outline, color: Colors.amber, size: 36),
                const SizedBox(height: 8),
                const Text(
                  'Teklifleri görmek için teklif hesaplama butonuna dokunun.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => notifier.calculateOffers(),
                  icon: const Icon(Icons.calculate_outlined),
                  label: const Text('Teklifleri Hesapla'),
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

              return Card(
                elevation: isSelected ? 3 : 1,
                color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade100,
                    child: const Icon(Icons.local_shipping, color: AppColors.primary),
                  ),
                  title: Text(
                    offer.cargoCompany.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Tahmini Teslimat: 1-3 İş Günü · ${state.desi.toStringAsFixed(1)} Desi'),
                  trailing: Text(
                    '₺${offer.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  onTap: () => notifier.selectOffer(offer),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],

        // Özet Tablosu
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gönderi Özeti',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const Divider(),
                _buildSummaryRow('Yön', state.direction == 'send' ? 'Kargo Gönder' : 'Kargo Bana Gelsin'),
                _buildSummaryRow('Gönderici Adresi', state.selectedSenderAddress?.displayName ?? '-'),
                _buildSummaryRow('Alıcı', state.recipientName.isNotEmpty ? state.recipientName : '-'),
                _buildSummaryRow('Alıcı Telefon', state.recipientPhone.isNotEmpty ? state.recipientPhone : '-'),
                _buildSummaryRow('Hedef', '${state.selectedDistrict?.name ?? ""}, ${state.selectedCity?.name ?? ""}'),
                _buildSummaryRow('Desi', '${state.desi.toStringAsFixed(2)} Desi'),
                if (state.payOnDelivery)
                  _buildSummaryRow('Kapıda Ödeme', '₺${state.payOnDeliveryAmount.toStringAsFixed(2)}', isHighlight: true),
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
        ),
      ],
    );
  }
}
