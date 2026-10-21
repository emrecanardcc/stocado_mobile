import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/balance_model.dart';
import '../models/dashboard_stats_model.dart';
import '../services/dashboard_service.dart';

class DashboardState {
  final bool isLoading;
  final DashboardStats? stats;
  final BalanceModel? balance;
  final String? errorMessage;

  const DashboardState({
    this.isLoading = false,
    this.stats,
    this.balance,
    this.errorMessage,
  });

  DashboardState copyWith({
    bool? isLoading,
    DashboardStats? stats,
    BalanceModel? balance,
    String? errorMessage,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      balance: balance ?? this.balance,
      errorMessage: errorMessage,
    );
  }
}

class DashboardNotifier extends Notifier<DashboardState> {
  final DashboardService _dashboardService = DashboardService();

  @override
  DashboardState build() {
    ref.listen(authProvider, (previous, next) {
      if (!next.isAuthenticated) {
        state = const DashboardState();
      } else if (next.accountId != null && next.accountId != previous?.accountId) {
        loadDashboard();
      }
    });
    Future.microtask(() => loadDashboard());
    return const DashboardState(isLoading: true);
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final authState = ref.read(authProvider);
      final accountId = authState.accountId ?? authState.user?.accounts.firstOrNull?.id;

      final results = await Future.wait([
        _dashboardService.getDashboardStats(accountId: accountId),
        _dashboardService.getBalance(accountId: accountId),
      ]);

      final stats = results[0] as DashboardStats?;
      final balance = results[1] as BalanceModel?;

      state = state.copyWith(
        isLoading: false,
        stats: stats,
        balance: balance,
        errorMessage: (stats == null && balance == null) ? 'İstatistik verileri sunucudan alınamadı.' : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: ApiClient.parseError(e, defaultMessage: 'Panel verileri yüklenirken bir sorun oluştu.'),
      );
    }
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});
