import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/create_cargo_provider.dart';

class Step3ServicesWidget extends StatelessWidget {
  final CreateCargoState state;
  final CreateCargoNotifier notifier;
  final TextEditingController podAmountController;

  const Step3ServicesWidget({
    super.key,
    required this.state,
    required this.notifier,
    required this.podAmountController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Özel Teslimat ve Hizmet Seçenekleri',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 16),

        // 1. Kapıda Ödeme
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Kapıda Ödeme', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Teslimatta tahsil edilecek tutar'),
                  value: state.payOnDelivery,
                  onChanged: (val) => notifier.updateAdditionalServices(payOnDelivery: val),
                ),
                if (state.payOnDelivery) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  TextField(
                    controller: podAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Tahsil Edilecek Tutar (₺) *',
                      prefixIcon: const Icon(Icons.currency_lira),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (val) => notifier.updateAdditionalServices(
                      payOnDeliveryAmount: double.tryParse(val) ?? 0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Ödeme Türü:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Nakit'),
                        selected: state.payOnDeliveryType == 'cash',
                        onSelected: (val) {
                          if (val) notifier.updateAdditionalServices(payOnDeliveryType: 'cash');
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Kredi Kartı'),
                        selected: state.payOnDeliveryType == 'credit_card',
                        onSelected: (val) {
                          if (val) notifier.updateAdditionalServices(payOnDeliveryType: 'credit_card');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Kargo ücreti kapıda ödeme tutarından kesilsin', style: TextStyle(fontSize: 13)),
                    value: state.canOffsetCargoFee,
                    onChanged: (val) => notifier.updateAdditionalServices(canOffsetCargoFee: val ?? false),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 2. Kapıda Alıcı Ödemeli
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SwitchListTile(
            title: const Text('Kapıda Alıcı Ödemeli', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Kargo gönderim bedelini alıcı öder'),
            value: state.receiverPays,
            onChanged: (val) => notifier.updateAdditionalServices(receiverPays: val),
          ),
        ),
        const SizedBox(height: 12),

        // 3. Kontrollü Teslimat
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SwitchListTile(
            title: const Text('Kontrollü Teslimat', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Alıcı paketi açarak kontrol edebilir (PTT vb. destekler)'),
            value: state.controlledDelivery,
            onChanged: (val) => notifier.updateAdditionalServices(controlledDelivery: val),
          ),
        ),
        const SizedBox(height: 12),

        // 4. Taslak Kargo Oluştur
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SwitchListTile(
            title: const Text('Taslak Kargo Oluştur', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Kargo taslak olarak kaydedilir, kargo firmasına anında iletilmez'),
            value: state.isDraft,
            onChanged: (val) => notifier.updateAdditionalServices(isDraft: val),
          ),
        ),
      ],
    );
  }
}
