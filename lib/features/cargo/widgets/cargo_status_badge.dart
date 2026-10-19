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
    Color statusColor;
    Color statusBgColor;

    switch (status) {
      case 0: // Bekleyen / Oluşturuldu
        statusColor = Colors.grey.shade800;
        statusBgColor = Colors.grey.shade200;
        break;
      case 1: // Yolda / Transfer
        statusColor = Colors.blue.shade800;
        statusBgColor = Colors.blue.shade100;
        break;
      case 2: // Dağıtımda
        statusColor = Colors.orange.shade800;
        statusBgColor = Colors.orange.shade100;
        break;
      case 3: // Teslim Edildi
        statusColor = Colors.green.shade800;
        statusBgColor = Colors.green.shade100;
        break;
      case 4: // İade / Sorunlu
        statusColor = Colors.red.shade800;
        statusBgColor = Colors.red.shade100;
        break;
      default:
        statusColor = AppColors.primary;
        statusBgColor = AppColors.primary.withValues(alpha: 0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusBgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
