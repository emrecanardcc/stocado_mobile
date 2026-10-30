import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/cargo_model.dart';
import '../services/cargo_service.dart';
import 'cargo_company_logo.dart';
import 'cargo_status_badge.dart';

class CargoDetailModal extends ConsumerStatefulWidget {
  final CargoModel cargo;

  const CargoDetailModal({
    super.key,
    required this.cargo,
  });

  static void show(BuildContext context, CargoModel cargo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CargoDetailModal(cargo: cargo),
    );
  }

  @override
  ConsumerState<CargoDetailModal> createState() => _CargoDetailModalState();
}

class _CargoDetailModalState extends ConsumerState<CargoDetailModal> {
  late CargoModel _cargo;
  bool _isLoadingLiveDetails = false;
  bool _hasLoadedLive = false;
  final CargoService _cargoService = CargoService();

  @override
  void initState() {
    super.initState();
    _cargo = widget.cargo;
    _loadLiveDetails();
  }

  Future<void> _loadLiveDetails() async {
    final cid = _cargo.id?.toString();
    if (cid == null || cid.isEmpty) return;

    setState(() => _isLoadingLiveDetails = true);
    try {
      final auth = ref.read(authProvider);
      final accountId = auth.accountId ?? auth.user?.accounts.firstOrNull?.id;
      final detailed = await _cargoService.getCargoDetail(cid, accountId: accountId);
      if (mounted && detailed != null) {
        setState(() {
          _cargo = detailed;
          _hasLoadedLive = true;
          _isLoadingLiveDetails = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoadingLiveDetails = false);
    }
  }


  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanPhone,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Arama başlatılamadı. Telefon uygulamasını kontrol ediniz.'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    } catch (_) {}
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label panoya kopyalandı.'),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  int _resolveActiveTimelineStep() {
    final type = _cargo.effectiveTransactionType;
    final status = _cargo.status;

    // 1. Transaction tipi veya iptal durumu
    if (type != null) {
      if (type == 6) return 4; // Teslim Edildi
      if (type == 5) return 3; // Kurye Dağıtıma Çıktı
      if ([2, 3, 4, 9].contains(type)) return 2; // Aktarma / Yolda
      if (type == 1) return 1; // Şubeye Teslim Edildi / Hazır
      if ([7, 12, 13].contains(type)) return -1; // İptal Edildi / Sorunlu
      if ([10, 11].contains(type)) return -2; // İade
    }

    // 2. Transaction yoksa genel status kodu ile dinamik belirle
    switch (status) {
      case 0:
        return 0; // Taslak
      case 1:
        return 1; // Gönderime Hazır / Şubede
      case 2:
        return 2; // Yolda / Dağıtımda
      case 3:
      case 4:
        return -1; // İptal Edildi (Stocado DB'de status=3 kapalı/iptal durumudur)
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final receiverName = _cargo.receiver?.name ?? 'İsimsiz Alıcı';
    final receiverPhone = _cargo.receiver?.phone;
    final receiverCity = _cargo.receiver?.city?.name ?? '';
    final receiverDistrict = _cargo.receiver?.district?.name ?? '';
    final receiverLoc = [receiverDistrict, receiverCity].where((s) => s.isNotEmpty).join(', ');
    final receiverAddress = [
      if (_cargo.receiver?.title != null && _cargo.receiver!.title!.isNotEmpty) _cargo.receiver!.title!,
      if (receiverLoc.isNotEmpty) receiverLoc,
    ].join('\n');

    final senderName = _cargo.sender?.name ?? 'Gönderici';
    final senderCity = _cargo.sender?.city?.name ?? '';
    final senderDistrict = _cargo.sender?.district?.name ?? '';
    final senderLoc = [senderDistrict, senderCity].where((s) => s.isNotEmpty).join(', ');
    final senderAddress = [
      if (_cargo.sender?.title != null && _cargo.sender!.title!.isNotEmpty) _cargo.sender!.title!,
      if (senderLoc.isNotEmpty) senderLoc,
    ].join(' • ');

    final activeStep = _resolveActiveTimelineStep();
    final hasRealTransactions = _cargo.transactions.isNotEmpty;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Tutamaç (Handle)
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Modal Üst Başlık (Header)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CargoCompanyLogo(
                      companyId: _cargo.cargoCompany?.id?.toString() ?? _cargo.cargoCompanyId,
                      companyName: _cargo.cargoCompany?.title,
                      width: 76,
                      height: 32,
                      borderRadius: 8,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _cargo.cargoCompany?.title ?? CargoCompanyType.fromString(_cargo.cargoCompanyId).displayName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        if (_cargo.createdAt != null)
                          Text(
                            AppFormatters.formatDateTime(_cargo.createdAt!),
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (_isLoadingLiveDetails)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                      ),
                    CargoStatusBadge(
                      status: _cargo.status,
                      statusText: _cargo.statusText,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Modal İçerik Alanı
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Takip Kodu ve Resmi Takip Sitesi Butonu Kartı
                  Container(
                    width: double.infinity,
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
                        // Taşıyıcı Barkod
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Taşıyıcı Barkod',
                                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  if (_cargo.hasCarrierBarcode)
                                    Text(
                                      _cargo.outTrackingCode,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                        fontFamily: 'monospace',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.border.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Kabul bekleniyor',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (_cargo.hasCarrierBarcode)
                              OutlinedButton.icon(
                                onPressed: () => _copyToClipboard(context, _cargo.outTrackingCode, 'Taşıyıcı Barkod'),
                                icon: const Icon(Icons.copy_rounded, size: 14),
                                label: const Text('Kopyala', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  side: const BorderSide(color: AppColors.border),
                                  minimumSize: Size.zero,
                                ),
                              ),
                          ],
                        ),

                        // Referans Barkod (processNumber)
                        if (_cargo.processNumber.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Referans Barkod (Süreç No)',
                                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _cargo.processNumber,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                        fontFamily: 'monospace',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _copyToClipboard(context, _cargo.processNumber, 'Referans Barkod'),
                                icon: const Icon(Icons.copy_rounded, size: 14),
                                label: const Text('Kopyala', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  side: const BorderSide(color: AppColors.border),
                                  minimumSize: Size.zero,
                                ),
                              ),
                            ],
                          ),
                        ],



                        if (_cargo.orderNumber != null && _cargo.orderNumber!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Sipariş No:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text(_cargo.orderNumber!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Kargo Durum Süreci (Canlı Hareketler veya Durum Boru Hattı)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kargo Durum Süreci',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      if (_hasLoadedLive && hasRealTransactions)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt_rounded, size: 12, color: AppColors.secondary),
                              SizedBox(width: 4),
                              Text(
                                'Canlı Hareketler',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.secondary),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: hasRealTransactions
                        ? _buildRealTransactionsList(_cargo.transactions)
                        : _buildStandardTimelinePipeline(activeStep),
                  ),
                  const SizedBox(height: 20),

                  // 3. Alıcı ve Gönderici Bilgileri
                  const Text(
                    'Teslimat Tarafları',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  // Alıcı Kartı
                  Container(
                    width: double.infinity,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.person_pin_circle_rounded, size: 18, color: AppColors.secondary),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Alıcı Bilgileri', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                    Text(receiverName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  ],
                                ),
                              ],
                            ),
                            if (receiverPhone != null && receiverPhone.isNotEmpty)
                              IconButton.filledTonal(
                                onPressed: () => _makePhoneCall(context, receiverPhone),
                                icon: const Icon(Icons.call_rounded, size: 18),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.secondaryLight,
                                  foregroundColor: AppColors.secondary,
                                ),
                              ),
                          ],
                        ),
                        if (receiverPhone != null && receiverPhone.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Telefon: $receiverPhone', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          receiverAddress,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Gönderici Kartı
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.storefront_rounded, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Çıkış / Gönderici Adresi', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(senderName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              Text(senderAddress, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Paket ve Finansal Detaylar
                  const Text(
                    'Paket ve Finansal Bilgiler',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Hesaplanan Desi', '${_cargo.effectiveDesi.toStringAsFixed(1)} Desi'),
                        const Divider(height: 16, color: AppColors.border),
                        _buildDetailRow('Kargo Taşıma Ücreti', AppFormatters.formatCurrency(_cargo.totalPrice)),
                        if (_cargo.payOnDelivery) ...[
                          const Divider(height: 16, color: AppColors.border),
                          _buildDetailRow('Kapıda Ödeme (Tahsilat)', AppFormatters.formatCurrency(_cargo.payOnDeliveryAmount ?? 0.0), isHighlight: true),
                          if (_cargo.payOnDeliveryCost != null) ...[
                            const SizedBox(height: 6),
                            _buildDetailRow('Kesinti / Hizmet Bedeli', AppFormatters.formatCurrency(_cargo.payOnDeliveryCost)),
                          ],
                          const SizedBox(height: 6),
                          _buildDetailRow('Net Aktarılacak Tutar', AppFormatters.formatCurrency(_cargo.payOnDeliveryNetAmount), isHighlight: true),
                          const SizedBox(height: 6),
                          _buildDetailRow('Tahsilat Türü', _cargo.payOnDeliveryTypeText ?? (_cargo.payOnDeliveryType == 2 ? 'Kredi Kartı' : 'Nakit')),
                          if (_cargo.payOnDeliveryStatusText != null && _cargo.payOnDeliveryStatusText!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            _buildDetailRow('Tahsilat Durumu', _cargo.payOnDeliveryStatusText!),
                          ],
                          if (_cargo.payOnDeliveryOffsetDate != null) ...[
                            const SizedBox(height: 6),
                            _buildDetailRow('Tahmini Aktarım Tarihi', AppFormatters.formatDateTime(_cargo.payOnDeliveryOffsetDate)),
                          ],
                          if (_cargo.collectionPeriod != null) ...[
                            const SizedBox(height: 6),
                            _buildDetailRow('Tahsilat Vadesi', '${_cargo.collectionPeriod} Gün'),
                          ],
                          if (_cargo.podTransactionId != null && _cargo.podTransactionId!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            _buildDetailRow('K.Ö. İşlem Referansı', _cargo.podTransactionId!),
                          ],
                        ],
                        if (_cargo.description != null && _cargo.description!.isNotEmpty) ...[
                          const Divider(height: 16, color: AppColors.border),
                          _buildDetailRow('Paket Açıklaması', _cargo.description!),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Canlı kargo hareketleri listesi (taşıyıcı sisteminden alınan gerçek kayıtlar)
  Widget _buildRealTransactionsList(List<CargoTransaction> transactions) {
    // En yeni hareket en üstte görüntülenecek şekilde sırala
    final sorted = List<CargoTransaction>.from(transactions)..sort((a, b) {
      if (a.createdAt != null && b.createdAt != null) {
        return b.createdAt!.compareTo(a.createdAt!);
      }
      return 0;
    });

    return Column(
      children: List.generate(sorted.length, (index) {
        final tx = sorted[index];
        final isLatest = index == 0;
        final isOldest = index == sorted.length - 1;

        IconData iconData;
        Color badgeColor;
        switch (tx.type) {
          case 6:
            iconData = Icons.check_circle_rounded;
            badgeColor = AppColors.secondary;
            break;
          case 5:
            iconData = Icons.delivery_dining_rounded;
            badgeColor = AppColors.primary;
            break;
          case 4:
            iconData = Icons.warehouse_rounded;
            badgeColor = const Color(0xFF6366F1);
            break;
          case 2:
          case 3:
          case 9:
            iconData = Icons.local_shipping_rounded;
            badgeColor = const Color(0xFF2563EB);
            break;
          case 7:
          case 10:
          case 11:
          case 13:
            iconData = Icons.error_outline_rounded;
            badgeColor = AppColors.error;
            break;
          default:
            iconData = Icons.inventory_2_rounded;
            badgeColor = AppColors.primary;
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sol Çizgi ve Durum Noktası
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    if (!isLatest)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppColors.border,
                        ),
                      )
                    else
                      const Expanded(child: SizedBox()),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isLatest ? badgeColor : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: badgeColor, width: 2),
                      ),
                      child: Icon(
                        iconData,
                        size: 13,
                        color: isLatest ? Colors.white : badgeColor,
                      ),
                    ),
                    if (!isOldest)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppColors.border,
                        ),
                      )
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Sağ Hareket Bilgileri
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              tx.description.isNotEmpty ? tx.description : 'İşlem Kaydedildi',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isLatest ? FontWeight.w800 : FontWeight.w600,
                                color: isLatest ? AppColors.textPrimary : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          if (isLatest)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Son Durum',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: badgeColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (tx.location != null && tx.location!.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 13, color: AppColors.textMuted),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                tx.location!,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (tx.createdAt != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          AppFormatters.formatDateTime(tx.createdAt!),
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Standart 5 adımlı kargo boru hattı (özet akış)
  Widget _buildStandardTimelinePipeline(int activeStep) {
    return Column(
      children: [
        if (activeStep == -1) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cancel_outlined, size: 22, color: AppColors.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _cargo.latestActionTitle,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.error),
                      ),
                      if (_cargo.latestTransaction?.description.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            _cargo.latestTransaction!.description,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else if (activeStep == -2) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.assignment_return_rounded, size: 22, color: AppColors.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _cargo.latestActionTitle,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                      ),
                      if (_cargo.latestTransaction?.description.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            _cargo.latestTransaction!.description,
                            style: const TextStyle(fontSize: 12, color: Color(0xFFB45309)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        _buildTimelineTile(
          title: 'Sipariş Kaydedildi / Hazır',
          subtitle: 'Kargo bilgisi sisteme girildi',
          isCompleted: activeStep >= 0,
          isCurrent: activeStep == 0,
          isFirst: true,
          isLast: false,
        ),
        _buildTimelineTile(
          title: 'Şubeye Teslim Edildi',
          subtitle: 'Kargo çıkış şubesinde işleme alındı',
          isCompleted: activeStep >= 1,
          isCurrent: activeStep == 1,
          isFirst: false,
          isLast: false,
        ),
        _buildTimelineTile(
          title: 'Aktarma Merkezinde / Yolda',
          subtitle: 'Varış merkezine doğru transfer ediliyor',
          isCompleted: activeStep >= 2,
          isCurrent: activeStep == 2,
          isFirst: false,
          isLast: false,
        ),
        _buildTimelineTile(
          title: 'Kurye Dağıtıma Çıktı',
          subtitle: 'Alıcı adresine teslimat için kuryede',
          isCompleted: activeStep >= 3,
          isCurrent: activeStep == 3,
          isFirst: false,
          isLast: false,
        ),
        _buildTimelineTile(
          title: 'Teslim Edildi',
          subtitle: 'Kargo alıcıya başarıyla ulaştırıldı',
          isCompleted: activeStep >= 4,
          isCurrent: activeStep >= 4,
          isFirst: false,
          isLast: true,
        ),
        if (_cargo.latestTransaction != null && _cargo.latestTransaction!.description.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Son Sistem Hareketi',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _cargo.latestTransaction!.description,
                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w700,
            color: isHighlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineTile({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isCurrent,
    required bool isFirst,
    required bool isLast,
  }) {
    final color = isCurrent
        ? AppColors.primary
        : (isCompleted ? AppColors.secondary : AppColors.border);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Çizgi ve İkon Kolonu
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? AppColors.secondary : AppColors.border,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isCompleted ? color : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted && !isCurrent ? AppColors.secondary : AppColors.border,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Metinler
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isCurrent || isCompleted ? FontWeight.bold : FontWeight.w500,
                      color: isCurrent
                          ? AppColors.primary
                          : (isCompleted ? AppColors.textPrimary : AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
