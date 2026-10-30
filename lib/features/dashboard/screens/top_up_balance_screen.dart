import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class TopUpBalanceScreen extends ConsumerWidget {
  const TopUpBalanceScreen({super.key});

  static const String bankName = 'Kuveyt Türk Katılım Bankası A.Ş.';
  static const String accountName = 'Adorel Lojistik Kargo Telekomünikasyon Bilişim Yazılım İç ve Dış Tic Anonim Şirketi';
  static const String iban = 'TR38 0020 5000 0956 8498 0000 01';
  static const String defaultEftCode = '-';

  void _copy(BuildContext context, String text, String label) {
    if (text.trim().isEmpty || text == '-') {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.clearSnackBars();
      messenger?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hesabınıza henüz bir $label atanmamış.',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(milliseconds: 2000),
        ),
      );
      return;
    }

    try {
      Clipboard.setData(ClipboardData(text: text));
      HapticFeedback.lightImpact();
    } catch (_) {}

    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.clearSnackBars();
    messenger?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$label panoya kopyalandı.',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(milliseconds: 1800),
      ),
    );
  }

  void _copyAll(BuildContext context, String code) {
    final effectiveCode = (code.trim().isEmpty || code == '-') ? '(Açıklama kodu tanımlı değil)' : code;
    final text = 'Banka Adı: $bankName\n'
        'Hesap Adı: $accountName\n'
        'IBAN: $iban\n'
        'Açıklama Kodu: $effectiveCode\n'
        '(Not: Havale/EFT açıklama alanına sadece $effectiveCode yazınız.)';

    _copy(context, text, 'Tüm hesap bilgileri');
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onCopy,
    bool isMonospace = false,
    bool isHighlight = false,
    String? badgeText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.warningLight.withValues(alpha: 0.35) : AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.8),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: isHighlight ? const Color(0xFF92400E) : AppColors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (badgeText != null) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isHighlight ? 13.5 : 12.5,
                    fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                    fontFamily: isMonospace ? 'monospace' : null,
                    color: isHighlight ? const Color(0xFF78350F) : AppColors.textPrimary,
                    letterSpacing: isMonospace ? 0.3 : 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: onCopy,
            icon: Icon(
              Icons.copy_rounded,
              size: 16,
              color: isHighlight ? const Color(0xFFB45309) : AppColors.primary,
            ),
            tooltip: 'Kopyala',
            style: IconButton.styleFrom(
              backgroundColor: isHighlight
                  ? AppColors.warning.withValues(alpha: 0.15)
                  : AppColors.surfaceSecondary,
              padding: const EdgeInsets.all(6),
              minimumSize: const Size(32, 32),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final account = (user != null && user.accounts.isNotEmpty)
        ? (user.accounts.where((a) => a.id == user.accountId).firstOrNull ?? user.accounts.firstOrNull)
        : null;

    final rawEftCode = account?.eftCode?.trim();
    final rawAccountCode = account?.accountCode?.trim();
    final eftCode = (rawEftCode != null && rawEftCode.isNotEmpty)
        ? rawEftCode
        : ((rawAccountCode != null && rawAccountCode.isNotEmpty)
            ? rawAccountCode
            : defaultEftCode);

    final dashboardState = ref.watch(dashboardProvider);
    final currentBalance = dashboardState.balance?.availableBalance ??
        dashboardState.balance?.balance ??
        dashboardState.stats?.availableBalance ??
        dashboardState.stats?.balance ??
        0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: false,
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Bakiye Yükle',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Bilgileri Paylaş',
            onPressed: () => _copyAll(context, eftCode),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(dashboardProvider.notifier).refresh();
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Mevcut Bakiye & Bilgi Kartı
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                  boxShadow: AppColors.softShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KULLANILABİLİR BAKİYENİZ',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppFormatters.formatCurrency(currentBalance),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: currentBalance < 0 ? AppColors.error : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '7/24 FAST',
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF065F46)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 2. Banka Hesap Bilgileri Kartı
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.softShadow,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _buildInfoRow(
                      context: context,
                      label: 'BANKA ADI',
                      value: bankName,
                      onCopy: () => _copy(context, bankName, 'Banka Adı'),
                    ),
                    _buildInfoRow(
                      context: context,
                      label: 'HESAP SAHİBİ',
                      value: accountName,
                      onCopy: () => _copy(context, accountName, 'Hesap Sahibi'),
                    ),
                    _buildInfoRow(
                      context: context,
                      label: 'IBAN',
                      value: iban,
                      isMonospace: true,
                      onCopy: () => _copy(context, iban.replaceAll(' ', ''), 'IBAN'),
                    ),
                    _buildInfoRow(
                      context: context,
                      label: 'AÇIKLAMA KODUNUZ',
                      value: eftCode,
                      isMonospace: true,
                      isHighlight: true,
                      badgeText: 'ZORUNLU',
                      onCopy: () => _copy(context, eftCode, 'Açıklama Kodu'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 3. Uyarı Kutusu
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB), // Amber-50
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 1.2), // Amber-500
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFD97706), // Amber-600
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Uyarı',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB45309), // Amber-700
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF78350F), // Amber-900
                                height: 1.3,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Havale yaparken açıklama kısmına ',
                                ),
                                TextSpan(
                                  text: 'açıklama kodunuzu ($eftCode) ',
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                const TextSpan(
                                  text: 'yazmanız gerekmektedir. Açıklama kodunu boş bırakmanız durumunda göndereceğiniz EFT tutarı carinize işlenmeyecektir.',
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
              const SizedBox(height: 8),

              // 4. Nasıl Yüklenir?
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nasıl Yüklenir?',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    _buildStepItem(
                      stepNumber: '1',
                      text: 'Banka uygulamanızdan Para Transferi / FAST / EFT adımına girin.',
                    ),
                    const SizedBox(height: 4),
                    _buildStepItem(
                      stepNumber: '2',
                      text: 'Yukarıdaki IBAN ve Alıcı Adı bilgilerini kopyalayıp yapıştırın.',
                    ),
                    const SizedBox(height: 4),
                    _buildStepItem(
                      stepNumber: '3',
                      text: 'Açıklama alanına SADECE "$eftCode" kodunuzu yazarak transferi onaylayın.',
                      isBold: true,
                    ),
                    const SizedBox(height: 4),
                    _buildStepItem(
                      stepNumber: '4',
                      text: 'FAST ile yapılan yüklemeler birkaç dakika içinde otomatik olarak cüzdanınıza yansır.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 5. Tümünü Kopyala Butonu
              ElevatedButton.icon(
                onPressed: () => _copyAll(context, eftCode),
                icon: const Icon(Icons.copy_all_rounded, size: 17),
                label: const Text(
                  'Tüm Hesap Bilgilerini Kopyala',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required String stepNumber,
    required String text,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 17,
          height: 17,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}
