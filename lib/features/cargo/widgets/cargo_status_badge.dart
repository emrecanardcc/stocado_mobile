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

    switch (status) {
      case 0: // Taslak / Bekleyen
        dotColor = AppColors.warning;
        textColor = const Color(0xFFB45309);
        bgColor = AppColors.warningLight;
        break;
      case 1: // Yolda / Transfer
        dotColor = AppColors.info;
        textColor = const Color(0xFF1D4ED8);
        bgColor = AppColors.infoLight;
        break;
      case 2: // Dağıtımda
        dotColor = const Color(0xFF0284C7);
        textColor = const Color(0xFF0369A1);
        bgColor = const Color(0xFFE0F2FE);
        break;
      case 3: // Teslim Edildi
        dotColor = AppColors.secondary;
        textColor = const Color(0xFF065F46);
        bgColor = AppColors.secondaryLight;
        break;
      case 4: // İade / Sorunlu
        dotColor = AppColors.error;
        textColor = const Color(0xFF991B1B);
        bgColor = AppColors.errorLight;
        break;
      default:
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
