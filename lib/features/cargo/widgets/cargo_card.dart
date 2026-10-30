import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/app_formatters.dart';
import '../models/cargo_model.dart';
import 'cargo_company_logo.dart';
import 'cargo_detail_modal.dart';
import 'cargo_status_icon.dart';

class CargoCard extends StatelessWidget {
  final CargoModel cargo;

  const CargoCard({
    super.key,
    required this.cargo,
  });

  void _copyTrackingCode(BuildContext context, String code) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Takip numarası kopyalandı: $code'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receiverName = cargo.receiver?.name.trim().isNotEmpty == true
        ? cargo.receiver!.name.trim()
        : 'İsimsiz Alıcı';

    final rawCity = cargo.receiver?.city?.name.trim() ?? '';
    final rawDistrict = cargo.receiver?.district?.name.trim() ?? '';
    String cityName = '';
    if (rawDistrict.isNotEmpty && rawCity.isNotEmpty && rawDistrict != rawCity) {
      cityName = '$rawDistrict, $rawCity';
    } else if (rawCity.isNotEmpty) {
      cityName = rawCity;
    } else if (rawDistrict.isNotEmpty) {
      cityName = rawDistrict;
    } else {
      cityName = cargo.receiver?.phone ?? '-';
    }

    final trackingCode = cargo.hasCarrierBarcode
        ? cargo.outTrackingCode
        : (cargo.processNumber.isNotEmpty ? cargo.processNumber : '');

    final dateText = cargo.createdAt != null
        ? AppFormatters.formatDate(cargo.createdAt!)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => CargoDetailModal.show(context, cargo),
          onLongPress: trackingCode.isNotEmpty
              ? () => _copyTrackingCode(context, trackingCode)
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Satır: Firma Logosu + Takip No / Kopyala + Sağ Ok (Chevron)
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CargoCompanyLogo(
                            companyId: cargo.cargoCompany?.id?.toString() ?? cargo.cargoCompanyId,
                            companyName: cargo.cargoCompany?.title,
                            width: 76,
                            height: 32,
                          ),
                          const SizedBox(width: 8),
                          if (trackingCode.isNotEmpty) ...[
                            Flexible(
                              child: Text(
                                trackingCode,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Color(0xFF0F172A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => _copyTrackingCode(context, trackingCode),
                              borderRadius: BorderRadius.circular(4),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.copy_rounded,
                                  size: 14,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ] else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Kabul Bekleniyor',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2. Satır: Sol Alıcı Bilgisi & Sağ Dikkat Çekici Durum Simgesi + Tarih
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            receiverName,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            cityName.isNotEmpty ? cityName : (cargo.receiver?.phone ?? '-'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Son Hareket / Durum Rozeti (İkon yanında durum metni birlikte)
                        CargoStatusIcon(
                          cargo: cargo,
                          showLabel: true,
                        ),
                        if (dateText.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            dateText,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                // 3. Satır: Kapıda Ödeme Etiketi (Görsel mockup uyumu: Sol alt etiket)
                if (cargo.payOnDelivery) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 15,
                          color: Color(0xFF0F172A),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Kapıda Ödeme',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            AppFormatters.formatCurrency(
                              (cargo.payOnDeliveryAmount != null && cargo.payOnDeliveryAmount! > 0)
                                  ? cargo.payOnDeliveryAmount!
                                  : (cargo.payOnDeliveryNetAmount > 0
                                      ? cargo.payOnDeliveryNetAmount
                                      : 0.0),
                            ),
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (cargo.payOnDeliveryTypeText != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${cargo.payOnDeliveryTypeText})',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
