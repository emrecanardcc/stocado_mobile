import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CargoStatusBadge extends StatelessWidget {
  final int status;
  final String statusText;

  const CargoStatusBadge({
    super.key,
    required this.status,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    Color textColor;
    Color bgColor;

    final lower = statusText.toLowerCase();

    // Semantik duruma göre rozet renk paleti belirleme (Parite Hatası Önleme)
    if (lower.contains('teslim edildi')) {
      dotColor = AppColors.secondary;
      textColor = const Color(0xFF065F46);
      bgColor = AppColors.secondaryLight;
    } else if (lower.contains('iade') || lower.contains('iptal') || lower.contains('edilemedi') || lower.contains('sorunlu')) {
      dotColor = AppColors.error;
      textColor = const Color(0xFF991B1B);
      bgColor = AppColors.errorLight;
    } else if (lower.contains('dağıtım') || lower.contains('yolda') || lower.contains('transfer')) {
      dotColor = AppColors.info;
      textColor = const Color(0xFF1D4ED8);
      bgColor = AppColors.infoLight;
    } else if (lower.contains('hazır') || lower.contains('bekleyen')) {
      dotColor = const Color(0xFF6366F1);
      textColor = const Color(0xFF4338CA);
      bgColor = const Color(0xFFEEF2FF);
    } else if (lower.contains('taslak') || status == 0) {
      dotColor = AppColors.warning;
      textColor = const Color(0xFFB45309);
      bgColor = AppColors.warningLight;
    } else {
      dotColor = AppColors.primary;
      textColor = AppColors.primary;
      bgColor = AppColors.primary.withValues(alpha: 0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
          const SizedBox(width: 5),
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
}
