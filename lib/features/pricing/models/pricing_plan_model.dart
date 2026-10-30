import '../../cargo/widgets/cargo_company_logo.dart';
import 'cargo_tariff_engine.dart';

class PricingTier {
  final String desiRange;
  final double price;

  PricingTier({required this.desiRange, required this.price});
}

class PricingPlan {
  final String companyName;
  final String code;
  final String tariffName;
  final String logo;
  final double zeroTwoDesi;
  final double fiveDesi;
  final double tenDesi;
  final double twentyDesi;
  final double thirtyDesi;
  final double additionalDesi;
  final String returnRate;
  final bool hasPod;
  final bool hasPodCreditCard;
  final bool hasControlledDelivery;
  final bool hasDoorPickup;
  final String notes;
  final Map<int, double> desiPrices;

  PricingPlan({
    required this.companyName,
    required this.code,
    required this.tariffName,
    required this.logo,
    required this.zeroTwoDesi,
    required this.fiveDesi,
    required this.tenDesi,
    required this.twentyDesi,
    required this.thirtyDesi,
    required this.additionalDesi,
    required this.returnRate,
    required this.hasPod,
    required this.hasPodCreditCard,
    required this.hasControlledDelivery,
    required this.hasDoorPickup,
    required this.notes,
    this.desiPrices = const {},
  });

  bool get isPtt =>
      CargoCompanyType.fromString(code) == CargoCompanyType.ptt ||
      CargoCompanyType.fromString(companyName) == CargoCompanyType.ptt ||
      code.toLowerCase().contains('ptt') ||
      companyName.toLowerCase().contains('ptt');

  /// Belirli bir desi icin fiyat hesaplar.
  /// API'den gelen desiPrices haritasindaki kademeler uzerinden lineer interpolasyon
  /// veya en ust kademenin uzerindeyse ek desi fiyati ile hesaplama yapar.
  /// 0 Desi tam desteklenir (1'e yuvarlanmaz).
  double calculatePrice(
    num desi, {
    bool isPod = false,
    double podAmount = 0.0,
    String podType = 'cash',
    bool isControlled = false,
    bool isReceiverPays = false,
  }) {
    final normCode = CargoTariffEngine.normalizeCompanyCode(code);
    final isOfficialCode = normCode == CargoTariffEngine.codePtt ||
        normCode == CargoTariffEngine.codeHepsiJet ||
        normCode == CargoTariffEngine.codeSurat ||
        normCode == CargoTariffEngine.codeKolayGelsin ||
        normCode == CargoTariffEngine.codeYurtici ||
        normCode == CargoTariffEngine.codeUps;

    // 1. Kontrollü Teslimat Uygunluk Kontrolü
    if (isControlled) {
      final supported = hasControlledDelivery || isPtt || CargoTariffEngine.isControlledDeliverySupported(normCode);
      if (!supported) return 0.0;
      if (isOfficialCode && !CargoTariffEngine.isControlledDeliverySupported(normCode)) return 0.0;
    }

    // 2. Kapıda Ödeme (POD) Uygunluk Kontrolü
    if (isPod) {
      final isCc = podType == 'credit_card';
      if (isCc) {
        final supported = hasPodCreditCard || CargoTariffEngine.isPodSupported(normCode, isCreditCard: true);
        if (!supported) return 0.0;
        if (isOfficialCode && !CargoTariffEngine.isPodSupported(normCode, isCreditCard: true)) return 0.0;
      } else {
        final supported = hasPod || CargoTariffEngine.isPodSupported(normCode, isCreditCard: false);
        if (!supported) return 0.0;
        if (isOfficialCode && !CargoTariffEngine.isPodSupported(normCode, isCreditCard: false)) return 0.0;
      }
    }

    final d = desi <= 0 ? 0 : (desi is int ? desi : desi.ceil());

    double basePrice = 0.0;

    // Alıcı ödemeli resmi tarife kontrolü (kargo.txt: HepsiJET, Sürat ve UPS resmi alıcı ödemeli kademelerine sahiptir)
    if (isReceiverPays && isOfficialCode) {
      basePrice = CargoTariffEngine.calculateBasePrice(
        companyCode: normCode,
        desi: d.toDouble(),
        isReceiverPays: true,
      );
    } else {
      // 0-2 Desi kurali: Turkiye kargo tasimaciliginda 0-2 Desi taban kademedir.
      if (d <= 2) {
        if (desiPrices.containsKey(d)) {
          basePrice = desiPrices[d]!;
        } else if (d == 0) {
          if (desiPrices.containsKey(0)) {
            basePrice = desiPrices[0]!;
          } else if (desiPrices.containsKey(1)) {
            basePrice = desiPrices[1]!;
          } else if (desiPrices.containsKey(2)) {
            basePrice = desiPrices[2]!;
          } else if (zeroTwoDesi > 0) {
            basePrice = zeroTwoDesi;
          }
        } else if (desiPrices.containsKey(2)) {
          basePrice = desiPrices[2]!;
        } else if (desiPrices.containsKey(0)) {
          basePrice = desiPrices[0]!;
        } else if (desiPrices.containsKey(1)) {
          basePrice = desiPrices[1]!;
        } else if (zeroTwoDesi > 0) {
          basePrice = zeroTwoDesi;
        }
      }

      if (basePrice == 0.0 && desiPrices.isNotEmpty) {
        if (desiPrices.containsKey(d)) {
          basePrice = desiPrices[d]!;
        } else {
          final sortedThresholds = desiPrices.keys.toList()..sort();
          final minThreshold = sortedThresholds.first;
          final maxThreshold = sortedThresholds.last;

          if (d <= minThreshold) {
            basePrice = desiPrices[minThreshold]!;
          } else if (d >= maxThreshold) {
            final maxPrice = desiPrices[maxThreshold]!;
            if (additionalDesi > 0) {
              basePrice = maxPrice + (d - maxThreshold) * additionalDesi;
            } else {
              basePrice = maxPrice;
            }
          } else {
            // Iki kademe arasinda lineer interpolasyon
            int lower = minThreshold;
            int upper = maxThreshold;
            for (final t in sortedThresholds) {
              if (t < d && t > lower) lower = t;
              if (t > d && t < upper) upper = t;
            }

            final lowerPrice = desiPrices[lower]!;
            final upperPrice = desiPrices[upper]!;
            if (upper == lower) {
              basePrice = lowerPrice;
            } else {
              final effectiveLower = (lower == 0) ? 2 : lower;
              if (d <= effectiveLower) {
                basePrice = lowerPrice;
              } else {
                final ratio = (d - effectiveLower) / (upper - effectiveLower);
                basePrice = lowerPrice + ratio * (upperPrice - lowerPrice);
              }
            }
          }
        }
      }

      if (basePrice == 0.0) {
        // Geriye donuk uyumluluk veya desiPrices haritasi bos ise:
        // Orijinal tarife motorunu kontrol et
        if (isOfficialCode &&
            !code.toLowerCase().contains('ozel') &&
            !code.toLowerCase().contains('bozuk')) {
          basePrice = CargoTariffEngine.calculateBasePrice(
            companyCode: code,
            desi: d.toDouble(),
            isReceiverPays: isReceiverPays,
          );
        } else {
          if (d <= 2) {
            basePrice = zeroTwoDesi;
          } else if (d <= 5) {
            if (fiveDesi <= 0) {
              basePrice = zeroTwoDesi;
            } else {
              final ratio = (d - 2) / (5 - 2);
              basePrice = zeroTwoDesi + ratio * (fiveDesi - zeroTwoDesi);
            }
          } else if (d <= 10) {
            final base = fiveDesi > 0 ? fiveDesi : zeroTwoDesi;
            if (tenDesi <= 0) {
              basePrice = base;
            } else {
              final ratio = (d - 5) / (10 - 5);
              basePrice = base + ratio * (tenDesi - base);
            }
          } else if (d <= 20) {
            final base = tenDesi > 0 ? tenDesi : (fiveDesi > 0 ? fiveDesi : zeroTwoDesi);
            if (twentyDesi <= 0) {
              basePrice = base;
            } else {
              final ratio = (d - 10) / (20 - 10);
              basePrice = base + ratio * (twentyDesi - base);
            }
          } else if (d <= 30) {
            final base = twentyDesi > 0
                ? twentyDesi
                : (tenDesi > 0 ? tenDesi : (fiveDesi > 0 ? fiveDesi : zeroTwoDesi));
            if (thirtyDesi <= 0) {
              basePrice = base;
            } else {
              final ratio = (d - 20) / (30 - 20);
              basePrice = base + ratio * (thirtyDesi - base);
            }
          } else {
            final base = thirtyDesi > 0
                ? thirtyDesi
                : (twentyDesi > 0
                    ? twentyDesi
                    : (tenDesi > 0 ? tenDesi : (fiveDesi > 0 ? fiveDesi : zeroTwoDesi)));
            if (additionalDesi > 0) {
              basePrice = base + (d - 30) * additionalDesi;
            } else {
              basePrice = base;
            }
          }
        }
      }
    }

    // Ek Hizmet Ücretleri (Kapıda Ödeme & Kontrollü Teslimat)
    if (basePrice > 0) {
      if (isControlled) {
        final fee = CargoTariffEngine.getControlledDeliveryFee(normCode);
        basePrice += (fee > 0 ? fee : (hasControlledDelivery || isPtt ? 49.99 : 0.0));
      }
      if (isPod) {
        final fee = CargoTariffEngine.calculatePodFee(
          normCode,
          podAmount > 0 ? podAmount : 250.0,
          isCreditCard: podType == 'credit_card',
        );
        basePrice += (fee > 0 ? fee : (hasPod ? 15.0 : 0.0));
      }
    }

    return basePrice;
  }

  factory PricingPlan.fromBackend(Map<String, dynamic> item, [Map<String, dynamic>? detail]) {
    final company = item['cargo_company'] is Map<String, dynamic>
        ? item['cargo_company'] as Map<String, dynamic>
        : <String, dynamic>{};

    final companyName = company['title']?.toString() ??
        company['name']?.toString() ??
        item['title']?.toString() ??
        item['name']?.toString() ??
        '';
    final code = item['cargo_company_id']?.toString().isNotEmpty == true
        ? item['cargo_company_id'].toString()
        : (company['code']?.toString() ?? company['id']?.toString() ?? '');
    final tariffName = item['name']?.toString() ?? '';
    final logo = company['logo']?.toString() ?? '';

    final prices = (detail?['prices'] as List<dynamic>?) ??
        (item['prices'] as List<dynamic>?) ??
        [];
    final fees = (detail?['fees'] as List<dynamic>?) ??
        (item['fees'] as List<dynamic>?) ??
        [];

    final Map<int, double> desiPrices = {};
    for (final it in prices) {
      if (it is Map<String, dynamic>) {
        final threshold = it['desi_threshold'] is num
            ? (it['desi_threshold'] as num).toInt()
            : int.tryParse(it['desi_threshold']?.toString() ?? '');
        final amt = it['amount'] is num
            ? (it['amount'] as num).toDouble()
            : double.tryParse(it['amount']?.toString() ?? '') ?? 0.0;
        if (threshold != null && amt > 0) {
          desiPrices[threshold] = amt * 1.20; // %20 KDV dahil
        }
      }
    }

    double getPrice(int desi) {
      if (desiPrices.containsKey(desi)) {
        return desiPrices[desi]!;
      }
      if (desi == 0) {
        if (desiPrices.containsKey(2)) return desiPrices[2]!;
        if (desiPrices.containsKey(1)) return desiPrices[1]!;
        if (desiPrices.containsKey(0)) return desiPrices[0]!;
      }
      return 0.0;
    }

    double additionalDesi = 0.0;
    String returnRate = '%50';
    for (final f in fees) {
      if (f is Map<String, dynamic>) {
        final feeType = f['type']?.toString();
        if (feeType == '201') {
          final rawAdd = (f['value'] is num)
              ? (f['value'] as num).toDouble()
              : double.tryParse(f['value']?.toString() ?? '') ?? 0.0;
          additionalDesi = rawAdd * 1.20; // %20 KDV dahil
        } else if (feeType == '202') {
          final valStr = f['value']?.toString() ?? '50';
          returnRate = valStr.startsWith('%') ? valStr : '%$valStr';
        }
      }
    }

    if (additionalDesi == 0.0) {
      final rawAddFallback = detail?['additional_desi_price'] ?? item['additional_desi_price'];
      if (rawAddFallback != null) {
        final parsed = (rawAddFallback is num)
            ? rawAddFallback.toDouble()
            : double.tryParse(rawAddFallback.toString()) ?? 0.0;
        if (parsed > 0) additionalDesi = parsed * 1.20;
      }
    }

    bool parseBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is num) return val == 1;
      final str = val.toString().trim().toLowerCase();
      return str == 'true' || str == '1';
    }

    final notes = company['customer_note']?.toString() ?? '';
    final bool hasDoorPickup = notes.toLowerCase().contains('ücretsiz kurye') ||
        notes.toLowerCase().contains('kapıdan') ||
        parseBool(company['can_receive_direction']);

    final bool isPtt = CargoCompanyType.fromString(code) == CargoCompanyType.ptt ||
        CargoCompanyType.fromString(companyName) == CargoCompanyType.ptt ||
        code.toLowerCase().contains('ptt') ||
        companyName.toLowerCase().contains('ptt');
    final bool hasControlledDelivery = parseBool(company['can_controlled_delivery']) || isPtt;

    return PricingPlan(
      companyName: companyName,
      code: code,
      tariffName: tariffName,
      logo: logo,
      zeroTwoDesi: getPrice(0) > 0 ? getPrice(0) : (desiPrices[2] ?? desiPrices[1] ?? desiPrices[0] ?? 0.0),
      fiveDesi: getPrice(5) > 0 ? getPrice(5) : (desiPrices[5] ?? 0.0),
      tenDesi: getPrice(10) > 0 ? getPrice(10) : (desiPrices[10] ?? 0.0),
      twentyDesi: getPrice(20) > 0 ? getPrice(20) : (desiPrices[20] ?? 0.0),
      thirtyDesi: getPrice(30) > 0 ? getPrice(30) : (desiPrices[30] ?? 0.0),
      additionalDesi: additionalDesi,
      returnRate: returnRate,
      hasPod: parseBool(company['can_pod']),
      hasPodCreditCard: parseBool(company['can_pod_credit_card']),
      hasControlledDelivery: hasControlledDelivery,
      hasDoorPickup: hasDoorPickup,
      notes: notes.isNotEmpty ? notes : 'Standart gönderi ve teslimat kuralları geçerlidir.',
      desiPrices: desiPrices,
    );
  }
}
