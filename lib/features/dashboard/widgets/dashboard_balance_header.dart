import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../../auth/models/user_model.dart';

class DashboardBalanceHeader extends StatelessWidget {
  final UserModel? user;
  final double currentBalance;
  final double podReceivable;
  final bool isLoading;
  final VoidCallback? onNewCargoTap;
  final VoidCallback? onProductsTap;
  final VoidCallback? onRatesTap;

  const DashboardBalanceHeader({
    super.key,
    required this.user,
    required this.currentBalance,
    required this.podReceivable,
    required this.isLoading,
    this.onNewCargoTap,
    this.onProductsTap,
    this.onRatesTap,
  });

  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary ? AppColors.primary : AppColors.border,
            width: 1,
          ),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isPrimary ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isPrimary ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final companyName = (user?.accounts.isNotEmpty ?? false)
        ? (user!.accounts.first.companyName?.isNotEmpty ?? false)
            ? user!.accounts.first.companyName!
            : user!.accounts.first.name
        : '';

    final balanceSplit = AppFormatters.splitCurrency(currentBalance);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kullanıcı Karşılama ve Firma Ünvanı
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user != null && user!.firstName.isNotEmpty
                        ? 'İyi Çalışmalar, ${user!.firstName}'
                        : 'İyi Çalışmalar',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (companyName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        companyName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Hero Bakiye & Finans Kartı (Soft Açık Tema & Yüksek Okunabilirlik)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Satır: Bakiye Başlığı ve Canlı Rozeti
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 16),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Cüzdan Bakiyesi',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Canlı',
                          style: TextStyle(color: Color(0xFF065F46), fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Ana Bakiye Tutarı (Hero Tipografi: Tam Sayı Büyük, Kuruş Küçük)
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    balanceSplit.whole,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    '${balanceSplit.decimal} ${balanceSplit.symbol}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (currentBalance.abs() >= 10000) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        AppFormatters.formatCompactCurrency(currentBalance),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // Alt Bölüm: K.Ö. Alacak ve Hesap Durumu Çipleri
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.hourglass_bottom_rounded, color: AppColors.warning, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'K.Ö. Alacak',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  AppFormatters.formatCurrency(podReceivable),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 24, width: 1, color: AppColors.border),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: AppColors.secondary, size: 18),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hesap Durumu',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 1),
                                Text(
                                  'Aktif / Onaylı',
                                  style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Mobil Hızlı İşlem Çipleri (Thumb-Friendly Ergonomics)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickActionChip(
                icon: Icons.add_circle_outline_rounded,
                label: 'Yeni Kargo',
                onTap: onNewCargoTap,
                isPrimary: true,
              ),
              const SizedBox(width: 8),
              _buildQuickActionChip(
                icon: Icons.inventory_2_outlined,
                label: 'Ürün Kataloğu',
                onTap: onProductsTap,
              ),
              const SizedBox(width: 8),
              _buildQuickActionChip(
                icon: Icons.receipt_long_outlined,
                label: 'Tarifeler & Fiyat',
                onTap: onRatesTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
