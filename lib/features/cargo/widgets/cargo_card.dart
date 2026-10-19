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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Satır: Alıcı Avatarı, Adı ve Durum Rozeti
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          receiverInitials.toUpperCase(),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              receiverName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (cargo.receiver?.phone.isNotEmpty ?? false)
                              Text(
                                cargo.receiver!.phone,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                CargoStatusBadge(
                  status: cargo.status,
                  statusText: cargo.statusText,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // 2. Satır: Barkod ve Kargo Şirketi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Barkod
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code_2, size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          cargo.outTrackingCode.isNotEmpty ? cargo.outTrackingCode : cargo.processNumber,
                          style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16, color: AppColors.textSecondary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Barkodu Kopyala',
                        onPressed: () {
                          final code = cargo.outTrackingCode.isNotEmpty ? cargo.outTrackingCode : cargo.processNumber;
                          Clipboard.setData(ClipboardData(text: code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Barkod kopyalandı!'), duration: Duration(seconds: 1)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Kargo Şirketi
                if (cargo.cargoCompany != null)
                  Row(
                    children: [
                      const Icon(Icons.local_shipping, size: 18, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        cargo.cargoCompany!.title,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
              ],
            ),

            // 3. Satır: Şehir / İlçe ve Ek Rozetler
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (cargo.receiver?.city != null)
                  Text(
                    '${cargo.receiver!.city!.name}${cargo.receiver?.district != null ? ' / ${cargo.receiver!.district!.name}' : ''}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  )
                else
                  const SizedBox(),
              ],
            ),

            // Kapıda Ödeme Detay Şeridi (Varsa)
            if (cargo.payOnDelivery) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.payments_outlined, size: 16, color: Colors.amber.shade800),
                        const SizedBox(width: 6),
                        Text(
                          'K.Ö: ₺ ${cargo.payOnDeliveryAmount?.toStringAsFixed(2) ?? '0,00'}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                        ),
                        if (cargo.payOnDeliveryTypeText != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '(${cargo.payOnDeliveryTypeText})',
                            style: TextStyle(fontSize: 11, color: Colors.amber.shade800),
                          ),
                        ],
                      ],
                    ),
                    if (cargo.payOnDeliveryStatusText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Text(
                          cargo.payOnDeliveryStatusText!,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Son Hareket: ${cargo.latestTransaction!.description}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
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
