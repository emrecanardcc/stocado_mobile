import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../../cargo/models/cargo_model.dart';
import '../../cargo/providers/cargo_list_provider.dart';
import '../../cargo/widgets/cargo_company_logo.dart';
import '../../cargo/widgets/cargo_detail_modal.dart';
import '../../cargo/widgets/cargo_status_icon.dart';

class DashboardRecentCargosSection extends ConsumerWidget {
  final VoidCallback onSeeAllTap;
  final VoidCallback onNewCargoTap;

  const DashboardRecentCargosSection({
    super.key,
    required this.onSeeAllTap,
    required this.onNewCargoTap,
  });

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
                  companyId: cargo.cargoCompany?.id?.toString() ?? cargo.cargoCompanyId,
                  companyName: cargo.cargoCompany?.title,
                  width: 76,
                  height: 32,
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
                    CargoStatusIcon(cargo: cargo, showLabel: true),
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
    // Son Gönderiler her zaman filtrelenmemiş en son kargoları gösterir (Kargolarım filtrelerinden etkilenmez)
    final displayItems = cargoListState.recentCargos.isNotEmpty
        ? cargoListState.recentCargos
        : (!cargoListState.hasActiveFilters && cargoListState.activeTab == 'all'
            ? cargoListState.cargos
            : const <CargoModel>[]);
    final recentItems = displayItems.take(4).toList();

    if (cargoListState.recentCargos.isEmpty && !cargoListState.isLoading) {
      Future.microtask(() => ref.read(cargoListProvider.notifier).loadRecentCargos());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık ve 'Tümünü Gör >'
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Son Gönderiler',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0E1E38),
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
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
        if (cargoListState.isLoading && recentItems.isEmpty)
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
        else if (recentItems.isEmpty)
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
