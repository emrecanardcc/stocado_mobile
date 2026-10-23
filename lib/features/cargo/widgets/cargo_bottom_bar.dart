import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../dashboard/screens/top_up_balance_screen.dart';
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

  void _showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFD97706), // Amber-600
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _checkBalanceAndConfirm(BuildContext context, WidgetRef ref, double cargoFee) async {
    final balanceState = ref.read(dashboardProvider);
    final availableBalance = balanceState.balance?.availableBalance ??
        balanceState.balance?.balance ??
        balanceState.stats?.availableBalance ??
        0.0;

    if (availableBalance < cargoFee) {
      final choice = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFD97706), size: 22),
              SizedBox(width: 8),
              Text('Yetersiz Bakiye', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kargo taşıma ücreti (${AppFormatters.formatCurrency(cargoFee)}), cüzdan bakiyenizden (${AppFormatters.formatCurrency(availableBalance)}) yüksektir.',
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Kargonuzu oluşturabilmek için bakiye yükleyebilir veya daha sonra tamamlamak üzere "Taslak" olarak kaydedebilirsiniz.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'cancel'),
              child: const Text('Vazgeç', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx, 'draft'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Taslak Kaydet', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, 'topup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('Bakiye Yükle', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

      if (choice == 'topup') {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TopUpBalanceScreen()),
          );
        }
        return false;
      } else if (choice == 'draft') {
        notifier.toggleDraft(true);
        return true;
      } else {
        return false;
      }
    }
    return true;
  }

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
                          // 1. ADIM VALIDASYONU (Adresler & İletişim)
                          if (state.currentStep == 0) {
                            if (state.selectedSenderAddress == null) {
                              _showWarning(context, 'Lütfen kargonun çıkış yapacağı gönderici adresini seçiniz.');
                              return;
                            }

                            if (state.recipientName.trim().isEmpty) {
                              _showWarning(context, 'Lütfen alıcı ad ve soyadını giriniz.');
                              return;
                            }

                            if (state.recipientName.trim().length < 3) {
                              _showWarning(context, 'Lütfen geçerli bir alıcı ad ve soyadı giriniz (en az 3 karakter).');
                              return;
                            }

                            final phoneDigits = state.recipientPhone.replaceAll(RegExp(r'\D'), '');
                            if (phoneDigits.length < 10) {
                              _showWarning(context, 'Lütfen en az 10 haneli geçerli bir telefon numarası giriniz.');
                              return;
                            }

                            if (!phoneDigits.startsWith('5') && !phoneDigits.startsWith('05')) {
                              _showWarning(context, 'Telefon numarası geçerli bir cep telefonu formatında (5xx xxx xx xx) olmalıdır.');
                              return;
                            }

                            // E-Posta Kontrolü (Zorunlu kargo takip bildirimi doğrulaması)
                            final email = state.recipientEmail.trim();
                            if (email.isEmpty) {
                              _showWarning(context, 'Lütfen kargo takip ve teslimat bilgilendirmesi için alıcı e-posta adresini giriniz.');
                              return;
                            }

                            final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegExp.hasMatch(email)) {
                              _showWarning(context, 'Lütfen geçerli bir e-posta adresi formatı giriniz (örn: alici@gmail.com).');
                              return;
                            }

                            if (state.selectedCity == null) {
                              _showWarning(context, 'Lütfen teslimat yapılacak ili seçiniz.');
                              return;
                            }

                            if (state.selectedDistrict == null) {
                              _showWarning(context, 'Lütfen teslimat yapılacak ilçeyi seçiniz.');
                              return;
                            }

                            if (state.addressDetails.trim().isEmpty) {
                              _showWarning(context, 'Lütfen alıcı açık adresini (cadde, sokak, bina no) giriniz.');
                              return;
                            }

                            if (state.addressDetails.trim().length < 8) {
                              _showWarning(context, 'Kargonun teslim edilebilmesi için lütfen detaylı açık adres (mahalle, sokak, no) giriniz.');
                              return;
                            }
                          }

                          // 2. ADIM VALIDASYONU (Paket Bilgileri & Boyutlar)
                          if (state.currentStep == 1) {
                            if (state.desi <= 0 && state.weight <= 0 && state.width <= 0 && state.length <= 0) {
                              _showWarning(context, 'Lütfen paket desi, ağırlık veya boyut bilgilerini giriniz.');
                              return;
                            }

                            if (state.desi > 150) {
                              _showWarning(context, 'Girilen desi değeri kargo taşıma limitlerini aşmaktadır (maksimum 150 desi).');
                              return;
                            }

                            if (state.weight > 100000) {
                              _showWarning(context, 'Kargo paket ağırlığı maksimum 100 kg (100.000 gram) olabilir.');
                              return;
                            }
                          }

                          // 3. ADIM -> 4. ADIM (Ek Hizmetler & Teklif Hesaplama)
                          if (state.currentStep == 2) {
                            if (state.payOnDelivery) {
                              if (state.payOnDeliveryAmount <= 0) {
                                _showWarning(context, 'Kapıda ödeme seçildiğinde tahsil edilecek tutar en az 1 TL olmalıdır.');
                                return;
                              }
                              if (state.payOnDeliveryAmount > 30000) {
                                _showWarning(context, 'Kapıda ödeme yasal tahsilat üst sınırı 30.000 TL\'dir.');
                                return;
                              }
                            }
                            notifier.calculateOffers();
                          }

                          notifier.setStep(state.currentStep + 1);
                        } else {
                          // 4. ADIM: GÖNDERİ SUBMIT (Kargo Oluştur veya Taslak Kaydet)
                          if (!state.isDraft && state.selectedOffer == null) {
                            _showWarning(context, 'Lütfen kargonuzu taşımak için bir kargo firması teklifi seçiniz.');
                            return;
                          }

                          // Bakiye Yeterlilik Kontrolü (Alıcı ödemeli veya kapıda ödeme mahsuplu değilse)
                          if (!state.isDraft && !state.receiverPays && state.selectedOffer != null) {
                            final canProceed = await _checkBalanceAndConfirm(
                              context,
                              ref,
                              state.selectedOffer!.price,
                            );
                            if (!canProceed) return;
                          }

                          final success = await notifier.submitCargo();
                          if (!context.mounted) return;

                          if (success) {
                            final successMsg = ref.read(createCargoProvider).successMessage;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(successMsg ?? 'Kargo başarıyla oluşturuldu!'),
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
                            final error = ref.read(createCargoProvider).errorMessage;
                            final displayError = (error != null && error.trim().isNotEmpty)
                                ? error
                                : 'Kargo oluşturulamadı. Lütfen bilgilerinizi kontrol ediniz.';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(displayError),
                                backgroundColor: AppColors.error,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 4),
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
