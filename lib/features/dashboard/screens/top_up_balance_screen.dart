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
  static const String defaultEftCode = 'ADO822716';

  void _copy(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
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
    final text = 'Banka Adı: $bankName\n'
        'Hesap Adı: $accountName\n'
        'IBAN: $iban\n'
        'Açıklama Kodu: $code\n'
        '(Not: Havale/EFT açıklama alanına sadece $code yazınız.)';

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isHighlight ? const Color(0xFF92400E) : AppColors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (badgeText != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isHighlight ? 15 : 13,
                    fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                    fontFamily: isMonospace ? 'monospace' : null,
                    color: isHighlight ? const Color(0xFF78350F) : AppColors.textPrimary,
                    letterSpacing: isMonospace ? 0.4 : 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onCopy,
            icon: Icon(
              Icons.copy_rounded,
              size: 19,
              color: isHighlight ? const Color(0xFFB45309) : AppColors.primary,
            ),
            tooltip: 'Kopyala',
            style: IconButton.styleFrom(
              backgroundColor: isHighlight
                  ? AppColors.warning.withValues(alpha: 0.15)
                  : AppColors.surfaceSecondary,
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(36, 36),
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
    final account = user?.accounts.firstOrNull;
    final eftCode = (account?.eftCode != null && account!.eftCode!.isNotEmpty)
        ? account.eftCode!
        : defaultEftCode;

    final dashboardState = ref.watch(dashboardProvider);
    final currentBalance = dashboardState.balance?.availableBalance ??
        dashboardState.balance?.balance ??
        dashboardState.stats?.availableBalance ??
        0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 20),
            SizedBox(width: 8),
            Text('Bakiye Yükle'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Mevcut Bakiye & Bilgi Kartı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                boxShadow: AppColors.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KULLANILABİLİR BAKİYENİZ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppFormatters.formatCurrency(currentBalance),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '7/24 FAST',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF065F46)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Banka Hesap Bilgileri Kartı
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
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
            const SizedBox(height: 16),

            // 3. Uyarı Kutusu (Görseldeki İle Birebir Uyumlu Sarı/Turuncu Kart)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB), // Amber-50
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.5), // Amber-500
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFD97706), // Amber-600
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Uyarı',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB45309), // Amber-700
                          ),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF78350F), // Amber-900
                              height: 1.45,
                              fontFamily: 'Roboto',
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
            const SizedBox(height: 16),

            // 4. Nasıl Yüklenir? Adım Adım Rehber
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nasıl Yüklenir?',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  _buildStepItem(
                    stepNumber: '1',
                    text: 'Banka uygulamanızdan Para Transferi / FAST / EFT adımına girin.',
                  ),
                  const SizedBox(height: 10),
                  _buildStepItem(
                    stepNumber: '2',
                    text: 'Yukarıdaki IBAN ve Alıcı Adı bilgilerini kopyalayıp yapıştırın.',
                  ),
                  const SizedBox(height: 10),
                  _buildStepItem(
                    stepNumber: '3',
                    text: 'Açıklama alanına SADECE "$eftCode" kodunuzu yazarak transferi onaylayın.',
                    isBold: true,
                  ),
                  const SizedBox(height: 10),
                  _buildStepItem(
                    stepNumber: '4',
                    text: 'FAST ile yapılan yüklemeler birkaç dakika içinde otomatik olarak cüzdanınıza yansır.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 5. Tümünü Kopyala Butonu
            ElevatedButton.icon(
              onPressed: () => _copyAll(context, eftCode),
              icon: const Icon(Icons.copy_all_rounded, size: 18),
              label: const Text(
                'Tüm Hesap Bilgilerini Kopyala',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 16),
          ],
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
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
