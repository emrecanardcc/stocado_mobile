import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum CargoCompanyType {
  ptt,
  yurtici,
  surat,
  hepsijet,
  ups,
  kolayGelsin,
  aras,
  mng,
  trendyol,
  unknown;

  static CargoCompanyType fromString(String? raw) {
    if (raw == null) return CargoCompanyType.unknown;
    final lower = raw.toLowerCase().trim();
    if (lower.contains('ptt')) return CargoCompanyType.ptt;
    if (lower.contains('yurtici') || lower.contains('yurtiçi')) return CargoCompanyType.yurtici;
    if (lower.contains('surat') || lower.contains('sürat')) return CargoCompanyType.surat;
    if (lower.contains('hepsijet') || lower.contains('hepsi jet')) return CargoCompanyType.hepsijet;
    if (lower.contains('ups')) return CargoCompanyType.ups;
    if (lower.contains('kolay') || lower.contains('gelsin')) return CargoCompanyType.kolayGelsin;
    if (lower.contains('aras')) return CargoCompanyType.aras;
    if (lower.contains('mng')) return CargoCompanyType.mng;
    if (lower.contains('trendyol')) return CargoCompanyType.trendyol;
    return CargoCompanyType.unknown;
  }

  /// Orijinal yüksek çözünürlüklü marka logo dosya yolu
  String? get assetPath {
    switch (this) {
      case CargoCompanyType.ptt:
        return 'assets/images/cargo/ptt.png';
      case CargoCompanyType.yurtici:
        return 'assets/images/cargo/yurtici.png';
      case CargoCompanyType.surat:
        return 'assets/images/cargo/surat.png';
      case CargoCompanyType.hepsijet:
        return 'assets/images/cargo/hepsijet.png';
      case CargoCompanyType.ups:
        return 'assets/images/cargo/ups.png';
      case CargoCompanyType.kolayGelsin:
        return 'assets/images/cargo/kolay_gelsin.png';
      case CargoCompanyType.aras:
        return 'assets/images/cargo/aras.png';
      case CargoCompanyType.mng:
        return 'assets/images/cargo/mng.png';
      case CargoCompanyType.trendyol:
        return 'assets/images/cargo/trendyol.png';
      case CargoCompanyType.unknown:
        return null;
    }
  }
}

/// Kargo firmalarının orijinal yüksek çözünürlüklü kurumsal marka logoları bileşeni.
/// Orijinal görsel varlığı temiz ve dengeli beyaz arka plan kartı üzerinde render edilir;
/// asset çözümlenemediğinde veya bilinmeyen firmalarda zarif vektörel yedek tasarım devreye girer.
class CargoCompanyLogo extends StatelessWidget {
  final String? companyId;
  final String? companyName;
  final double size;
  final double borderRadius;
  final bool showBorder;

  const CargoCompanyLogo({
    super.key,
    this.companyId,
    this.companyName,
    this.size = 38.0,
    this.borderRadius = 10.0,
    this.showBorder = true,
  });

  CargoCompanyType get _type {
    final fromId = CargoCompanyType.fromString(companyId);
    if (fromId != CargoCompanyType.unknown) return fromId;
    return CargoCompanyType.fromString(companyName);
  }

  @override
  Widget build(BuildContext context) {
    final type = _type;
    final assetPath = type.assetPath;

    if (assetPath != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: showBorder ? Border.all(color: AppColors.border, width: 1.0) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.all(size * 0.12),
        child: Center(
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) => _buildFallbackContent(type),
          ),
        ),
      );
    }

    return _buildFallbackContainer(type);
  }

  Widget _buildFallbackContainer(CargoCompanyType type) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getBackgroundColor(type),
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder ? Border.all(color: _getBorderColor(type), width: 1.0) : null,
        boxShadow: [
          BoxShadow(
            color: _getBrandColor(type).withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(
        child: _buildFallbackContent(type),
      ),
    );
  }

  Color _getBackgroundColor(CargoCompanyType type) {
    switch (type) {
      case CargoCompanyType.ptt:
        return const Color(0xFFFDB913); // PTT Resmi Sarı
      case CargoCompanyType.yurtici:
        return const Color(0xFF004B93); // Yurtiçi Resmi Mavi
      case CargoCompanyType.surat:
        return const Color(0xFFE30613); // Sürat Resmi Kırmızı
      case CargoCompanyType.hepsijet:
        return const Color(0xFF111111); // HepsiJet Siyah
      case CargoCompanyType.ups:
        return const Color(0xFF351C15); // UPS Klasik Kahve
      case CargoCompanyType.kolayGelsin:
        return const Color(0xFF00B074); // Kolay Gelsin Yeşil
      case CargoCompanyType.aras:
        return const Color(0xFF00205B); // Aras Lacivert
      case CargoCompanyType.mng:
        return const Color(0xFF002A54); // MNG Derin Mavi
      case CargoCompanyType.trendyol:
        return const Color(0xFFF27A1A); // Trendyol Turuncu
      case CargoCompanyType.unknown:
        return AppColors.surfaceSecondary;
    }
  }

  Color _getBorderColor(CargoCompanyType type) {
    switch (type) {
      case CargoCompanyType.ptt:
        return const Color(0xFFE09F00);
      case CargoCompanyType.yurtici:
        return const Color(0xFF00366B);
      case CargoCompanyType.surat:
        return const Color(0xFFBA040F);
      case CargoCompanyType.hepsijet:
        return const Color(0xFF2E2E2E);
      case CargoCompanyType.ups:
        return const Color(0xFF26120D);
      case CargoCompanyType.kolayGelsin:
        return const Color(0xFF008F5D);
      case CargoCompanyType.aras:
        return const Color(0xFF00153D);
      case CargoCompanyType.mng:
        return const Color(0xFF001C38);
      case CargoCompanyType.trendyol:
        return const Color(0xFFD6640E);
      case CargoCompanyType.unknown:
        return AppColors.border;
    }
  }

  Color _getBrandColor(CargoCompanyType type) {
    switch (type) {
      case CargoCompanyType.ptt:
        return const Color(0xFFFDB913);
      case CargoCompanyType.yurtici:
        return const Color(0xFF004B93);
      case CargoCompanyType.surat:
        return const Color(0xFFE30613);
      case CargoCompanyType.hepsijet:
        return const Color(0xFFFF6000);
      case CargoCompanyType.ups:
        return const Color(0xFFFFB500);
      case CargoCompanyType.kolayGelsin:
        return const Color(0xFF00B074);
      case CargoCompanyType.aras:
        return const Color(0xFFFF5B00);
      case CargoCompanyType.mng:
        return const Color(0xFF00ADEF);
      case CargoCompanyType.trendyol:
        return const Color(0xFFF27A1A);
      case CargoCompanyType.unknown:
        return AppColors.primary;
    }
  }

  Widget _buildFallbackContent(CargoCompanyType type) {
    final scale = size / 38.0;

    switch (type) {
      case CargoCompanyType.ptt:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PTT',
              style: TextStyle(
                fontFamily: 'Roboto',
                color: const Color(0xFF002B49),
                fontWeight: FontWeight.w900,
                fontSize: 13.0 * scale,
                letterSpacing: 0.5,
                height: 0.9,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 1.5 * scale),
              width: 18 * scale,
              height: 2.0 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF002B49),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        );

      case CargoCompanyType.yurtici:
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              right: 4 * scale,
              top: 4 * scale,
              child: Container(
                width: 6 * scale,
                height: 6 * scale,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDB813),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Text(
              'YK',
              style: TextStyle(
                fontFamily: 'Roboto',
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14.0 * scale,
                letterSpacing: 0.8,
                height: 1.0,
              ),
            ),
          ],
        );

      case CargoCompanyType.surat:
        return Transform.rotate(
          angle: -0.05,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SÜRAT',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 8.5 * scale,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.5,
                  height: 1.0,
                ),
              ),
              Icon(
                Icons.fast_forward_rounded,
                color: Colors.white,
                size: 14 * scale,
              ),
            ],
          ),
        );

      case CargoCompanyType.hepsijet:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bolt_rounded,
              color: const Color(0xFFFF6000),
              size: 14 * scale,
            ),
            Text(
              'jet',
              style: TextStyle(
                fontFamily: 'Roboto',
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13.0 * scale,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.2,
                height: 1.0,
              ),
            ),
          ],
        );

      case CargoCompanyType.ups:
        return Container(
          width: 22 * scale,
          height: 24 * scale,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFFB500), width: 1.8 * scale),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(3 * scale),
              topRight: Radius.circular(3 * scale),
              bottomLeft: Radius.circular(11 * scale),
              bottomRight: Radius.circular(11 * scale),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            'ups',
            style: TextStyle(
              fontFamily: 'Roboto',
              color: const Color(0xFFFFB500),
              fontWeight: FontWeight.w900,
              fontSize: 9.5 * scale,
              height: 0.9,
            ),
          ),
        );

      case CargoCompanyType.kolayGelsin:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_run_rounded,
              color: Colors.white,
              size: 13 * scale,
            ),
            Text(
              'KG',
              style: TextStyle(
                fontFamily: 'Roboto',
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11.5 * scale,
                letterSpacing: 0.5,
                height: 1.0,
              ),
            ),
          ],
        );

      case CargoCompanyType.aras:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 4 * scale,
                  height: 4 * scale,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5B00),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 2 * scale),
                Text(
                  'aras',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11.5 * scale,
                    letterSpacing: 0.5,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ],
        );

      case CargoCompanyType.mng:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'MNG',
              style: TextStyle(
                fontFamily: 'Roboto',
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 10.5 * scale,
                letterSpacing: 0.5,
                height: 1.0,
              ),
            ),
            Icon(
              Icons.navigation_rounded,
              color: const Color(0xFF00ADEF),
              size: 10 * scale,
            ),
          ],
        );

      case CargoCompanyType.trendyol:
        return Text(
          'TX',
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 13.0 * scale,
            letterSpacing: 0.5,
            height: 1.0,
          ),
        );

      case CargoCompanyType.unknown:
        return Icon(
          Icons.local_shipping_rounded,
          color: AppColors.primary,
          size: 18 * scale,
        );
    }
  }
}
