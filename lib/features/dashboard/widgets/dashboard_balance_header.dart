import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/models/user_model.dart';

class DashboardBalanceHeader extends StatelessWidget {
  final UserModel? user;
  final double currentBalance;
  final double podReceivable;
  final bool isLoading;

  const DashboardBalanceHeader({
    super.key,
    required this.user,
    required this.currentBalance,
    required this.podReceivable,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final companyName = (user?.accounts.isNotEmpty ?? false)
        ? (user!.accounts.first.companyName?.isNotEmpty ?? false)
            ? user!.accounts.first.companyName!
            : user!.accounts.first.name
        : '';

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
                  Row(
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
                      const SizedBox(width: 6),
                      const Text('🖐️', style: TextStyle(fontSize: 18)),
                    ],
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

        // Hero Bakiye & Finans Kartı (Modern Koyu Lacivert Gradyan)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2A16325B),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Satır: Bakiye Başlığı ve Simge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Cüzdan Bakiyesi',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, color: Colors.amberAccent, size: 13),
                        SizedBox(width: 3),
                        Text(
                          'Canlı',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Ana Bakiye Tutarı
              Text(
                '₺ ${currentBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Alt Bölüm: K.Ö. Alacak ve Kullanılabilir Bakiye Çipleri
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.payments_outlined, color: Colors.greenAccent, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'K.Ö. Alacak',
                                  style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '₺ ${podReceivable.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 24, width: 1, color: Colors.white24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: Colors.lightBlueAccent, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hesap Durumu',
                                  style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w500),
                                ),
                                const Text(
                                  'Aktif / Onaylı',
                                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
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
      ],
    );
  }
}
