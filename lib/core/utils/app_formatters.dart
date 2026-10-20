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
}
