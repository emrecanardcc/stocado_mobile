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
  });

  factory PricingPlan.fromBackend(Map<String, dynamic> item, [Map<String, dynamic>? detail]) {
    final company = item['cargo_company'] is Map<String, dynamic>
        ? item['cargo_company'] as Map<String, dynamic>
        : <String, dynamic>{};

    final companyName = company['title']?.toString() ?? item['name']?.toString() ?? '';
    final code = item['cargo_company_id']?.toString() ?? '';
    final tariffName = item['name']?.toString() ?? '';
    final logo = company['logo']?.toString() ?? '';

    final prices = (detail?['prices'] as List<dynamic>?) ?? [];
    final fees = (detail?['fees'] as List<dynamic>?) ?? [];

    double getPrice(int desi) {
      dynamic p;
      for (final it in prices) {
        if (it is Map<String, dynamic>) {
          final threshold = it['desi_threshold'];
          if ((threshold is num && threshold.toInt() == desi) ||
              threshold?.toString() == desi.toString()) {
            p = it;
            break;
          }
        }
      }

      // 0-2 Desi için esnek eşleşme (bazı tarifelerde threshold 1 veya 2 tanımlıdır)
      if (p == null && desi == 0) {
        for (final it in prices) {
          if (it is Map<String, dynamic>) {
            final threshold = it['desi_threshold'];
            if ((threshold is num && threshold.toInt() <= 2) ||
                threshold?.toString() == '1' ||
                threshold?.toString() == '2') {
              p = it;
              break;
            }
          }
        }
      }

      if (p != null && p is Map<String, dynamic>) {
        final amt = (p['amount'] is num)
            ? (p['amount'] as num).toDouble()
            : double.tryParse(p['amount']?.toString() ?? '') ?? 0.0;
        return amt * 1.20; // %20 KDV dahil
      }
      return 0.0;
    }

    double additionalDesi = 0.0;
    String returnRate = '%50';
    for (final f in fees) {
      if (f is Map<String, dynamic>) {
        if (f['type'] == 201) {
          final rawAdd = (f['value'] is num)
              ? (f['value'] as num).toDouble()
              : double.tryParse(f['value']?.toString() ?? '') ?? 0.0;
          additionalDesi = rawAdd * 1.20; // %20 KDV dahil
        } else if (f['type'] == 202) {
          returnRate = '%${f['value']}';
        }
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

    final bool isPtt = code.toLowerCase().contains('ptt') || companyName.toLowerCase().contains('ptt');
    final bool hasControlledDelivery = parseBool(company['can_controlled_delivery']) || isPtt;

    return PricingPlan(
      companyName: companyName,
      code: code,
      tariffName: tariffName,
      logo: logo,
      zeroTwoDesi: getPrice(0),
      fiveDesi: getPrice(5),
      tenDesi: getPrice(10),
      twentyDesi: getPrice(20),
      thirtyDesi: getPrice(30),
      additionalDesi: additionalDesi,
      returnRate: returnRate,
      hasPod: parseBool(company['can_pod']),
      hasPodCreditCard: parseBool(company['can_pod_credit_card']),
      hasControlledDelivery: hasControlledDelivery,
      hasDoorPickup: hasDoorPickup,
      notes: notes.isNotEmpty ? notes : 'Standart gönderi ve teslimat kuralları geçerlidir.',
    );
  }
}
