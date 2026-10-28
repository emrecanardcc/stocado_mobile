import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../dashboard/screens/top_up_balance_screen.dart';
import '../../dashboard/widgets/finance_stats_tab_view.dart';
import '../../dashboard/widgets/pod_stats_tab_view.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> with SingleTickerProviderStateMixin {
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

  Widget _buildSegmentItem({required int index, required String title}) {
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
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF0E1E38) : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(double currentBalance, double pendingPod, double transferredPod) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Koyu Lacivert Bakiye Kartı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1E38),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A0E1E38),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Kullanılabilir Bakiye',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.visibility_outlined, size: 16, color: Colors.white70),
                        ],
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppFormatters.formatCurrency(currentBalance),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TopUpBalanceScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 16, color: Color(0xFF0E1E38)),
                  label: const Text(
                    'Bakiye Yükle',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0E1E38),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2'li İkili Kart Satırı (Bekleyen Tahsilat & Aktarılan Tutar)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.hourglass_top_rounded, size: 16, color: AppColors.warning),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Bekleyen Tahsilat',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          AppFormatters.formatCurrency(pendingPod),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0E1E38),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance_rounded, size: 16, color: AppColors.secondary),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Aktarılan Tutar',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          AppFormatters.formatCurrency(transferredPod),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0E1E38),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Finansal Akış Özeti
          const Text(
            'Finansal Akış',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0E1E38)),
          ),
          const SizedBox(height: 10),
          FinanceStatsTabView(stats: ref.watch(dashboardProvider).stats, currentBalance: currentBalance),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final stats = dashboardState.stats;
    final balance = dashboardState.balance;

    final currentBalance = balance?.balance ?? stats?.balance ?? 0.0;
    final pendingPod = stats?.podPending ?? stats?.podWillPay ?? 0.0;
    final transferredPod = stats?.podPaid ?? 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        titleSpacing: 18,
        title: const Text(
          'Finans',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0E1E38),
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
        color: AppColors.primary,
        child: Column(
          children: [
            // Segment Switcher: Özet | Kapıda Ödeme | Hareketler
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  children: [
                    _buildSegmentItem(index: 0, title: 'Özet'),
                    _buildSegmentItem(index: 1, title: 'Kapıda Ödeme'),
                    _buildSegmentItem(index: 2, title: 'Hareketler'),
                  ],
                ),
              ),
            ),

            Expanded(
              child: AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) {
                  switch (_tabController.index) {
                    case 0:
                      return _buildOverviewTab(currentBalance, pendingPod, transferredPod);
                    case 1:
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: PodStatsTabView(stats: stats),
                      );
                    case 2:
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: FinanceStatsTabView(stats: stats, currentBalance: currentBalance),
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
