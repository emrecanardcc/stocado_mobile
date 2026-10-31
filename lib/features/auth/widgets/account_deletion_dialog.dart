import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

/// WhatsApp Destek Hattını Başlatır (+90 553 448 81 92)
Future<void> launchSupportWhatsApp(BuildContext context, {String? customMessage}) async {
  final message = customMessage ??
      'Merhaba, Stocado hesabımı kapatmak ve verilerimi silmek istiyorum.';
  final encodedMsg = Uri.encodeComponent(message);
  final uri = Uri.parse('https://wa.me/905534488192?text=$encodedMsg');

  try {
    // 1. WhatsApp uygulamasını harici uygulama modunda açmayı dene
    final launchedApp = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (launchedApp) return;

    // 2. WhatsApp uygulaması yüklü değilse tarayıcıda wa.me web sayfasını aç
    final launchedBrowser = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (launchedBrowser) return;
  } catch (_) {
    try {
      final launchedBrowser = await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (launchedBrowser) return;
    } catch (_) {}
  }

  // 3. Tarayıcı da açılamadıysa telefon arama fallback'i uygula
  if (context.mounted) {
    await launchSupportPhone(context);
  }
}

/// Telefon Görüşmesi Başlatır (+90 553 448 81 92)
Future<void> launchSupportPhone(BuildContext context) async {
  final uri = Uri.parse('tel:+905534488192');
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
  } catch (_) {}

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Arama başlatılamadı. Destek hattımız: +90 553 448 81 92'),
        backgroundColor: AppColors.warning,
      ),
    );
  }
}

/// Web Portalını Tarayıcıda Açar
Future<void> launchWebPortal(BuildContext context, [String path = '']) async {
  final url = path.isNotEmpty ? 'https://portal.stocado.com$path' : 'https://portal.stocado.com';
  final uri = Uri.parse(url);
  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      await launchUrl(uri);
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Web portalı açılamadı: $url'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }
}

/// App Store 5.1.1 & Play Store Uyumlu Hesap Silme Bilgilendirme ve Destek İletişim Dialogu
Future<void> showAccountDeletionDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.shield_outlined, color: AppColors.error, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hesap Silme Talebi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0E1E38),
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.error, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Güvenlik ve Yasal Doğrulama Gerekliliği',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Mevcut aktif kargo gönderileriniz, tahsilatlı (kapıda ödeme) teslimat süreçleriniz ve cüzdan bakiyeniz bulunabileceğinden dolayı; hesap kapatma ve veri silme işlemleri güvenlik nedeniyle Müşteri Destek Merkezimiz tarafından doğrulanarak yapılmaktadır.',
              style: TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.45),
            ),
            const SizedBox(height: 10),
            const Text(
              'Açık gönderi ve finansal bakiye kontrollerinizin hemen ardından hesap silme işleminiz tamamlanacaktır. Destek ekibimizle WhatsApp veya telefon hattımız üzerinden anında iletişime geçebilirsiniz.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // WhatsApp İletişim Butonu (Öncelikli Eylem)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: const Text(
                'WhatsApp Destek (+90 553 448 81 92)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                launchSupportWhatsApp(context);
              },
            ),
            const SizedBox(height: 8),

            // Telefon ile Arama Butonu
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0E1E38),
                minimumSize: const Size(double.infinity, 42),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.phone_outlined, size: 18),
              label: const Text(
                'Telefon ile Ara (+90 553 448 81 92)',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                launchSupportPhone(context);
              },
            ),
            const SizedBox(height: 8),

            // Web Portalı Butonu
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 42),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.language_rounded, size: 18),
              label: const Text(
                'Web Portalı (portal.stocado.com)',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                launchWebPortal(context);
              },
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            'Vazgeç',
            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
