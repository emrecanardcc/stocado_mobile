import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../cargo/screens/cargos_screen.dart';
import '../../cargo/screens/create_cargo_screen.dart';
import '../../finance/screens/finance_screen.dart';
import '../providers/navigation_provider.dart';
import 'dashboard_screen.dart';
import 'more_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final Set<int> _loadedTabs = {0};

  Widget _buildScreen(int index) {
    if (!_loadedTabs.contains(index)) {
      return const SizedBox.shrink();
    }
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const CargosScreen();
      case 2:
        return const CreateCargoScreen();
      case 3:
        return const FinanceScreen();
      case 4:
        return const MoreScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int currentIndex,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? const Color(0xFF0E1E38) : const Color(0xFF94A3B8);

    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(mainNavigationProvider.notifier).selectTab(index);
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(2, 6, 2, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 22,
                color: color,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterActionButton(int currentIndex) {
    final isSelected = currentIndex == 2;

    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(mainNavigationProvider.notifier).selectTab(2);
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(2, 0, 2, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E1E38),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0E1E38).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Yeni Kargo',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? const Color(0xFF0E1E38) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(mainNavigationProvider);
    final currentIndex = navState.tabIndex;

    // Aktif sekmeyi lazy-load kümesine ekle
    _loadedTabs.add(currentIndex);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: List.generate(5, _buildScreen),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: AppColors.border.withValues(alpha: 0.8),
              width: 1.0,
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 12,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          bottom: true,
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Ana Sayfa',
                  currentIndex: currentIndex,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2_rounded,
                  label: 'Kargolar',
                  currentIndex: currentIndex,
                ),
                _buildCenterActionButton(currentIndex),
                _buildNavItem(
                  index: 3,
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart_rounded,
                  label: 'Finans',
                  currentIndex: currentIndex,
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.more_horiz_rounded,
                  activeIcon: Icons.more_horiz_rounded,
                  label: 'Diğer',
                  currentIndex: currentIndex,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
