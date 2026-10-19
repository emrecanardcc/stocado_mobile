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
      appBar: AppBar(
        title: const Text('Fiyat Listesi ve Tarifeler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: () => notifier.refresh(),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Tarifeler veritabanından yükleniyor...', style: TextStyle(color: AppColors.textSecondary)),
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
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => notifier.refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Dene'),
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
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
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
