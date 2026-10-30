import 'dart:math' as math;
import '../../cargo/models/cargo_offer_model.dart';
import 'pricing_plan_model.dart';

/// Stocado Resmi Kargo Fiyat Listesi ve Hesaplama Motoru (kargo.txt & OpenAPI Paritesi)
class CargoTariffEngine {
  CargoTariffEngine._();

  static const String codeHepsiJet = 'hepsijet';
  static const String codePtt = 'ptt-kargo';
  static const String codeSurat = 'surat-kargo';
  static const String codeKolayGelsin = 'kolay-gelsin';
  static const String codeYurtici = 'yurtici-kargo';
  static const String codeUps = 'ups';

  /// Firma kodunu veya unvanını standart firma slug'ına dönüştürür
  static String normalizeCompanyCode(String? codeOrName) {
    if (codeOrName == null || codeOrName.trim().isEmpty) return '';
    final lower = codeOrName.toLowerCase().replaceAll('-', '').replaceAll('_', '').replaceAll(' ', '');
    if (lower.contains('ptt')) return codePtt;
    if (lower.contains('hepsijet') || lower.contains('hepsi')) return codeHepsiJet;
    if (lower.contains('surat') || lower.contains('sürat')) return codeSurat;
    if (lower.contains('kolay') || lower.contains('gelsin')) return codeKolayGelsin;
    if (lower.contains('yurtici') || lower.contains('yurtiçi')) return codeYurtici;
    if (lower.contains('ups')) return codeUps;
    return codeOrName;
  }

  // ==========================================
  // STANDART FİYAT KADEMELERİ (kargo.txt)
  // ==========================================

  /// HepsiJET Standart Kademe Fiyatları (KDV Dahil)
  /// 0-4: 116.00 ₺ | 5-10: 190.00 ₺ | 11-20: 253.00 ₺ | 21-30: 370.00 ₺ | 31-40: 441.00 ₺ | +1 desi: 25.00 ₺
  static const Map<int, double> hepsijetStandard = {
    0: 116.00,
    1: 116.00,
    2: 116.00,
    3: 116.00,
    4: 116.00,
    5: 190.00,
    6: 190.00,
    7: 190.00,
    8: 190.00,
    9: 190.00,
    10: 190.00,
    11: 253.00,
    12: 253.00,
    13: 253.00,
    14: 253.00,
    15: 253.00,
    16: 253.00,
    17: 253.00,
    18: 253.00,
    19: 253.00,
    20: 253.00,
    21: 370.00,
    22: 370.00,
    23: 370.00,
    24: 370.00,
    25: 370.00,
    26: 370.00,
    27: 370.00,
    28: 370.00,
    29: 370.00,
    30: 370.00,
    31: 441.00,
    32: 441.00,
    33: 441.00,
    34: 441.00,
    35: 441.00,
    36: 441.00,
    37: 441.00,
    38: 441.00,
    39: 441.00,
    40: 441.00,
  };

  /// HepsiJET Alıcı Ödemeli Kademe Fiyatları (KDV Dahil)
  /// 0-4: 167.00 ₺ | 5-10: 257.00 ₺ | 11-20: 340.00 ₺ | 21: 465.00 ₺ | 22-30: 525.00 ₺
  static const Map<int, double> hepsijetReceiverPays = {
    0: 167.00,
    1: 167.00,
    2: 167.00,
    3: 167.00,
    4: 167.00,
    5: 257.00,
    6: 257.00,
    7: 257.00,
    8: 257.00,
    9: 257.00,
    10: 257.00,
    11: 340.00,
    12: 340.00,
    13: 340.00,
    14: 340.00,
    15: 340.00,
    16: 340.00,
    17: 340.00,
    18: 340.00,
    19: 340.00,
    20: 340.00,
    21: 465.00,
    22: 525.00,
    23: 525.00,
    24: 525.00,
    25: 525.00,
    26: 525.00,
    27: 525.00,
    28: 525.00,
    29: 525.00,
    30: 525.00,
  };

  /// PTT Kargo 0-30 Desi Standart Fiyatları (KDV Dahil)
  /// Artan desi: 25.79 ₺
  static const Map<int, double> pttStandard = {
    0: 104.00,
    1: 107.00,
    2: 124.00,
    3: 142.00,
    4: 167.00,
    5: 179.00,
    6: 192.00,
    7: 222.00,
    8: 234.00,
    9: 238.00,
    10: 240.00,
    11: 288.00,
    12: 300.00,
    13: 306.00,
    14: 312.00,
    15: 314.00,
    16: 384.00,
    17: 396.00,
    18: 402.00,
    19: 414.00,
    20: 420.00,
    21: 474.00,
    22: 498.00,
    23: 504.00,
    24: 510.00,
    25: 516.00,
    26: 564.00,
    27: 576.00,
    28: 588.00,
    29: 600.00,
    30: 613.00,
  };

  /// Sürat Kargo Standart Kademe Fiyatları (KDV Dahil)
  /// 0-2: 117.00 ₺ | 3: 131 | 4: 145 | ... | 30: 462.00 ₺ | Artan: 23.34 ₺
  static const Map<int, double> suratStandard = {
    0: 117.00,
    1: 117.00,
    2: 117.00,
    3: 131.00,
    4: 145.00,
    5: 146.00,
    6: 182.00,
    7: 195.00,
    8: 201.00,
    9: 205.00,
    10: 206.00,
    11: 218.00,
    12: 220.00,
    13: 224.00,
    14: 240.00,
    15: 244.00,
    16: 257.00,
    17: 264.00,
    18: 271.00,
    19: 284.00,
    20: 290.00,
    21: 323.00,
    22: 337.00,
    23: 356.00,
    24: 370.00,
    25: 383.00,
    26: 396.00,
    27: 416.00,
    28: 429.00,
    29: 442.00,
    30: 462.00,
  };

  /// Sürat Kargo Alıcı Ödemeli Kademe Fiyatları (KDV Dahil)
  /// 0-3: 202.00 ₺ | 4-5: 238.00 ₺ | 6-10: 259.00 ₺ | 11-15: 317.00 ₺ | 16-20: 364.00 ₺ | 21-25: 440.00 ₺ | 26-30: 515.00 ₺
  static const Map<int, double> suratReceiverPays = {
    0: 202.00,
    1: 202.00,
    2: 202.00,
    3: 202.00,
    4: 238.00,
    5: 238.00,
    6: 259.00,
    7: 259.00,
    8: 259.00,
    9: 259.00,
    10: 259.00,
    11: 317.00,
    12: 317.00,
    13: 317.00,
    14: 317.00,
    15: 317.00,
    16: 364.00,
    17: 364.00,
    18: 364.00,
    19: 364.00,
    20: 364.00,
    21: 440.00,
    22: 440.00,
    23: 440.00,
    24: 440.00,
    25: 440.00,
    26: 515.00,
    27: 515.00,
    28: 515.00,
    29: 515.00,
    30: 515.00,
  };

  /// Kolay Gelsin Standart Kademe Fiyatları (KDV Dahil)
  /// 0-2: 132.00 ₺ | 3-5: 137.00 ₺ | 6-10: 151.00 ₺ | 11-15: 235.00 ₺ | 16-20: 246.00 ₺ | 21-25: 330.00 ₺ | 26-30: 366.00 ₺ | Artan: 23.34 ₺
  static const Map<int, double> kolayGelsinStandard = {
    0: 132.00,
    1: 132.00,
    2: 132.00,
    3: 137.00,
    4: 137.00,
    5: 137.00,
    6: 151.00,
    7: 151.00,
    8: 151.00,
    9: 151.00,
    10: 151.00,
    11: 235.00,
    12: 235.00,
    13: 235.00,
    14: 235.00,
    15: 235.00,
    16: 246.00,
    17: 246.00,
    18: 246.00,
    19: 246.00,
    20: 246.00,
    21: 330.00,
    22: 330.00,
    23: 330.00,
    24: 330.00,
    25: 330.00,
    26: 366.00,
    27: 366.00,
    28: 366.00,
    29: 366.00,
    30: 366.00,
  };

  /// Yurtiçi Kargo Standart Kademe Fiyatları (KDV Dahil)
  /// 0: 229 | 1: 234 | 2: 239 | ... | 30: 984.00 ₺ | Artan: 39.30 ₺
  static const Map<int, double> yurticiStandard = {
    0: 229.00,
    1: 234.00,
    2: 239.00,
    3: 251.00,
    4: 265.00,
    5: 286.00,
    6: 336.00,
    7: 354.00,
    8: 372.00,
    9: 384.00,
    10: 396.00,
    11: 480.00,
    12: 492.00,
    13: 504.00,
    14: 552.00,
    15: 588.00,
    16: 612.00,
    17: 642.00,
    18: 672.00,
    19: 696.00,
    20: 708.00,
    21: 768.00,
    22: 780.00,
    23: 792.00,
    24: 822.00,
    25: 876.00,
    26: 954.00,
    27: 960.00,
    28: 966.00,
    29: 972.00,
    30: 984.00,
  };

  /// UPS Kargo Standart Kademe Fiyatları (KDV Dahil)
  /// 0-5: 196.00 ₺ | 6-10: 241.00 ₺ | 11-15: 274.00 ₺ | 16-25: 307.00 ₺ | 26-30: 359.00 ₺ | 31-40: 411.00 ₺ | 41-50: 496.00 ₺ | 51-55: 562.00 ₺ | 56-60: 653.00 ₺ | 61-65: 718.00 ₺ | 66-70: 836.00 ₺ | Artan: 28.66 ₺
  static const Map<int, double> upsStandard = {
    0: 196.00,
    1: 196.00,
    2: 196.00,
    3: 196.00,
    4: 196.00,
    5: 196.00,
    6: 241.00,
    7: 241.00,
    8: 241.00,
    9: 241.00,
    10: 241.00,
    11: 274.00,
    12: 274.00,
    13: 274.00,
    14: 274.00,
    15: 274.00,
    16: 307.00,
    17: 307.00,
    18: 307.00,
    19: 307.00,
    20: 307.00,
    21: 307.00,
    22: 307.00,
    23: 307.00,
    24: 307.00,
    25: 307.00,
    26: 359.00,
    27: 359.00,
    28: 359.00,
    29: 359.00,
    30: 359.00,
    31: 411.00,
    32: 411.00,
    33: 411.00,
    34: 411.00,
    35: 411.00,
    36: 411.00,
    37: 411.00,
    38: 411.00,
    39: 411.00,
    40: 411.00,
    41: 496.00,
    42: 496.00,
    43: 496.00,
    44: 496.00,
    45: 496.00,
    46: 496.00,
    47: 496.00,
    48: 496.00,
    49: 496.00,
    50: 496.00,
    51: 562.00,
    52: 562.00,
    53: 562.00,
    54: 562.00,
    55: 562.00,
    56: 653.00,
    57: 653.00,
    58: 653.00,
    59: 653.00,
    60: 653.00,
    61: 718.00,
    62: 718.00,
    63: 718.00,
    64: 718.00,
    65: 718.00,
    66: 836.00,
    67: 836.00,
    68: 836.00,
    69: 836.00,
    70: 836.00,
  };

  /// UPS Kargo Alıcı Ödemeli Kademe Fiyatları (KDV Dahil)
  /// 0-5: 426 ₺ | 6-10: 486 | 11-15: 547 | 16-25: 622 | 26-30: 695 | 31-40: 838 | 41-43: 1014 | 44-50: 1161 | 51-55: 719 | 56-60: 791 | 61-65: 864 | 66-70: 825.00 ₺
  static const Map<int, double> upsReceiverPays = {
    0: 426.00,
    1: 426.00,
    2: 426.00,
    3: 426.00,
    4: 426.00,
    5: 426.00,
    6: 486.00,
    7: 486.00,
    8: 486.00,
    9: 486.00,
    10: 486.00,
    11: 547.00,
    12: 547.00,
    13: 547.00,
    14: 547.00,
    15: 547.00,
    16: 622.00,
    17: 622.00,
    18: 622.00,
    19: 622.00,
    20: 622.00,
    21: 622.00,
    22: 622.00,
    23: 622.00,
    24: 622.00,
    25: 622.00,
    26: 695.00,
    27: 695.00,
    28: 695.00,
    29: 695.00,
    30: 695.00,
    31: 838.00,
    32: 838.00,
    33: 838.00,
    34: 838.00,
    35: 838.00,
    36: 838.00,
    37: 838.00,
    38: 838.00,
    39: 838.00,
    40: 838.00,
    41: 1014.00,
    42: 1014.00,
    43: 1014.00,
    44: 1161.00,
    45: 1161.00,
    46: 1161.00,
    47: 1161.00,
    48: 1161.00,
    49: 1161.00,
    50: 1161.00,
    51: 719.00,
    52: 719.00,
    53: 719.00,
    54: 719.00,
    55: 719.00,
    56: 791.00,
    57: 791.00,
    58: 791.00,
    59: 791.00,
    60: 791.00,
    61: 864.00,
    62: 864.00,
    63: 864.00,
    64: 864.00,
    65: 864.00,
    66: 825.00,
    67: 825.00,
    68: 825.00,
    69: 825.00,
    70: 825.00,
  };

  // ==========================================
  // ARTAN DESİ ÜCRETLERİ (kargo.txt)
  // ==========================================
  static const double additionalDesiHepsiJet = 25.00;
  static const double additionalDesiPtt = 25.79;
  static const double additionalDesiSurat = 23.34;
  static const double additionalDesiKolayGelsin = 23.34;
  static const double additionalDesiYurtici = 39.30;
  static const double additionalDesiUps = 28.66;

  // ==========================================
  // KONTROLLÜ TESLİMAT ÜCRETLERİ (kargo.txt)
  // ==========================================
  static const double controlledDeliveryFeePtt = 49.99;
  static const double controlledDeliveryFeeUps = 60.84;

  /// Kontrollü teslimat ücretini döner (Desteklemeyen firmalarda 0.0)
  static double getControlledDeliveryFee(String companyCode) {
    final code = normalizeCompanyCode(companyCode);
    if (code == codePtt) return controlledDeliveryFeePtt;
    if (code == codeUps) return controlledDeliveryFeeUps;
    return 0.0;
  }

  /// Firmanın Kontrollü Teslimat destekleyip desteklemediği
  static bool isControlledDeliverySupported(String companyCode) {
    final code = normalizeCompanyCode(companyCode);
    return code == codePtt || code == codeUps;
  }

  /// Firmanın Kapıda Ödeme (POD) destekleyip desteklemediği
  static bool isPodSupported(String companyCode, {bool isCreditCard = false}) {
    final code = normalizeCompanyCode(companyCode);
    if (isCreditCard) {
      // Yalnızca Sürat Kargo ve UPS Kargo kredi kartı ile kapıda ödeme destekler
      return code == codeSurat || code == codeUps;
    }
    // Nakit Kapıda Ödeme HepsiJET, PTT, Sürat ve UPS tarafından desteklenir
    return code == codeHepsiJet || code == codePtt || code == codeSurat || code == codeUps;
  }

  // ==========================================
  // KAPIDA ÖDEME KOMİSYON KESİNTİLERİ (kargo.txt)
  // ==========================================

  /// Kapıda Ödeme Nakit / Kart Komisyon Tutarını hesaplar (kargo.txt birebir)
  static double calculatePodFee(
    String companyCode,
    double amount, {
    bool isCreditCard = false,
  }) {
    final code = normalizeCompanyCode(companyCode);
    final amt = math.max(0.0, amount);

    // Kredi kartı kapıda ödeme
    if (isCreditCard) {
      if (code == codeSurat) {
        // kargo.txt: "Kredi kartı ile yapılan tahsilatlarda, nakit tahsilat bedeline ek olarak Erken Ödeme Kesintisi uygulanır."
        // Erken ödeme kesintisi: %5.40
        final cashFee = _calculateCashPodFeeSurat(amt);
        final earlyFee = amt * 0.054;
        return cashFee + earlyFee;
      } else if (code == codeUps) {
        // kargo.txt: "Kredi kartı ile yapılan tahsilatlarda, nakit tahsilat bedeline ek olarak Erken Ödeme Kesintisi uygulanır."
        // Erken ödeme kesintisi: %5.96
        final cashFee = _calculateCashPodFeeUps(amt);
        final earlyFee = amt * 0.0596;
        return cashFee + earlyFee;
      }
      return 0.0;
    }

    // Nakit kapıda ödeme
    switch (code) {
      case codeHepsiJet:
        return _calculateCashPodFeeHepsiJet(amt);
      case codePtt:
        return _calculateCashPodFeePtt(amt);
      case codeSurat:
        return _calculateCashPodFeeSurat(amt);
      case codeUps:
        return _calculateCashPodFeeUps(amt);
      default:
        return 15.0; // Standart taban komisyon
    }
  }

  static double _calculateCashPodFeeHepsiJet(double amount) {
    if (amount <= 500) return 60.06;
    if (amount <= 1000) return 79.20;
    if (amount <= 2000) return 113.84;
    if (amount <= 3000) return 145.20;
    if (amount <= 4000) return 207.60;
    if (amount <= 5000) return 246.00;
    return 406.80;
  }

  static double _calculateCashPodFeePtt(double amount) {
    if (amount <= 500) return 12.00;
    if (amount <= 1000) return 14.40;
    if (amount <= 2000) return 18.00;
    return 30.00;
  }

  static double _calculateCashPodFeeSurat(double amount) {
    if (amount <= 500) return 52.20;
    if (amount <= 1000) return 61.86;
    if (amount <= 2000) return 93.49;
    if (amount <= 3000) return 116.88;
    if (amount <= 4000) return 144.54;
    return amount * 0.036; // 4000+ TL: %3.60
  }

  static double _calculateCashPodFeeUps(double amount) {
    if (amount <= 500) return 47.40;
    if (amount <= 1000) return 58.20;
    if (amount <= 2000) return 81.26;
    if (amount <= 3000) return 108.74;
    if (amount <= 4000) return 131.28;
    if (amount <= 5000) return 147.00;
    return amount * 0.0474; // 5000+ TL: %4.74
  }

  // ==========================================
  // TABAN FİYAT HESAPLAMA MOTORU (kargo.txt)
  // ==========================================

  /// Belirli bir desi ve taşıma yönü için resmi kargo taban fiyatını hesaplar
  static double calculateBasePrice({
    required String companyCode,
    required double desi,
    bool isReceiverPays = false,
  }) {
    final code = normalizeCompanyCode(companyCode);
    final d = desi <= 0 ? 0 : desi.ceil();

    switch (code) {
      case codeHepsiJet:
        final table = isReceiverPays ? hepsijetReceiverPays : hepsijetStandard;
        final maxTier = isReceiverPays ? 30 : 40;
        if (d <= maxTier) {
          return table[d] ?? (isReceiverPays ? 525.00 : 441.00);
        }
        final maxPrice = table[maxTier]!;
        return maxPrice + (d - maxTier) * additionalDesiHepsiJet;

      case codePtt:
        if (d <= 30) {
          return pttStandard[d] ?? 613.00;
        }
        return pttStandard[30]! + (d - 30) * additionalDesiPtt;

      case codeSurat:
        final table = isReceiverPays ? suratReceiverPays : suratStandard;
        if (d <= 30) {
          return table[d] ?? (isReceiverPays ? 515.00 : 462.00);
        }
        final maxPrice = table[30]!;
        return maxPrice + (d - 30) * additionalDesiSurat;

      case codeKolayGelsin:
        if (d <= 30) {
          return kolayGelsinStandard[d] ?? 366.00;
        }
        return kolayGelsinStandard[30]! + (d - 30) * additionalDesiKolayGelsin;

      case codeYurtici:
        if (d <= 30) {
          return yurticiStandard[d] ?? 984.00;
        }
        return yurticiStandard[30]! + (d - 30) * additionalDesiYurtici;

      case codeUps:
        final table = isReceiverPays ? upsReceiverPays : upsStandard;
        if (d <= 70) {
          return table[d] ?? (isReceiverPays ? 825.00 : 836.00);
        }
        final maxPrice = table[70]!;
        return maxPrice + (d - 70) * additionalDesiUps;

      default:
        // Bilinmeyen / özel tarife fallback
        return 120.0 + (d > 2 ? (d - 2) * 15.0 : 0.0);
    }
  }

  // ==========================================
  // TOPLAM GÖNDERİ FİYATI HESAPLAMA MOTORU
  // ==========================================

  /// Taban fiyat + Kapıda Ödeme Kesintisi + Kontrollü Teslimat Ücreti hesaplar
  static double calculatePrice({
    required String companyCode,
    required double desi,
    bool isReceiverPays = false,
    bool isPod = false,
    double podAmount = 0.0,
    String podType = 'cash',
    bool isControlled = false,
  }) {
    final code = normalizeCompanyCode(companyCode);

    // Kontrollü Teslimat seçiliyse ve firma desteklemiyorsa 0.0 döner
    if (isControlled && !isControlledDeliverySupported(code)) {
      return 0.0;
    }

    // Kapıda Ödeme seçiliyse ve firma o ödeme türünü desteklemiyorsa 0.0 döner
    if (isPod && !isPodSupported(code, isCreditCard: podType == 'credit_card')) {
      return 0.0;
    }

    double total = calculateBasePrice(
      companyCode: code,
      desi: desi,
      isReceiverPays: isReceiverPays,
    );

    if (isPod) {
      total += calculatePodFee(
        code,
        podAmount > 0 ? podAmount : 250.0, // Tutar girilmemişse 0-500 TL taban dilimi
        isCreditCard: podType == 'credit_card',
      );
    }

    if (isControlled) {
      total += getControlledDeliveryFee(code);
    }

    return total;
  }

  // ==========================================
  // CREATE CARGO FALLBACK TEKLİFLERİ
  // ==========================================

  /// Backend teklif hesaplama servisi yanıt veremediğinde kargo.txt verileriyle
  /// tüm koşullara (POD, Kontrollü, Alıcı Öder, Kredi Kartı/Nakit) uygun teklif listesi üretir
  static List<CargoOffer> generateFallbackOffers({
    required double desi,
    bool isPod = false,
    double podAmount = 0.0,
    String podType = 'cash',
    bool isControlled = false,
    bool isReceiverPays = false,
  }) {
    final List<CargoOffer> list = [];

    // 1. Kontrollü Teslimat: Yalnızca PTT Kargo destekler
    if (isControlled) {
      final price = calculatePrice(
        companyCode: codePtt,
        desi: desi,
        isReceiverPays: isReceiverPays,
        isPod: isPod,
        podAmount: podAmount,
        podType: podType,
        isControlled: true,
      );
      if (price > 0) {
        list.add(CargoOffer(
          cargoCompany: CargoCompany(id: codePtt, title: 'PTT Kargo'),
          price: price,
        ));
      }
      return list;
    }

    // 2. Kredi Kartı Kapıda Ödeme: Yalnızca Sürat Kargo ve UPS Kargo destekler
    if (isPod && podType == 'credit_card') {
      final suratPrice = calculatePrice(
        companyCode: codeSurat,
        desi: desi,
        isReceiverPays: isReceiverPays,
        isPod: true,
        podAmount: podAmount,
        podType: 'credit_card',
      );
      if (suratPrice > 0) {
        list.add(CargoOffer(
          cargoCompany: CargoCompany(id: codeSurat, title: 'Sürat Kargo'),
          price: suratPrice,
        ));
      }

      final upsPrice = calculatePrice(
        companyCode: codeUps,
        desi: desi,
        isReceiverPays: isReceiverPays,
        isPod: true,
        podAmount: podAmount,
        podType: 'credit_card',
      );
      if (upsPrice > 0) {
        list.add(CargoOffer(
          cargoCompany: CargoCompany(id: codeUps, title: 'UPS Kargo'),
          price: upsPrice,
        ));
      }

      list.sort((a, b) => a.price.compareTo(b.price));
      return list;
    }

    // 3. Nakit Kapıda Ödeme: HepsiJET, Sürat Kargo, PTT Kargo, UPS Kargo destekler
    if (isPod && podType == 'cash') {
      final companies = [
        (codeHepsiJet, 'HepsiJET'),
        (codePtt, 'PTT Kargo'),
        (codeSurat, 'Sürat Kargo'),
        (codeUps, 'UPS Kargo'),
      ];

      for (final comp in companies) {
        final price = calculatePrice(
          companyCode: comp.$1,
          desi: desi,
          isReceiverPays: isReceiverPays,
          isPod: true,
          podAmount: podAmount,
          podType: 'cash',
        );
        if (price > 0) {
          list.add(CargoOffer(
            cargoCompany: CargoCompany(id: comp.$1, title: comp.$2),
            price: price,
          ));
        }
      }

      list.sort((a, b) => a.price.compareTo(b.price));
      return list;
    }

    // 4. Standart Gönderi (POD yok, Kontrollü yok): Tüm 6 firma
    final allCompanies = [
      (codeHepsiJet, 'HepsiJET'),
      (codePtt, 'PTT Kargo'),
      (codeSurat, 'Sürat Kargo'),
      (codeKolayGelsin, 'Kolay Gelsin'),
      (codeUps, 'UPS Kargo'),
      (codeYurtici, 'Yurtiçi Kargo'),
    ];

    for (final comp in allCompanies) {
      final price = calculatePrice(
        companyCode: comp.$1,
        desi: desi,
        isReceiverPays: isReceiverPays,
        isPod: false,
      );
      if (price > 0) {
        list.add(CargoOffer(
          cargoCompany: CargoCompany(id: comp.$1, title: comp.$2),
          price: price,
        ));
      }
    }

    list.sort((a, b) => a.price.compareTo(b.price));
    return list;
  }

  // ==========================================
  // RESMİ PRICING PLAN LİSTESİ (kargo.txt)
  // ==========================================

  /// Resmi kargo.txt verileriyle 6 anlaşmalı kargo firmasının PricingPlan nesnelerini üretir
  static List<PricingPlan> getOfficialPricingPlans() {
    return [
      PricingPlan(
        companyName: 'HepsiJET',
        code: codeHepsiJet,
        tariffName: 'HepsiJET Standart Tarife',
        logo: '',
        zeroTwoDesi: hepsijetStandard[0]!,
        fiveDesi: hepsijetStandard[5]!,
        tenDesi: hepsijetStandard[10]!,
        twentyDesi: hepsijetStandard[20]!,
        thirtyDesi: hepsijetStandard[30]!,
        additionalDesi: additionalDesiHepsiJet,
        returnRate: '%50',
        hasPod: true,
        hasPodCreditCard: false,
        hasControlledDelivery: false,
        hasDoorPickup: true,
        notes: 'Adresinizden ücretsiz kurye alımı sağlanır. Kapıda ödeme yalnızca nakit olarak yapılır.',
        desiPrices: Map.unmodifiable(hepsijetStandard),
      ),
      PricingPlan(
        companyName: 'PTT Kargo',
        code: codePtt,
        tariffName: 'PTT Kargo Standart Tarife',
        logo: '',
        zeroTwoDesi: pttStandard[0]!,
        fiveDesi: pttStandard[5]!,
        tenDesi: pttStandard[10]!,
        twentyDesi: pttStandard[20]!,
        thirtyDesi: pttStandard[30]!,
        additionalDesi: additionalDesiPtt,
        returnRate: '%50',
        hasPod: true,
        hasPodCreditCard: false,
        hasControlledDelivery: true,
        hasDoorPickup: false,
        notes: 'Kapıda nakit tahsilat ve kontrollü teslimat hizmeti verilmektedir. Kurye ile adresten alım hizmeti yoktur.',
        desiPrices: Map.unmodifiable(pttStandard),
      ),
      PricingPlan(
        companyName: 'Sürat Kargo',
        code: codeSurat,
        tariffName: 'Sürat Kargo Standart Tarife',
        logo: '',
        zeroTwoDesi: suratStandard[0]!,
        fiveDesi: suratStandard[5]!,
        tenDesi: suratStandard[10]!,
        twentyDesi: suratStandard[20]!,
        thirtyDesi: suratStandard[30]!,
        additionalDesi: additionalDesiSurat,
        returnRate: '%50',
        hasPod: true,
        hasPodCreditCard: true,
        hasControlledDelivery: false,
        hasDoorPickup: false,
        notes: 'Kapıda nakit ve tek çekim kredi kartı ile tahsilat desteklenmektedir. 30 desiye kadar standart fiyatlandırma uygulanır.',
        desiPrices: Map.unmodifiable(suratStandard),
      ),
      PricingPlan(
        companyName: 'Kolay Gelsin',
        code: codeKolayGelsin,
        tariffName: 'Kolay Gelsin Standart Tarife',
        logo: '',
        zeroTwoDesi: kolayGelsinStandard[0]!,
        fiveDesi: kolayGelsinStandard[5]!,
        tenDesi: kolayGelsinStandard[10]!,
        twentyDesi: kolayGelsinStandard[20]!,
        thirtyDesi: kolayGelsinStandard[30]!,
        additionalDesi: additionalDesiKolayGelsin,
        returnRate: '%100',
        hasPod: false,
        hasPodCreditCard: false,
        hasControlledDelivery: false,
        hasDoorPickup: true,
        notes: 'Adresinizden ücretsiz kurye alımı sağlanır. Kapıda ödeme seçeneği bulunmamaktadır.',
        desiPrices: Map.unmodifiable(kolayGelsinStandard),
      ),
      PricingPlan(
        companyName: 'UPS Kargo',
        code: codeUps,
        tariffName: 'UPS Kargo Standart Tarife',
        logo: '',
        zeroTwoDesi: upsStandard[0]!,
        fiveDesi: upsStandard[5]!,
        tenDesi: upsStandard[10]!,
        twentyDesi: upsStandard[20]!,
        thirtyDesi: upsStandard[30]!,
        additionalDesi: additionalDesiUps,
        returnRate: '%50',
        hasPod: true,
        hasPodCreditCard: true,
        hasControlledDelivery: true,
        hasDoorPickup: true,
        notes: 'Adresinizden ücretsiz kurye alımı sağlanır. Kapıda nakit ve kredi kartı ile tahsilat yapılabilir.',
        desiPrices: Map.unmodifiable(upsStandard),
      ),
      PricingPlan(
        companyName: 'Yurtiçi Kargo',
        code: codeYurtici,
        tariffName: 'Yurtiçi Kargo Standart Tarife',
        logo: '',
        zeroTwoDesi: yurticiStandard[0]!,
        fiveDesi: yurticiStandard[5]!,
        tenDesi: yurticiStandard[10]!,
        twentyDesi: yurticiStandard[20]!,
        thirtyDesi: yurticiStandard[30]!,
        additionalDesi: additionalDesiYurtici,
        returnRate: '%50',
        hasPod: false,
        hasPodCreditCard: false,
        hasControlledDelivery: false,
        hasDoorPickup: false,
        notes: '30 desiye kadar standart fiyatlandırma uygulanır. Kurye ile adresten alım hizmeti yoktur.',
        desiPrices: Map.unmodifiable(yurticiStandard),
      ),
    ];
  }
}
