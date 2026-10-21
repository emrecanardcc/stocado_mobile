import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../dashboard/widgets/cargo_stats_tab_view.dart';
import '../../dashboard/widgets/dashboard_balance_header.dart';
import '../../dashboard/widgets/finance_stats_tab_view.dart';
import '../../dashboard/widgets/pod_stats_tab_view.dart';
import '../providers/navigation_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppColors.error, size: 22),
            SizedBox(width: 8),
            Text('Çıkış Yap', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text(
          'Oturumunuzu kapatmak istediğinize emin misiniz? Tekrar giriş yapmanız gerekecektir.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Çıkış Yap', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabItem({required int index, required String title}) {
    final isSelected = _tabController.index == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? AppColors.softShadow : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final dashboardState = ref.watch(dashboardProvider);
    final user = authState.user;
    final stats = dashboardState.stats;
    final balance = dashboardState.balance;

    final currentBalance = balance?.balance ?? stats?.balance ?? 0.0;
    final podReceivable = stats?.podWillPay ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height: 20,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.local_shipping,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Stocado Paneli'),
          ],
        ),
        actions: [
          IconButton(
            icon: dashboardState.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Yenile',
            onPressed: dashboardState.isLoading ? null : () => ref.read(dashboardProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Çıkış Yap',
            onPressed: _showLogoutDialog,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: dashboardState.errorMessage != null && stats == null && !dashboardState.isLoading
          ? AppErrorState(
              title: 'Gösterge Paneli Yüklenemedi',
              message: dashboardState.errorMessage!,
              onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
            )
          : RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardBalanceHeader(
                user: user,
                currentBalance: currentBalance,
                podReceivable: podReceivable,
                isLoading: dashboardState.isLoading,
                onNewCargoTap: () => ref.read(mainNavigationProvider.notifier).selectTab(2),
                onProductsTap: () => ref.read(mainNavigationProvider.notifier).selectTab(3, subIndex: 1),
                onRatesTap: () => ref.read(mainNavigationProvider.notifier).selectTab(3, subIndex: 0),
              ),
              const SizedBox(height: 18),

              // Modern Pill-Style Segmented Tab Seçici
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  children: [
                    _buildSegmentedTabItem(index: 0, title: 'Kargolar'),
                    _buildSegmentedTabItem(index: 1, title: 'Kapıda Ödemeler'),
                    _buildSegmentedTabItem(index: 2, title: 'Finans'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sekme İçerikleri
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) {
                  switch (_tabController.index) {
                    case 0:
                      return CargoStatsTabView(stats: stats);
                    case 1:
                      return PodStatsTabView(stats: stats);
                    case 2:
                      return FinanceStatsTabView(stats: stats, currentBalance: currentBalance);
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}