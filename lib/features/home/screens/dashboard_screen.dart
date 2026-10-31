import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/account_deletion_dialog.dart';
import '../../cargo/providers/cargo_list_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../dashboard/widgets/dashboard_balance_hero_card.dart';
import '../../dashboard/widgets/dashboard_package_status_row.dart';
import '../../dashboard/widgets/dashboard_recent_cargos_section.dart';
import '../providers/navigation_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Bildirimler',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0E1E38)),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: AppColors.secondary, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tüm kargo ve bakiye bildirimleriniz günceldir.',
                        style: TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileSheet() {
    final authState = ref.read(authProvider);
    final user = authState.user;
    final account = (user != null && user.accounts.isNotEmpty)
        ? (user.accounts.where((a) => a.id == user.accountId).firstOrNull ?? user.accounts.firstOrNull)
        : null;
    final companyName = (account?.companyName?.isNotEmpty ?? false)
        ? account!.companyName!
        : (account?.name ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  user?.firstName.isNotEmpty == true ? user!.firstName[0].toUpperCase() : 'S',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user != null ? '${user.firstName} ${user.lastName}' : 'Stocado Kullanıcısı',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0E1E38)),
              ),
              if (companyName.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  companyName,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
              const SizedBox(height: 12),
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.support_agent_rounded, color: Color(0xFF25D366), size: 22),
                title: const Text('Müşteri Desteği (WhatsApp)', style: TextStyle(color: Color(0xFF0E1E38), fontWeight: FontWeight.w600, fontSize: 13.5)),
                subtitle: const Text('+90 553 448 81 92 hattı ile iletişime geçin', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                onTap: () {
                  Navigator.pop(ctx);
                  launchSupportWhatsApp(context, customMessage: 'Merhaba, Stocado destek almak istiyorum.');
                },
              ),
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.person_remove_outlined, color: AppColors.error, size: 22),
                title: const Text('Hesabımı Sil', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 13.5)),
                subtitle: const Text('Hesap kapatma ve veri silme talebi', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                onTap: () {
                  Navigator.pop(ctx);
                  showAccountDeletionDialog(context);
                },
              ),
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.logout_rounded, color: Color(0xFF64748B), size: 22),
                title: const Text('Oturumu Kapat', style: TextStyle(color: Color(0xFF0E1E38), fontWeight: FontWeight.w600, fontSize: 13.5)),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(authProvider.notifier).logout();
                },
              ),
            ],
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

    final userName = (user != null && user.firstName.isNotEmpty)
        ? user.firstName
        : 'Kullanıcı';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: dashboardState.errorMessage != null && stats == null && !dashboardState.isLoading
            ? AppErrorState(
                title: 'Özet Ekranı Yüklenemedi',
                message: dashboardState.errorMessage!,
                onRetry: () {
                  ref.read(dashboardProvider.notifier).refresh();
                  ref.read(cargoListProvider.notifier).refresh();
                },
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    ref.read(dashboardProvider.notifier).refresh(),
                    ref.read(cargoListProvider.notifier).refresh(),
                  ]);
                },
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. ÜST HEADER: Sol Kurumsal Stocado Başlığı & Sağ Minimal İkonlar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Stocado',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0E1E38),
                              letterSpacing: -0.6,
                            ),
                          ),

                          Row(
                            children: [
                              // Bildirim Zili ve Kırmızı Rozet
                              InkWell(
                                onTap: _showNotificationsSheet,
                                borderRadius: BorderRadius.circular(20),
                                child: SizedBox(
                                  width: 38,
                                  height: 38,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      const Icon(
                                        Icons.notifications_none_rounded,
                                        size: 24,
                                        color: Color(0xFF0E1E38),
                                      ),
                                      Positioned(
                                        top: 6,
                                        right: 7,
                                        child: Container(
                                          width: 7,
                                          height: 7,
                                          decoration: const BoxDecoration(
                                            color: AppColors.error,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Profil Avatar İkonu
                              InkWell(
                                onTap: _showProfileSheet,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE2E8F0),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    size: 20,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 2. KULLANICI KARŞILAMASI: Merhaba, [İsim]
                      Text(
                        'Merhaba, $userName',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0E1E38),
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 3. HERO KULLANILABİLİR BAKİYE KARTI
                      DashboardBalanceHeroCard(
                        currentBalance: currentBalance,
                        podReceivable: podReceivable,
                      ),
                      const SizedBox(height: 22),

                      // 4. KARGOLARIM DURUM ÖZETİ (YATAY 4'LÜ KUTU & BİLDİRİM ŞERİDİ)
                      DashboardPackageStatusRow(
                        stats: stats,
                        onStatusTap: (filter) {
                          ref.read(cargoListProvider.notifier).setTab('all');
                          ref.read(cargoListProvider.notifier).setStatusFilter(filter);
                          ref.read(mainNavigationProvider.notifier).selectTab(1);
                        },
                      ),
                      const SizedBox(height: 22),

                      // 5. SON GÖNDERİLER LİSTESİ
                      DashboardRecentCargosSection(
                        onSeeAllTap: () {
                          ref.read(cargoListProvider.notifier).clearFilters();
                          ref.read(cargoListProvider.notifier).setTab('all');
                          ref.read(mainNavigationProvider.notifier).selectTab(1);
                        },
                        onNewCargoTap: () => ref.read(mainNavigationProvider.notifier).selectTab(2),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}