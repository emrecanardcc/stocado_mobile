import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_error_state.dart';
import '../providers/pricing_provider.dart';
import '../widgets/live_price_calculator.dart';
import '../widgets/pricing_empty_state.dart';
import '../widgets/pricing_plan_card.dart';

class PricingScreen extends ConsumerWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricingState = ref.watch(pricingProvider);
    final pricingNotifier = ref.read(pricingProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.receipt_long_outlined, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tarifeler & Fiyatlar',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(context, pricingState, pricingNotifier),
    );
  }

  Widget _buildBody(BuildContext context, PricingState pricingState, PricingNotifier pricingNotifier) {
    if (pricingState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
            SizedBox(height: 16),
            Text(
              'Anlaşmalı kargo tarifeleri yükleniyor...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (pricingState.errorMessage != null && pricingState.plans.isEmpty) {
      return AppErrorState(
        title: 'Fiyat Tarifeleri Yüklenemedi',
        message: pricingState.errorMessage!,
        onRetry: () => pricingNotifier.refresh(),
      );
    }

    if (pricingState.plans.isEmpty) {
      return PricingEmptyState(onRefresh: () => pricingNotifier.refresh());
    }

    return RefreshIndicator(
      onRefresh: () => pricingNotifier.refresh(),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Canlı Fiyat Hesaplama Kutucuğu
          LivePriceCalculator(plans: pricingState.plans),
          const SizedBox(height: 16),

          // Firma Detay Tarifeleri Başlığı
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'FİRMA DETAY TARİFELERİ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.8,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '${pricingState.plans.length} ANLAŞMA',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Kargo Firma Tarifeleri Listesi
          ...pricingState.plans.map((plan) => PricingPlanCard(plan: plan)),
        ],
      ),
    );
  }
}
