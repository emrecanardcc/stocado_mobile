import 'package:flutter/material.dart';
import '../models/cargo_model.dart';

/// Kargo durumunu tek bakışta anlatan, canlı renklere sahip durum rozeti/simgesi.
/// [showLabel] = true olduğunda referans tasarımdaki gibi ikon yanında durum metniyle
/// birlikte şık kapsül (pill) rozet olarak render edilir.
class CargoStatusIcon extends StatelessWidget {
  final CargoModel cargo;
  final double size;
  final bool showLabel;

  const CargoStatusIcon({
    super.key,
    required this.cargo,
    this.size = 36.0,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final info = _resolveStatus(cargo);

    if (showLabel) {
      return Tooltip(
        message: info.tooltip,
        preferBelow: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
          decoration: BoxDecoration(
            color: info.pillBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: info.pillBorderColor, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                info.pillIcon,
                size: 13.5,
                color: info.pillTextColor,
              ),
              const SizedBox(width: 4.5),
              Text(
                info.label,
                style: TextStyle(
                  color: info.pillTextColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Tooltip(
      message: info.tooltip,
      preferBelow: false,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: info.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: info.color.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            info.icon,
            color: Colors.white,
            size: size * 0.54,
          ),
        ),
      ),
    );
  }

  static _StatusInfo _resolveStatus(CargoModel cargo) {
    final type = cargo.effectiveTransactionType;
    final actionTitle = cargo.latestActionTitle.trim();
    final lowerTitle = actionTitle.toLowerCase();
    final status = cargo.status;

    // 1. Teslim Edildi
    final isDeliveredTitle = (lowerTitle.contains('teslim edildi') && !lowerTitle.contains('edilemedi')) ||
        lowerTitle.contains('tamamlandı') ||
        lowerTitle.contains('tamamlan');
    if (type == 6 || (type == null && status == 2) || isDeliveredTitle) {
      return _StatusInfo(
        color: const Color(0xFF10B981), // Canlı Yeşil (Emerald 500)
        icon: Icons.check_rounded,
        pillBgColor: const Color(0xFFDCFCE7), // Açık Yeşil Zemin
        pillBorderColor: const Color(0xFFBBF7D0),
        pillTextColor: const Color(0xFF15803D), // Koyu Yeşil Metin & İkon
        pillIcon: Icons.check_circle_rounded,
        label: 'Teslim Edildi',
        tooltip: actionTitle.isNotEmpty ? actionTitle : 'Teslim Edildi',
      );
    }

    // 2. Dağıtımda (Kuryede / Son Teslimat Aşaması)
    if (type == 5 ||
        lowerTitle.contains('dağıtım') ||
        lowerTitle.contains('dagitim') ||
        lowerTitle.contains('kurye')) {
      return _StatusInfo(
        color: const Color(0xFF0284C7), // Canlı Açık Mavi / Turkuaz (Sky 600)
        icon: Icons.delivery_dining_rounded,
        pillBgColor: const Color(0xFFE0F2FE), // Açık Mavi Zemin
        pillBorderColor: const Color(0xFFBAE6FD),
        pillTextColor: const Color(0xFF0369A1), // Mavi Metin & İkon
        pillIcon: Icons.delivery_dining_rounded, // Kurye ikonu
        label: 'Dağıtımda',
        tooltip: actionTitle.isNotEmpty ? actionTitle : 'Dağıtımda',
      );
    }

    // 3. Sorunlu / İade / İptal / Teslim Edilemedi
    if ((type != null && [0, 7, 8, 10, 11, 12, 13].contains(type)) ||
        (type == null && (status == 3 || status == 4)) ||
        lowerTitle.contains('sorun') ||
        lowerTitle.contains('iade') ||
        lowerTitle.contains('iptal') ||
        lowerTitle.contains('hata') ||
        lowerTitle.contains('edilemedi') ||
        lowerTitle.contains('posta')) {
      final isReturn = (type != null && [10, 11].contains(type)) || lowerTitle.contains('iade');
      return _StatusInfo(
        color: const Color(0xFFF97316), // Canlı Turuncu (Orange 500)
        icon: isReturn ? Icons.assignment_return_rounded : Icons.warning_amber_rounded,
        pillBgColor: const Color(0xFFFEF3C7), // Açık Turuncu/Sarı Zemin
        pillBorderColor: const Color(0xFFFDE68A),
        pillTextColor: const Color(0xFFD97706), // Turuncu Metin & İkon
        pillIcon: isReturn ? Icons.assignment_return_rounded : Icons.warning_amber_rounded,
        label: isReturn ? 'İade' : 'Sorunlu',
        tooltip: actionTitle.isNotEmpty ? actionTitle : (isReturn ? 'İade' : 'Sorunlu'),
      );
    }

    // 4. Yolda / Transfer / Şube
    if ((type != null && [2, 3, 4, 9].contains(type)) ||
        (type == null && status == 1) ||
        lowerTitle.contains('yolda') ||
        lowerTitle.contains('transfer') ||
        lowerTitle.contains('şube') ||
        lowerTitle.contains('çıkış')) {
      return _StatusInfo(
        color: const Color(0xFF2563EB), // Canlı Mavi (Blue 600)
        icon: Icons.local_shipping_rounded,
        pillBgColor: const Color(0xFFEFF6FF), // Açık Mavi Zemin
        pillBorderColor: const Color(0xFFBFDBFE),
        pillTextColor: const Color(0xFF2563EB), // Mavi Metin & İkon
        pillIcon: Icons.local_shipping_outlined,
        label: 'Yolda',
        tooltip: actionTitle.isNotEmpty ? actionTitle : 'Yolda',
      );
    }

    // 5. Taslak
    if (status == 0 || lowerTitle.contains('taslak')) {
      return const _StatusInfo(
        color: Color(0xFF64748B), // Slate Gri
        icon: Icons.edit_note_rounded,
        pillBgColor: Color(0xFFF1F5F9),
        pillBorderColor: Color(0xFFE2E8F0),
        pillTextColor: Color(0xFF475569),
        pillIcon: Icons.edit_note_rounded,
        label: 'Taslak',
        tooltip: 'Taslak',
      );
    }

    // 6. Kabul Bekleniyor / Hazırlanıyor
    return _StatusInfo(
      color: const Color(0xFF6366F1), // Canlı İndigo
      icon: Icons.inventory_2_rounded,
      pillBgColor: const Color(0xFFF1F5F9), // Hafif Gri/Lacivert Zemin
      pillBorderColor: const Color(0xFFE2E8F0),
      pillTextColor: const Color(0xFF475569), // Koyu Gri/Lacivert Metin & İkon
      pillIcon: Icons.inventory_2_outlined,
      label: 'Hazırlanan',
      tooltip: actionTitle.isNotEmpty ? actionTitle : 'Hazırlanan',
    );
  }
}

class _StatusInfo {
  final Color color;
  final IconData icon;
  final Color pillBgColor;
  final Color pillBorderColor;
  final Color pillTextColor;
  final IconData pillIcon;
  final String label;
  final String tooltip;

  const _StatusInfo({
    required this.color,
    required this.icon,
    required this.pillBgColor,
    required this.pillBorderColor,
    required this.pillTextColor,
    required this.pillIcon,
    required this.label,
    required this.tooltip,
  });
}
