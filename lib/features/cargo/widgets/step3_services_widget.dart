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

  Widget _buildServiceCard({
    required Widget child,
    bool isHighlighted = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
          width: 1,
        ),
        boxShadow: AppColors.softShadow,
      ),
      padding: const EdgeInsets.all(16.0),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Özel Teslimat ve Hizmet Seçenekleri',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),

        // 1. Kapıda Ödeme
        _buildServiceCard(
          isHighlighted: state.payOnDelivery,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primary,
                secondary: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.warningLight,
                  ),
                  child: const Icon(Icons.payments_outlined, color: AppColors.warning, size: 20),
                ),
                title: const Text(
                  'Kapıda Ödeme',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                ),
                subtitle: const Text(
                  'Teslimatta alıcıdan tahsil edilecek tutar',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                value: state.payOnDelivery,
                onChanged: (val) {
                  if (!val) {
                    podAmountController.clear();
                  }
                  notifier.updateAdditionalServices(payOnDelivery: val);
                },
              ),
              if (state.payOnDelivery) ...[
                const SizedBox(height: 8),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
                TextField(
                  controller: podAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Tahsil Edilecek Tutar (₺) *',
                    hintText: 'Örn: 250.00',
                    prefixIcon: const Icon(Icons.currency_lira_rounded, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) {
                    final cleanVal = val.replaceAll(',', '.').trim();
                    notifier.updateAdditionalServices(
                      payOnDeliveryAmount: double.tryParse(cleanVal) ?? 0,
                    );
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ödeme Türü:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Nakit'),
                      selected: state.payOnDeliveryType == 'cash',
                      selectedColor: AppColors.primary.withValues(alpha: 0.12),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: state.payOnDeliveryType == 'cash' ? AppColors.primary : AppColors.textSecondary,
                      ),
                      onSelected: (val) {
                        if (val) notifier.updateAdditionalServices(payOnDeliveryType: 'cash');
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Kredi Kartı'),
                      selected: state.payOnDeliveryType == 'credit_card',
                      selectedColor: AppColors.primary.withValues(alpha: 0.12),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: state.payOnDeliveryType == 'credit_card' ? AppColors.primary : AppColors.textSecondary,
                      ),
                      onSelected: (val) {
                        if (val) notifier.updateAdditionalServices(payOnDeliveryType: 'credit_card');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  state.payOnDeliveryType == 'credit_card'
                      ? 'ℹ️ Kapıda kredi kartı tahsilatını UPS ve Sürat Kargo desteklemektedir.'
                      : 'ℹ️ Nakit tahsilat tüm kapıda ödeme firmalarında geçerlidir.',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                  title: const Text(
                    'Kargo ücreti kapıda ödeme tutarından kesilsin',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  subtitle: state.receiverPays
                      ? const Text(
                          'Kapıda Alıcı Ödemeli seçildiğinde bu seçenek kullanılamaz',
                          style: TextStyle(fontSize: 11, color: AppColors.warning),
                        )
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
        const SizedBox(height: 12),

        // 2. Kapıda Alıcı Ödemeli
        _buildServiceCard(
          isHighlighted: state.receiverPays,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primary,
                secondary: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.infoLight,
                  ),
                  child: const Icon(Icons.hail_rounded, color: AppColors.info, size: 20),
                ),
                title: const Text(
                  'Kapıda Alıcı Ödemeli',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                ),
                subtitle: const Text(
                  'Kargo gönderim bedelini alıcı öder',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                value: state.receiverPays,
                onChanged: (val) => notifier.updateAdditionalServices(receiverPays: val),
              ),
              if (state.receiverPays) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    '✓ Kargo taşıma ücreti teslimat esnasında alıcıdan tahsil edilecektir.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 3. Kontrollü Teslimat
        _buildServiceCard(
          isHighlighted: state.controlledDelivery,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primary,
                secondary: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF3E8FF),
                  ),
                  child: const Icon(Icons.verified_outlined, color: Colors.purple, size: 20),
                ),
                title: const Text(
                  'Kontrollü Teslimat',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                ),
                subtitle: const Text(
                  'Alıcı paketi açarak kontrol edebilir (Yalnızca PTT Kargo)',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                value: state.controlledDelivery,
                onChanged: (val) => notifier.updateAdditionalServices(controlledDelivery: val),
              ),
              if (state.controlledDelivery) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF5FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    '✓ Kontrollü teslimat hizmeti yalnızca PTT Kargo ile sunulmaktadır. Teklif adımında PTT Kargo filtrelenecektir.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B21A8), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 4. Taslak Kargo Oluştur
        _buildServiceCard(
          isHighlighted: state.isDraft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primary,
                secondary: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceSecondary,
                  ),
                  child: const Icon(Icons.drafts_outlined, color: AppColors.textSecondary, size: 20),
                ),
                title: const Text(
                  'Taslak Kargo Oluştur',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                ),
                subtitle: const Text(
                  'Kargo taslak olarak kaydedilir, firmaya anında iletilmez',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                value: state.isDraft,
                onChanged: (val) => notifier.updateAdditionalServices(isDraft: val),
              ),
              if (state.isDraft) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    '✓ Kargo "Taslak" statüsünde kaydedilecek, kargo firması entegrasyonuna gönderilmeyecektir. Kargolarım sekmesinden istediğiniz zaman işleme alabilirsiniz.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
