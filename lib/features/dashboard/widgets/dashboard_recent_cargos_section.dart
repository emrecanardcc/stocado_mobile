import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../../cargo/models/cargo_model.dart';
import '../../cargo/providers/cargo_list_provider.dart';
import '../../cargo/widgets/cargo_company_logo.dart';
import '../../cargo/widgets/cargo_detail_modal.dart';

class DashboardRecentCargosSection extends ConsumerWidget {
  final VoidCallback onSeeAllTap;
  final VoidCallback onNewCargoTap;

  const DashboardRecentCargosSection({
    super.key,
    required this.onSeeAllTap,
    required this.onNewCargoTap,
  });

  Widget _buildStatusPill(CargoModel cargo) {
    String statusText;
    final type = cargo.effectiveTransactionType;
    if (type == 6 || (cargo.status == 2 && cargo.latestActionTitle.toLowerCase().contains('teslim'))) {
      statusText = 'Teslim Edildi';
    } else if (type == 5) {
      statusText = 'Dağıtımda';
    } else if (type != null && [2, 3, 4, 9].contains(type)) {
      statusText = 'Yolda';
    } else if (type != null && [10, 11].contains(type)) {
      statusText = 'İade';
    } else if (type != null && [0, 7, 12, 13].contains(type)) {
      statusText = cargo.latestActionTitle.isNotEmpty ? cargo.latestActionTitle : 'Sorunlu';
    } else {
      statusText = cargo.latestActionTitle.isNotEmpty ? cargo.latestActionTitle : cargo.statusText;
    }

    final lower = statusText.toLowerCase();

    Color bgColor;
    Color textColor;
    IconData icon;

    if (lower.contains('teslim')) {
      bgColor = const Color(0xFFDCFCE7); // Emerald-100
      textColor = const Color(0xFF15803D); // Emerald-700
      icon = Icons.check_circle_rounded;
    } else if (lower.contains('sorun') || lower.contains('iade') || lower.contains('hata') || lower.contains('iptal') || cargo.status == 3) {
      bgColor = const Color(0xFFFFEDD5); // Orange-100
      textColor = const Color(0xFFC2410C); // Orange-700
      icon = Icons.warning_amber_rounded;
    } else if (lower.contains('dağıtım') || lower.contains('dagitim')) {
      bgColor = const Color(0xFFDBEAFE); // Blue-100
      textColor = const Color(0xFF1D4ED8); // Blue-700
      icon = Icons.local_shipping_outlined;
    } else {
      // Yolda / Gönderime Hazır
      bgColor = const Color(0xFFEFF6FF); // Sky-100
      textColor = const Color(0xFF2563EB); // Sky-700
      icon = Icons.local_shipping_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentCard(BuildContext context, CargoModel cargo) {
    final receiverName = cargo.receiver?.name ?? 'İsimsiz Alıcı';
    final cityName = cargo.receiver?.city?.name ?? '';
    final trackingCode = cargo.hasCarrierBarcode ? cargo.outTrackingCode : cargo.processNumber;
    final formattedDate = cargo.createdAt != null ? AppFormatters.formatDate(cargo.createdAt!) : '';
    final List<String> details = [];
    if (cityName.isNotEmpty) details.add(cityName);
    if (formattedDate.isNotEmpty) details.add(formattedDate);
    if (trackingCode.isNotEmpty) details.add(trackingCode);
    final subtitle = details.join(' • ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => CargoDetailModal.show(context, cargo),
          onLongPress: trackingCode.isNotEmpty
              ? () {
                  try {
                    Clipboard.setData(ClipboardData(text: trackingCode));
                    HapticFeedback.lightImpact();
                  } catch (_) {}
                  final messenger = ScaffoldMessenger.maybeOf(context);
                  messenger?.clearSnackBars();
                  messenger?.showSnackBar(
                    const SnackBar(
                      content: Text('Takip numarası kopyalandı.'),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              : null,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Sol: Taşıyıcı Kargo Firması Logosu
                CargoCompanyLogo(
                  companyId: cargo.cargoCompany?.id?.toString(),
                  companyName: cargo.cargoCompany?.title,
                  size: 34,
                  borderRadius: 8,
                  showBorder: false,
                ),
                const SizedBox(width: 12),

                // Orta: Alıcı Adı ve Şehir • Tarih • Takip No
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        receiverName,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0E1E38),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Sağ: Durum Rozeti ve Sağ Ok
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatusPill(cargo),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cargoListState = ref.watch(cargoListProvider);
    final cargos = cargoListState.cargos;
    final recentItems = cargos.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık ve 'Tümünü Gör >'
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Son Gönderiler',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0E1E38),
                letterSpacing: -0.2,
              ),
            ),
            InkWell(
              onTap: onSeeAllTap,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Text(
                      'Tümünü Gör',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Color(0xFF2563EB),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Yüklenme veya İçerik Durumu
        if (cargoListState.isLoading && cargos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.primary),
              ),
            ),
          )
        else if (cargos.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  size: 32,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Henüz kayıtlı gönderiniz bulunmuyor',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: onNewCargoTap,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Yeni Kargo Oluştur', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
              ],
            ),
          )
        else
          ...recentItems.map((cargo) => _buildShipmentCard(context, cargo)),
      ],
    );
  }
}
