import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/pricing_plan_model.dart';
import '../services/pricing_service.dart';

class PricingState {
  final bool isLoading;
  final List<PricingPlan> plans;
  final String? errorMessage;

  const PricingState({
    this.isLoading = false,
    this.plans = const [],
    this.errorMessage,
  });

  PricingState copyWith({
    bool? isLoading,
    List<PricingPlan>? plans,
    String? errorMessage,
  }) {
    return PricingState(
      isLoading: isLoading ?? this.isLoading,
      plans: plans ?? this.plans,
      errorMessage: errorMessage,
    );
  }
}

class PricingNotifier extends Notifier<PricingState> {
  final PricingService _pricingService = PricingService();

  @override
  PricingState build() {
    ref.listen(authProvider, (previous, next) {
      if (!next.isAuthenticated) {
        state = const PricingState();
      } else if (next.accountId != null && next.accountId != previous?.accountId) {
        loadPricingPlans();
      }
    });

    final currentAuth = ref.read(authProvider);
    if (currentAuth.isAuthenticated && currentAuth.accountId != null) {
      Future.microtask(() => loadPricingPlans());
      return const PricingState(isLoading: true);
    }

    return const PricingState(isLoading: false);
  }

  Future<void> loadPricingPlans() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final authState = ref.read(authProvider);
      final accountId = authState.accountId ?? authState.user?.accounts.firstOrNull?.id;

      if (accountId == null || accountId.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Hesap bilgisi bulunamadı. Lütfen tekrar giriş yapın.',
        );
        return;
      }

      final response = await _pricingService.getPricingPlans(accountId);

      state = state.copyWith(
        isLoading: false,
        plans: response.plans,
        errorMessage: response.errorMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: ApiClient.parseError(e, defaultMessage: 'Fiyat listesi yüklenirken bir sorun oluştu.'),
      );
    }
  }

  Future<void> refresh() async {
    await loadPricingPlans();
  }
}

final pricingProvider = NotifierProvider<PricingNotifier, PricingState>(() {
  return PricingNotifier();
});
