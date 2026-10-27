class AppFormatters {
  /// Türk Lirası para birimi formatlayıcı
  /// Örnek: 1250000.50 -> "1.250.000,50 ₺"
  /// Örnek: 847.16 -> "847,16 ₺"
  /// Örnek: 10 -> "10,00 ₺"
  static String formatCurrency(
    num? amount, {
    bool includeSymbol = true,
    int decimalDigits = 2,
  }) {
    if (amount == null) return includeSymbol ? '0,00 ₺' : '0,00';

    final isNegative = amount < 0;
    final absAmount = amount.abs();

    // Ondalık ayrımı ve yuvarlama
    final fixedStr = absAmount.toStringAsFixed(decimalDigits);
    final parts = fixedStr.split('.');
    final wholePart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    // Binlik basamakları nokta ile ayır
    final buffer = StringBuffer();
    final len = wholePart.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(wholePart[i]);
    }

    final formattedWhole = buffer.toString();
    final result = decimalDigits > 0
        ? '$formattedWhole,$decimalPart'
        : formattedWhole;

    final sign = isNegative ? '-' : '';
    final symbol = includeSymbol ? ' ₺' : '';
    return '$sign$result$symbol';
  }

  /// Hero Bakiye kartı için sayıyı tam kısım ve kuruş/simge olarak böler.
  /// Büyük bakiye rakamını 32px, kuruş ve ₺ simgesini 18px göstermek için kullanılır.
  /// Örnek: 1250000.50 -> (whole: "1.250.000", decimal: ",50", symbol: "₺")
  static ({String whole, String decimal, String symbol}) splitCurrency(num? amount) {
    if (amount == null) {
      return (whole: '0', decimal: ',00', symbol: '₺');
    }

    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final fixedStr = absAmount.toStringAsFixed(2);
    final parts = fixedStr.split('.');
    final wholePart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00';

    final buffer = StringBuffer();
    final len = wholePart.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(wholePart[i]);
    }

    final prefix = isNegative ? '-' : '';
    return (
      whole: '$prefix${buffer.toString()}',
      decimal: ',$decimalPart',
      symbol: '₺',
    );
  }

  /// Büyük tutarlar için tek bakışta anlaşılır kompakt metin
  /// Örnek: 1.250.000 -> "1,25 Milyon ₺"
  /// Örnek: 450.000 -> "450 Bin ₺"
  /// Örnek: 8.550 -> "8,55 Bin ₺"
  static String formatCompactCurrency(num? amount) {
    if (amount == null || amount == 0) return '0 ₺';
    final absAmount = amount.abs();
    final sign = amount < 0 ? '-' : '';

    if (absAmount >= 1000000) {
      final millions = absAmount / 1000000;
      final formatted = millions.toStringAsFixed(millions >= 10 ? 1 : 2).replaceAll('.', ',');
      return '$sign$formatted Milyon ₺';
    } else if (absAmount >= 10000) {
      final thousands = absAmount / 1000;
      final formatted = thousands.toStringAsFixed(thousands >= 100 ? 0 : 1).replaceAll('.', ',');
      return '$sign$formatted Bin ₺';
    } else {
      return formatCurrency(amount);
    }
  }

  /// Sayaç veya adet gibi tam sayıları binlik nokta ile formatlar
  /// Örnek: 1288 -> "1.288"
  /// Örnek: 206 -> "206"
  static String formatNumber(num? number) {
    if (number == null) return '0';
    final wholePart = number.toInt().abs().toString();
    final buffer = StringBuffer();
    final len = wholePart.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(wholePart[i]);
    }
    return (number < 0 ? '-' : '') + buffer.toString();
  }

  /// Desi formatı
  /// Örnek: 2.5 -> "2,50 Desi"
  static String formatDesi(num? desi) {
    if (desi == null) return '0 Desi';
    return '${desi.toStringAsFixed(2).replaceAll('.', ',')} Desi';
  }

  /// UTC zaman damgasını yerel saate (Turkey UTC+3) dönüştürerek parse eder.
  /// Backend veritabanından gelebilecek formatlar:
  /// - '2026-10-27T09:24:00.000000Z' (Standart ISO UTC)
  /// - '2026-10-27 09:24:00' (MySQL raw UTC, Z veya offset içermez)
  /// - '2026-10-27T09:24:00' (ISO UTC, Z içermez)
  /// - '2026-10-27T12:24:00+03:00' (Offset içeren ISO)
  static DateTime? parseUtcDateTime(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) {
      return raw.isUtc ? raw.toLocal() : raw;
    }
    final str = raw.toString().trim();
    if (str.isEmpty) return null;

    try {
      // 1. Eğer ISO string 'Z' ile bitiyorsa veya timezone offset (+03:00) içeriyorsa:
      if (str.endsWith('Z') || str.endsWith('z') || RegExp(r'[+-]\d{2}(:\d{2})?$').hasMatch(str)) {
        return DateTime.tryParse(str)?.toLocal();
      }

      // 2. Zaman dilimi belirtilmemişse (MySQL '2026-10-27 09:24:00' veya ISO '2026-10-27T09:24:00'):
      // Backend UTC sakladığı için 'Z' ekleyerek UTC parse edip yerel saate çeviriyoruz:
      final normalized = str.contains('T') ? '${str}Z' : '${str.replaceFirst(' ', 'T')}Z';
      final parsedUtc = DateTime.tryParse(normalized);
      if (parsedUtc != null) {
        return parsedUtc.toLocal();
      }

      return DateTime.tryParse(str)?.toLocal();
    } catch (_) {
      return DateTime.tryParse(str)?.toLocal();
    }
  }

  /// Tarih ve saat formatlayıcı
  /// Örnek: DateTime(2026, 10, 24, 14, 30) -> "24.10.2026 14:30"
  static String formatDateTime(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }

  /// Hem virgül hem nokta ile girilen ondalıklı sayıları güvenle parse eder.
  /// Örnek: "12,50" -> 12.5, "12.50" -> 12.5
  static double parseDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    final str = val.toString().replaceAll(',', '.').trim();
    return double.tryParse(str) ?? fallback;
  }

  /// Güvenli ondalıklı sayı çözümleyici (geçersizse null döner)
  static double? tryParseDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    final str = val.toString().replaceAll(',', '.').trim();
    return double.tryParse(str);
  }
}
