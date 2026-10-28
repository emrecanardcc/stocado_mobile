import 'package:flutter/material.dart';
import '../models/cargo_model.dart';

/// Kargo durumunu tek bakışta anlatan, canlı renklere ve dairesel tasarıma sahip dikkat çekici durum rozeti/simgesi.
class CargoStatusIcon extends StatelessWidget {
  final CargoModel cargo;
  final double size;

  const CargoStatusIcon({
    super.key,
    required this.cargo,
    this.size = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    final info = _resolveStatus(cargo);

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
    if (type == 6 ||
        (type == null && status == 2) ||
        lowerTitle.contains('teslim edildi') ||
        lowerTitle.contains('teslim') ||
        lowerTitle.contains('tamamlan')) {
      return _StatusInfo(
        color: const Color(0xFF10B981), // Canlı Yeşil (Emerald 500)
        icon: Icons.check_rounded,
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
        tooltip: actionTitle.isNotEmpty ? actionTitle : 'Sorunlu / İade',
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
        tooltip: actionTitle.isNotEmpty ? actionTitle : 'Yolda',
      );
    }

    // 5. Taslak
    if (status == 0 || lowerTitle.contains('taslak')) {
      return const _StatusInfo(
        color: Color(0xFF64748B), // Slate Gri
        icon: Icons.edit_note_rounded,
        tooltip: 'Taslak',
      );
    }

    // 6. Kabul Bekleniyor / Hazırlanıyor
    return _StatusInfo(
      color: const Color(0xFF6366F1), // Canlı İndigo
      icon: Icons.inventory_2_rounded,
      tooltip: actionTitle.isNotEmpty ? actionTitle : 'Kabul Bekleniyor',
    );
  }
}

class _StatusInfo {
  final Color color;
  final IconData icon;
  final String tooltip;

  const _StatusInfo({
    required this.color,
    required this.icon,
    required this.tooltip,
  });
}
