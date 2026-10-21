import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../cargo/screens/cargos_screen.dart';
import '../../cargo/screens/create_cargo_screen.dart';
import '../../pricing/screens/pricing_screen.dart';
import '../providers/navigation_provider.dart';
import 'dashboard_screen.dart';

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
        return const PricingScreen();
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

    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(mainNavigationProvider.notifier).selectTab(index);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: 22,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
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
        children: List.generate(4, _buildScreen),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x100F172A),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
                label: 'Özet',
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.local_shipping_outlined,
                activeIcon: Icons.local_shipping_rounded,
                label: 'Kargolar',
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.add_circle_outline_rounded,
                activeIcon: Icons.add_circle_rounded,
                label: 'Yeni Kargo',
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                label: 'Tarife & Ürün',
                currentIndex: currentIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
