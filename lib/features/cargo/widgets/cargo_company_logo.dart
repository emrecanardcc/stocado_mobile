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
    if (lower == 'ptt' || lower.contains('ptt')) return CargoCompanyType.ptt;
    if (lower == 'yk' || lower.contains('yurtici') || lower.contains('yurtiçi')) return CargoCompanyType.yurtici;
    if (lower == 'sur' || lower.contains('surat') || lower.contains('sürat')) return CargoCompanyType.surat;
    if (lower == 'hj' || lower.contains('hepsijet') || lower.contains('hepsi jet')) return CargoCompanyType.hepsijet;
    if (lower == 'ups' || lower.contains('ups')) return CargoCompanyType.ups;
    if (lower == 'kg' || lower.contains('kolay') || lower.contains('gelsin')) return CargoCompanyType.kolayGelsin;
    if (lower == 'aras' || lower.contains('aras')) return CargoCompanyType.aras;
    if (lower == 'mng' || lower.contains('mng')) return CargoCompanyType.mng;
    if (lower == 'ty' || lower.contains('trendyol')) return CargoCompanyType.trendyol;
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

  String get displayName {
    switch (this) {
      case CargoCompanyType.ptt:
        return 'PTT Kargo';
      case CargoCompanyType.yurtici:
        return 'Yurtiçi Kargo';
      case CargoCompanyType.surat:
        return 'Sürat Kargo';
      case CargoCompanyType.hepsijet:
        return 'HepsiJET';
      case CargoCompanyType.ups:
        return 'UPS Kargo';
      case CargoCompanyType.kolayGelsin:
        return 'Kolay Gelsin';
      case CargoCompanyType.aras:
        return 'Aras Kargo';
      case CargoCompanyType.mng:
        return 'MNG Kargo';
      case CargoCompanyType.trendyol:
        return 'Trendyol Express';
      case CargoCompanyType.unknown:
        return 'Kargo';
    }
  }

  Color get brandColor {
    switch (this) {
      case CargoCompanyType.ptt:
        return const Color(0xFF003E7E);
      case CargoCompanyType.yurtici:
        return const Color(0xFF004B93);
      case CargoCompanyType.surat:
        return const Color(0xFFE30613);
      case CargoCompanyType.hepsijet:
        return const Color(0xFFFF6000);
      case CargoCompanyType.ups:
        return const Color(0xFF351C15);
      case CargoCompanyType.kolayGelsin:
        return const Color(0xFF00AA4F);
      case CargoCompanyType.aras:
        return const Color(0xFF002B49);
      case CargoCompanyType.mng:
        return const Color(0xFF002244);
      case CargoCompanyType.trendyol:
        return const Color(0xFFF27A1A);
      case CargoCompanyType.unknown:
        return AppColors.primary;
    }
  }
}

/// Kargo firmalarının güncel, orijinal kurumsal marka logoları bileşeni.
/// Kartlarda ve listelerde yatayda net okunan, basıklaşmayan ve standartlaştırılmış
/// kurumsal logo formatı sunar (HepsiJET, SURAT, Ptt, Yurtiçi, Kolay Gelsin vb.).
class CargoCompanyLogo extends StatelessWidget {
  final String? companyId;
  final String? companyName;
  final double? size;
  final double? height;
  final double? width;
  final double borderRadius;
  final bool showBorder;
  final bool? isHorizontal;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool showShadow;
  final bool useContainer;

  const CargoCompanyLogo({
    super.key,
    this.companyId,
    this.companyName,
    this.size,
    this.height,
    this.width,
    this.borderRadius = 8.0,
    this.showBorder = true,
    this.isHorizontal,
    this.backgroundColor,
    this.padding,
    this.showShadow = false,
    this.useContainer = true,
  });

  CargoCompanyType get _type {
    final fromId = CargoCompanyType.fromString(companyId);
    if (fromId != CargoCompanyType.unknown) return fromId;
    return CargoCompanyType.fromString(companyName);
  }

  @override
  Widget build(BuildContext context) {
    final type = _type;

    if (!useContainer) {
      final h = height ?? 20.0;
      final logo = _buildHorizontalLogo(context, type, h, companyName: companyName);
      if (width != null) {
        return SizedBox(
          height: h,
          width: width,
          child: FittedBox(
            fit: BoxFit.contain,
            child: logo,
          ),
        );
      }
      return SizedBox(
        height: h,
        child: logo,
      );
    }

    final double effectiveHeight;
    final double effectiveWidth;

    if (width != null && height != null) {
      effectiveWidth = width!;
      effectiveHeight = height!;
    } else if (size != null) {
      effectiveHeight = size!;
      effectiveWidth = (size! * 2.375).roundToDouble();
    } else if (height != null) {
      effectiveHeight = height!;
      effectiveWidth = (height! * 2.375).roundToDouble();
    } else if (width != null) {
      effectiveWidth = width!;
      effectiveHeight = (width! / 2.375).roundToDouble();
    } else {
      effectiveWidth = 76.0;
      effectiveHeight = 32.0;
    }

    final innerPadding = padding ??
        EdgeInsets.symmetric(
          horizontal: (effectiveWidth * 0.08).clamp(4.0, 10.0),
          vertical: (effectiveHeight * 0.12).clamp(2.0, 6.0),
        );
    final logoRefHeight = (effectiveHeight - (effectiveHeight * 0.24)).clamp(10.0, 40.0);

    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      padding: innerPadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(color: const Color(0xFFE2E8F0), width: 1.0)
            : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1.5),
                ),
              ]
            : null,
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: _buildHorizontalLogo(context, type, logoRefHeight, companyName: companyName),
        ),
      ),
    );
  }

  Widget _buildHorizontalLogo(
    BuildContext context,
    CargoCompanyType type,
    double h, {
    String? companyName,
  }) {
    switch (type) {
      case CargoCompanyType.hepsijet:
        final fs = h * 0.88;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'hepsi',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: fs,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFF6000),
                letterSpacing: -0.6,
                height: 1.0,
              ),
            ),
            Text(
              'JET',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: fs,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF431870),
                letterSpacing: 0.2,
                height: 1.0,
              ),
            ),
            Transform.translate(
              offset: Offset(fs * 0.06, -fs * 0.36),
              child: Transform.rotate(
                angle: 0.45,
                child: Container(
                  width: fs * 0.16,
                  height: fs * 0.42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6000),
                    borderRadius: BorderRadius.circular(fs * 0.05),
                  ),
                ),
              ),
            ),
          ],
        );

      case CargoCompanyType.surat:
        final fs = h * 0.82;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(h * 0.86, h * 0.86),
              painter: const SuratEmblemPainter(),
            ),
            SizedBox(width: h * 0.2),
            Text(
              'SURAT',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: fs,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF00387A),
                letterSpacing: 0.6,
                height: 1.0,
              ),
            ),
          ],
        );

      case CargoCompanyType.ptt:
        final fs = h * 0.86;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(h * 0.95, h * 0.95),
              painter: const PttEmblemPainter(),
            ),
            SizedBox(width: h * 0.2),
            Text(
              'Ptt',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: fs * 1.05,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF003E7E),
                letterSpacing: -0.2,
                height: 1.0,
              ),
            ),
          ],
        );

      case CargoCompanyType.yurtici:
        final fs = h * 0.82;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(h * 0.95, h * 0.95),
              painter: const YurticiEmblemPainter(),
            ),
            SizedBox(width: h * 0.22),
            Text(
              'yurtiçi',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: fs * 0.92,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF004B93),
                letterSpacing: -0.3,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              'kargo',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: fs * 0.92,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFF37021),
                letterSpacing: -0.3,
                height: 1.0,
              ),
            ),
          ],
        );

      case CargoCompanyType.kolayGelsin:
        final fs = h * 0.82;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(h * 0.9, h * 0.9),
              painter: const KolayGelsinEmblemPainter(),
            ),
            SizedBox(width: h * 0.2),
            Text(
              'kolay gelsin',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: fs * 0.88,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00AA4F),
                letterSpacing: -0.3,
                height: 1.0,
              ),
            ),
          ],
        );

      case CargoCompanyType.aras:
        final fs = h * 0.84;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(h * 0.82, h * 0.82),
              painter: const ArasEmblemPainter(),
            ),
            SizedBox(width: h * 0.24),
            Text(
              'aras',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: fs * 0.96,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF002B49),
                letterSpacing: -0.3,
                height: 1.0,
              ),
            ),
          ],
        );

      case CargoCompanyType.mng:
        final fs = h * 0.82;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(h * 0.95, h * 0.95),
              painter: const MngEmblemPainter(),
            ),
            SizedBox(width: h * 0.2),
            Text(
              'MNG',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: fs * 0.9,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF002244),
                letterSpacing: -0.2,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              'kargo',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: fs * 0.9,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFF7900),
                letterSpacing: -0.2,
                height: 1.0,
              ),
            ),
          ],
        );

      case CargoCompanyType.ups:
        final fs = h * 0.8;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: fs * 0.22, vertical: fs * 0.08),
              decoration: BoxDecoration(
                color: const Color(0xFF351C15),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(fs * 0.15),
                  topRight: Radius.circular(fs * 0.15),
                  bottomLeft: Radius.circular(fs * 0.4),
                  bottomRight: Radius.circular(fs * 0.4),
                ),
                border: Border.all(color: const Color(0xFFFFB500), width: 1.2),
              ),
              child: Text(
                'ups',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: fs * 0.65,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFFB500),
                  height: 1.0,
                ),
              ),
            ),
            SizedBox(width: h * 0.2),
            Text(
              'UPS',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: fs * 0.85,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF351C15),
                letterSpacing: 0.5,
                height: 1.0,
              ),
            ),
          ],
        );

      case CargoCompanyType.trendyol:
        final fs = h * 0.8;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'trendyol',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: fs * 0.85,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF18181B),
                letterSpacing: -0.3,
                height: 1.0,
              ),
            ),
            SizedBox(width: h * 0.15),
            Container(
              padding: EdgeInsets.symmetric(horizontal: fs * 0.2, vertical: fs * 0.06),
              decoration: BoxDecoration(
                color: const Color(0xFFF27A1A),
                borderRadius: BorderRadius.circular(fs * 0.15),
              ),
              child: Text(
                'express',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: fs * 0.58,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),
          ],
        );

      case CargoCompanyType.unknown:
        final label = (companyName != null && companyName.trim().isNotEmpty)
            ? companyName.trim().toUpperCase()
            : 'KARGO';
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: h * 0.72,
              color: const Color(0xFF475569),
            ),
            SizedBox(width: h * 0.16),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: h * 0.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF475569),
                letterSpacing: 0.4,
                height: 1.0,
              ),
            ),
          ],
        );
    }
  }
}

/// Sürat Kargo'nun kurumsal dinamik paralelkenar amblemi
class SuratEmblemPainter extends CustomPainter {
  final Color color;
  const SuratEmblemPainter({this.color = const Color(0xFFE30613)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path()
      ..moveTo(w * 0.28, 0)
      ..lineTo(w * 0.95, 0)
      ..lineTo(w * 0.72, h)
      ..lineTo(w * 0.05, h)
      ..close();

    canvas.drawPath(path, paint);

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final cut = Path()
      ..moveTo(w * 0.44, 0)
      ..lineTo(w * 0.54, 0)
      ..lineTo(w * 0.34, h)
      ..lineTo(w * 0.24, h)
      ..close();

    canvas.drawPath(cut, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// PTT Kargo'nun sarı kanat & mavi posta borusu amblemi
class PttEmblemPainter extends CustomPainter {
  const PttEmblemPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final yellowPaint = Paint()
      ..color = const Color(0xFFFDB913)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final yellowPath = Path()
      ..moveTo(w * 0.15, h * 0.45)
      ..quadraticBezierTo(w * 0.4, h * 0.05, w * 0.9, h * 0.15)
      ..quadraticBezierTo(w * 0.5, h * 0.45, w * 0.75, h * 0.8)
      ..quadraticBezierTo(w * 0.35, h * 0.85, w * 0.15, h * 0.45)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    final bluePaint = Paint()
      ..color = const Color(0xFF003E7E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.16
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final horn = Path()
      ..moveTo(w * 0.08, h * 0.48)
      ..quadraticBezierTo(w * 0.35, h * 0.96, w * 0.92, h * 0.6);
    canvas.drawPath(horn, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Yurtiçi Kargo'nun 'YK' çift yönlü dinamik şerit amblemi
class YurticiEmblemPainter extends CustomPainter {
  const YurticiEmblemPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bluePaint = Paint()
      ..color = const Color(0xFF004B93)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final orangePaint = Paint()
      ..color = const Color(0xFFF37021)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final blue = Path()
      ..moveTo(w * 0.05, h * 0.05)
      ..lineTo(w * 0.38, h * 0.05)
      ..lineTo(w * 0.72, h * 0.95)
      ..lineTo(w * 0.39, h * 0.95)
      ..close();
    canvas.drawPath(blue, bluePaint);

    final orangeUp = Path()
      ..moveTo(w * 0.85, h * 0.05)
      ..lineTo(w * 0.55, h * 0.48)
      ..lineTo(w * 0.40, h * 0.48)
      ..lineTo(w * 0.65, h * 0.05)
      ..close();
    canvas.drawPath(orangeUp, orangePaint);

    final orangeDown = Path()
      ..moveTo(w * 0.55, h * 0.52)
      ..lineTo(w * 0.88, h * 0.95)
      ..lineTo(w * 0.68, h * 0.95)
      ..lineTo(w * 0.42, h * 0.58)
      ..close();
    canvas.drawPath(orangeDown, orangePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Aras Kargo'nun kırmızı kare & dinamik kanat amblemi
class ArasEmblemPainter extends CustomPainter {
  const ArasEmblemPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final redPaint = Paint()
      ..color = const Color(0xFFE30613)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final diamond = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.5)
      ..lineTo(w * 0.5, h)
      ..lineTo(0, h * 0.5)
      ..close();
    canvas.drawPath(diamond, redPaint);

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final plane = Path()
      ..moveTo(w * 0.25, h * 0.5)
      ..lineTo(w * 0.75, h * 0.28)
      ..lineTo(w * 0.62, h * 0.72)
      ..lineTo(w * 0.52, h * 0.55)
      ..close();
    canvas.drawPath(plane, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// MNG Kargo'nun kurumsal dinamik uçan kuş amblemi
class MngEmblemPainter extends CustomPainter {
  final Color color;
  const MngEmblemPainter({this.color = const Color(0xFFFF7900)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path()
      ..moveTo(0, h * 0.62)
      ..quadraticBezierTo(w * 0.12, h * 0.52, w * 0.22, h * 0.55)
      ..quadraticBezierTo(w * 0.36, h * 0.54, w * 0.46, h * 0.40)
      ..quadraticBezierTo(w * 0.52, h * 0.14, w * 0.60, h * 0.02)
      ..quadraticBezierTo(w * 0.62, h * 0.20, w * 0.68, h * 0.26)
      ..quadraticBezierTo(w * 0.74, h * 0.30, w * 0.84, h * 0.32)
      ..quadraticBezierTo(w * 0.72, h * 0.46, w * 0.64, h * 0.53)
      ..quadraticBezierTo(w * 0.84, h * 0.57, w, h * 0.60)
      ..quadraticBezierTo(w * 0.76, h * 0.68, w * 0.55, h * 0.68)
      ..quadraticBezierTo(w * 0.36, h * 0.68, w * 0.25, h * 0.64)
      ..quadraticBezierTo(w * 0.10, h * 0.66, 0, h * 0.62)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Kolay Gelsin'in konum pini & yeşil tik kurumsal amblemi
class KolayGelsinEmblemPainter extends CustomPainter {
  const KolayGelsinEmblemPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Pin halkası (gri kontur)
    final pinPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.13
      ..isAntiAlias = true;

    final pinCenter = Offset(w * 0.5, h * 0.44);
    canvas.drawCircle(pinCenter, w * 0.38, pinPaint);

    // Yeşil tik amblemi
    final checkPaint = Paint()
      ..color = const Color(0xFF00AA4F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final checkPath = Path()
      ..moveTo(w * 0.24, h * 0.54)
      ..lineTo(w * 0.44, h * 0.78)
      ..lineTo(w * 0.82, h * 0.28);
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

