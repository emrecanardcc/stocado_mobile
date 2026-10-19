import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../providers/cargo_list_provider.dart';
import '../providers/create_cargo_provider.dart';

class CargoBottomBar extends ConsumerWidget {
  final CreateCargoState state;
  final CreateCargoNotifier notifier;
  final VoidCallback onClearForm;

  const CargoBottomBar({
    super.key,
    required this.state,
    required this.notifier,
    required this.onClearForm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (state.currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: state.isSubmitting ? null : () => notifier.setStep(state.currentStep - 1),
                child: const Text('Geri'),
              ),
            ),
          if (state.currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: state.isSubmitting
                  ? null
                  : () async {
                      if (state.currentStep < 3) {
                        // 1. ADIM VALIDASYONU
                        if (state.currentStep == 0) {
                          if (state.selectedSenderAddress == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lütfen bir gönderici adresi seçiniz veya yeni adres ekleyiniz.'),
                                backgroundColor: AppColors.warning,
                              ),
                            );
                            return;
                          }

                          if (state.recipientName.trim().isEmpty ||
                              state.recipientPhone.trim().isEmpty ||
                              state.selectedCity == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lütfen Alıcı Ad Soyad, Telefon ve İl seçimini yapınız.'),
                                backgroundColor: AppColors.warning,
                              ),
                            );
                            return;
                          }
                        }

                        // 3. ADIM -> 4. ADIM (Teklif Hesaplama)
                        if (state.currentStep == 2) {
                          notifier.calculateOffers();
                        }

                        notifier.setStep(state.currentStep + 1);
                      } else {
                        // GÖNDERİ SUBMIT (Kargo Oluştur veya Taslak Kaydet)
                        final success = await notifier.submitCargo();
                        if (!context.mounted) return;

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.successMessage ?? 'Kargo Başarıyla Oluşturuldu!'),
                              backgroundColor: AppColors.secondary,
                            ),
                          );
                          onClearForm();
                          notifier.reset();
                          ref.read(cargoListProvider.notifier).refresh();
                          ref.read(dashboardProvider.notifier).refresh();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.errorMessage ?? 'Kargo oluşturulamadı.'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
              child: state.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      state.currentStep == 3 ? (state.isDraft ? 'Taslağı Kaydet' : 'Kargo Oluştur') : 'İleri',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
