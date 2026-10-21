import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../home/providers/navigation_provider.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: AppColors.softShadow,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (state.currentStep > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.isSubmitting ? null : () => notifier.setStep(state.currentStep - 1),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('Geri'),
                ),
              ),
            if (state.currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
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
                                  behavior: SnackBarBehavior.floating,
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
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                          }

                          // 2. ADIM VALIDASYONU (Paket Bilgileri)
                          if (state.currentStep == 1) {
                            if (state.desi <= 0 && state.weight <= 0 && state.width <= 0 && state.length <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Lütfen paket desi, ağırlık veya boyut bilgilerini giriniz.'),
                                  backgroundColor: AppColors.warning,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                          }

                          // 3. ADIM -> 4. ADIM (Teklif Hesaplama)
                          if (state.currentStep == 2) {
                            if (state.payOnDelivery && state.payOnDeliveryAmount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Lütfen kapıda ödeme tahsilat tutarını giriniz.'),
                                  backgroundColor: AppColors.warning,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            notifier.calculateOffers();
                          }

                          notifier.setStep(state.currentStep + 1);
                        } else {
                          // GÖNDERİ SUBMIT (Kargo Oluştur veya Taslak Kaydet)
                          if (!state.isDraft && state.selectedOffer == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lütfen bir kargo firması teklifi seçiniz veya teklifleri hesaplayınız.'),
                                backgroundColor: AppColors.warning,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          final success = await notifier.submitCargo();
                          if (!context.mounted) return;

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.successMessage ?? 'Kargo başarıyla oluşturuldu!'),
                                backgroundColor: AppColors.secondary,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            onClearForm();
                            notifier.reset();
                            ref.read(cargoListProvider.notifier).refresh();
                            ref.read(dashboardProvider.notifier).refresh();
                            ref.read(mainNavigationProvider.notifier).selectTab(1);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.errorMessage ?? 'Kargo oluşturulamadı.'),
                                backgroundColor: AppColors.error,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                icon: state.isSubmitting
                    ? const SizedBox.shrink()
                    : Icon(
                        state.currentStep == 3 ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                label: state.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        state.currentStep == 3
                            ? (state.isDraft ? 'Taslağı Kaydet' : 'Kargo Oluştur')
                            : 'İleri Adım',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
