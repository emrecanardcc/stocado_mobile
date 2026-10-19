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
                  onChanged: (val) {
                    if (!val) {
                      podAmountController.clear();
                    }
                    notifier.updateAdditionalServices(payOnDelivery: val);
                  },
                ),
                if (state.payOnDelivery) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  TextField(
                    controller: podAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Tahsil Edilecek Tutar (₺) *',
                      hintText: 'Örn: 250.00',
                      prefixIcon: const Icon(Icons.currency_lira),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (val) {
                      final cleanVal = val.replaceAll(',', '.').trim();
                      notifier.updateAdditionalServices(
                        payOnDeliveryAmount: double.tryParse(cleanVal) ?? 0,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text('Ödeme Türü:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
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
                  const SizedBox(height: 4),
                  Text(
                    state.payOnDeliveryType == 'credit_card'
                        ? 'ℹ️ Kapıda kredi kartı tahsilatını UPS ve Sürat Kargo desteklemektedir.'
                        : 'ℹ️ Nakit tahsilat tüm kapıda ödeme firmalarında geçerlidir.',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Kargo ücreti kapıda ödeme tutarından kesilsin', style: TextStyle(fontSize: 13)),
                    subtitle: state.receiverPays
                        ? const Text('Kapıda Alıcı Ödemeli seçildiğinde bu seçenek kullanılamaz', style: TextStyle(fontSize: 11, color: AppColors.warning))
                        : null,
                    value: state.canOffsetCargoFee,
                    onChanged: state.receiverPays
                        ? null
                        : (val) => notifier.updateAdditionalServices(canOffsetCargoFee: val ?? false),
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
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Kapıda Alıcı Ödemeli', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Kargo gönderim bedelini alıcı öder'),
                  value: state.receiverPays,
                  onChanged: (val) => notifier.updateAdditionalServices(receiverPays: val),
                ),
                if (state.receiverPays) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Text(
                      '✓ Kargo taşıma ücreti teslimat esnasında alıcıdan tahsil edilecektir.',
                      style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 3. Kontrollü Teslimat
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Kontrollü Teslimat', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Alıcı paketi açarak kontrol edebilir (Yalnızca PTT Kargo destekler)'),
                  value: state.controlledDelivery,
                  onChanged: (val) => notifier.updateAdditionalServices(controlledDelivery: val),
                ),
                if (state.controlledDelivery) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Text(
                      '✓ Kontrollü teslimat hizmeti yalnızca PTT Kargo ile sunulmaktadır. Teklif adımında PTT Kargo hesaplanacaktır.',
                      style: TextStyle(fontSize: 12, color: Colors.purple.shade900),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 4. Taslak Kargo Oluştur
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Taslak Kargo Oluştur', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Kargo taslak olarak kaydedilir, kargo firmasına anında iletilmez'),
                  value: state.isDraft,
                  onChanged: (val) => notifier.updateAdditionalServices(isDraft: val),
                ),
                if (state.isDraft) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      '✓ Kargo "Taslak" statüsünde kaydedilecek, kargo firması entegrasyonuna gönderilmeyecektir. Kargolarım ekranından istediğiniz zaman işleme alabilirsiniz.',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
