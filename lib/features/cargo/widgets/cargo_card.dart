import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../models/cargo_model.dart';
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

    final trackingCode = cargo.outTrackingCode.isNotEmpty ? cargo.outTrackingCode : cargo.processNumber;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Satır: Kargo Taşıyıcı Rozeti ve Durum Rozeti
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Taşıyıcı Firma
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.local_shipping_rounded, size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cargo.cargoCompany?.title ?? 'Kargo',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                // Durum Rozeti
                CargoStatusBadge(
                  status: cargo.status,
                  statusText: cargo.statusText,
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
                            const Icon(Icons.phone_outlined, size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              cargo.receiver!.phone,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                  Row(
                    children: [
                      const Icon(Icons.qr_code_2_rounded, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        trackingCode,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: trackingCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Takip numarası panoya kopyalandı'),
                          duration: Duration(seconds: 1),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.payments_outlined, size: 16, color: Color(0xFFB45309)),
                        const SizedBox(width: 6),
                        Text(
                          'K.Ö: ₺ ${cargo.payOnDeliveryAmount?.toStringAsFixed(2) ?? '0,00'}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                        ),
                        if (cargo.payOnDeliveryTypeText != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '(${cargo.payOnDeliveryTypeText})',
                            style: const TextStyle(fontSize: 11, color: Color(0xFFB45309), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ],
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
              ),
            ],

            // Son Hareket Açıklaması (Varsa)
            if (cargo.latestTransaction != null && cargo.latestTransaction!.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
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
                        'Son Hareket: ${cargo.latestTransaction!.description}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
