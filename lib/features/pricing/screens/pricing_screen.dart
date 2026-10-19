import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/pricing_provider.dart';
import '../widgets/pricing_empty_state.dart';
import '../widgets/pricing_plan_card.dart';

class PricingScreen extends ConsumerWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pricingProvider);
    final notifier = ref.read(pricingProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.receipt_long_outlined, size: 20),
            SizedBox(width: 8),
            Text('Fiyat Listesi & Tarifeler'),
          ],
        ),
        actions: [
          IconButton(
            icon: state.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Yenile',
            onPressed: state.isLoading ? null : () => notifier.refresh(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
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

          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.errorLight,
                      ),
                      child: const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => notifier.refresh(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Tekrar Dene'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(160, 44)),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.plans.isEmpty) {
            return PricingEmptyState(onRefresh: () => notifier.refresh());
          }

          return RefreshIndicator(
            onRefresh: () => notifier.refresh(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.plans.length,
              itemBuilder: (context, index) {
                final plan = state.plans[index];
                return PricingPlanCard(plan: plan);
              },
            ),
          );
        },
      ),
    );
  }
}
