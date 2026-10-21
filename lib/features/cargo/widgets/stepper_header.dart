import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StepperHeader extends StatelessWidget {
  final int currentStep;

  const StepperHeader({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    const steps = ['Adresler', 'Paket', 'Ek Hizmetler', 'Teklif'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? AppColors.secondary
                              : (isActive ? AppColors.primary : AppColors.surfaceSecondary),
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.secondary
                                : (isActive ? AppColors.primary : AppColors.border),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isActive ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        steps[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive ? AppColors.primary : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (index < steps.length - 1)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 14,
                    height: 2,
                    color: index < currentStep ? AppColors.secondary : AppColors.border,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
