import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../models/cargo_model.dart';
import 'cargo_company_logo.dart';
import 'cargo_detail_modal.dart';
import 'cargo_status_badge.dart';

class CargoCard extends StatelessWidget {
  final CargoModel cargo;

  const CargoCard({
    super.key,
    required this.cargo,
  });

  @override
  Widget build(BuildContext context) {
    final receiverName = cargo.receiver?.name ?? 'İsimsiz Alıcı';
    final receiverInitials = receiverName.isNotEmpty
        ? receiverName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'AK';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => CargoDetailModal.show(context, cargo),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Satır: Kargo Taşıyıcı Rozeti ve Durum Rozeti
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Taşıyıcı Firma ve Oluşturulma Tarihi
                Row(
                  children: [
                    CargoCompanyLogo(
                      companyId: cargo.cargoCompany?.id?.toString(),
                      companyName: cargo.cargoCompany?.title,
                      size: 28,
                      borderRadius: 6,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cargo.cargoCompany?.title ?? 'Kargo',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cargo.createdAt != null
                              ? AppFormatters.formatDateTime(cargo.createdAt!)
                              : '-',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Son Hareket Rozeti
                CargoStatusBadge(
                  status: cargo.status,
                  statusText: cargo.latestActionTitle,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),

            // 2. Satır: Alıcı Bilgileri
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceSecondary,
                  child: Text(
                    receiverInitials.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receiverName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (cargo.receiver?.phone.isNotEmpty ?? false) ...[
                            InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Clipboard.setData(ClipboardData(text: cargo.receiver!.phone));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Telefon kopyalandı: ${cargo.receiver!.phone}'),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.phone_outlined, size: 12, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    cargo.receiver!.phone,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          if (cargo.receiver?.city != null) ...[
                            const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                '${cargo.receiver!.city!.name}${cargo.receiver?.district != null ? ' / ${cargo.receiver!.district!.name}' : ''}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 3. Satır: Barkod / Takip Kodu Kutusu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_2_rounded, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: cargo.hasCarrierBarcode
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      cargo.outTrackingCode,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (cargo.processNumber.isNotEmpty && cargo.processNumber != cargo.outTrackingCode)
                                      Text(
                                        'Ref: ${cargo.processNumber}',
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: AppColors.border.withValues(alpha: 0.6),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Kabul bekleniyor',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (cargo.processNumber.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2.0),
                                        child: Text(
                                          'Ref: ${cargo.processNumber}',
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: AppColors.textPrimary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final textToCopy = cargo.hasCarrierBarcode
                          ? cargo.outTrackingCode
                          : cargo.processNumber;
                      Clipboard.setData(ClipboardData(text: textToCopy));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            cargo.hasCarrierBarcode
                                ? 'Taşıyıcı takip numarası kopyalandı'
                                : 'Referans barkod numarası kopyalandı',
                          ),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        children: [
                          Icon(Icons.copy_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Kopyala',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Kapıda Ödeme Detay Şeridi (Varsa)
            if (cargo.payOnDelivery) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warningLight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.payments_outlined, size: 16, color: Color(0xFFB45309)),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'K.Ö. Net: ${AppFormatters.formatCurrency(cargo.payOnDeliveryNetAmount)}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (cargo.payOnDeliveryTypeText != null) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '(${cargo.payOnDeliveryTypeText})',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFFB45309), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (cargo.payOnDeliveryStatusText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              cargo.payOnDeliveryStatusText!,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                            ),
                          ),
                      ],
                    ),
                    if (cargo.payOnDeliveryCost != null || cargo.payOnDeliveryOffsetDate != null) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 10,
                        runSpacing: 2,
                        children: [
                          if (cargo.payOnDeliveryAmount != null && cargo.payOnDeliveryCost != null && cargo.payOnDeliveryCost! > 0)
                            Text(
                              'Tahsilat: ${AppFormatters.formatCurrency(cargo.payOnDeliveryAmount)} (Kesinti: ${AppFormatters.formatCurrency(cargo.payOnDeliveryCost)})',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF92400E), fontWeight: FontWeight.w500),
                            ),
                          if (cargo.payOnDeliveryOffsetDate != null)
                            Text(
                              'Tahmini Aktarım: ${AppFormatters.formatDateTime(cargo.payOnDeliveryOffsetDate)}',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Son Hareket Açıklaması (Web Portali ile Tam Parite)
            Builder(
              builder: (context) {
                final actionTitle = cargo.latestActionTitle;
                final actionDesc = cargo.latestTransaction?.description.trim();
                final location = cargo.latestTransaction?.location?.trim();
                String? latestText;

                if (actionTitle.isNotEmpty) {
                  latestText = actionTitle;
                  if (location != null && location.isNotEmpty && !actionTitle.toLowerCase().contains(location.toLowerCase())) {
                    latestText = '$actionTitle ($location)';
                  }
                } else if (actionDesc != null && actionDesc.isNotEmpty) {
                  latestText = actionDesc;
                  if (location != null && location.isNotEmpty && !actionDesc.toLowerCase().contains(location.toLowerCase())) {
                    latestText = '$actionDesc ($location)';
                  }
                }

                if (latestText == null || latestText.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Son Hareket: $latestText',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  ),
);
  }
}
