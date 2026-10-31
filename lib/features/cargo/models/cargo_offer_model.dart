class CargoCompany {
  final dynamic id;
  final String title;
  final String? logo;

  CargoCompany({
    required this.id,
    required this.title,
    this.logo,
  });

  factory CargoCompany.fromJson(Map<String, dynamic> json) {
    return CargoCompany(
      id: json['id'] ?? json['code'] ?? json['company_id'] ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      logo: json['logo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'logo': logo,
      };
}

class CargoOffer {
  final CargoCompany cargoCompany;
  final double price;
  final double returnFee;
  final double podFee;
  final int? estimatedDeliveryDays;
  final List<String> warnings;
  final List<String> errors;

  CargoOffer({
    required this.cargoCompany,
    required this.price,
    this.returnFee = 0.0,
    this.podFee = 0.0,
    this.estimatedDeliveryDays,
    this.warnings = const [],
    this.errors = const [],
  });

  factory CargoOffer.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['total'] ?? json['price'] ?? json['total_price'] ?? json['amount'];
    final companyMap = json['cargo_company'] is Map<String, dynamic>
        ? json['cargo_company'] as Map<String, dynamic>
        : (json['company'] is Map<String, dynamic> ? json['company'] as Map<String, dynamic> : null);

    // Ücret kırılımları (İade & Kapıda Ödeme)
    double retFee = 0.0;
    double pFee = 0.0;
    if (json['fees'] is Map<String, dynamic>) {
      final fees = json['fees'] as Map<String, dynamic>;
      final rawRet = fees['return_fee'];
      if (rawRet is num) retFee = rawRet.toDouble();
      final rawPod = fees['pay_on_delivery'];
      if (rawPod is num) pFee = rawPod.toDouble();
    }

    // Tahmini teslimat süresi (gün)
    int? deliveryDays;
    final rawDays = json['estimated_delivery_days'];
    if (rawDays is num) deliveryDays = rawDays.toInt();

    // Uyarı ve hata mesajları (Meta)
    final List<String> warns = [];
    final List<String> errs = [];
    if (json['meta'] is List) {
      for (final m in json['meta']) {
        if (m is Map) {
          final msg = m['message']?.toString();
          final type = m['type']?.toString();
          if (msg != null && msg.isNotEmpty) {
            if (type == 'error') {
              errs.add(msg);
            } else {
              warns.add(msg);
            }
          }
        }
      }
    }

    return CargoOffer(
      cargoCompany: companyMap != null
          ? CargoCompany.fromJson(companyMap)
          : CargoCompany(
              id: json['cargo_company_id'] ?? json['company_id'] ?? json['id'] ?? 'bilinmeyen',
              title: json['cargo_company_title'] ?? json['company_title'] ?? json['title'] ?? 'Kargo Firması',
            ),
      price: (rawPrice is num)
          ? rawPrice.toDouble()
          : double.tryParse(rawPrice?.toString() ?? '') ?? 0.0,
      returnFee: retFee,
      podFee: pFee,
      estimatedDeliveryDays: deliveryDays,
      warnings: warns,
      errors: errs,
    );
  }
}

class PackageData {
  final double desi;
  final double? length;
  final double? width;
  final double? height;
  final double? weight;

  PackageData({
    required this.desi,
    this.length,
    this.width,
    this.height,
    this.weight,
  });

  Map<String, dynamic> toJson() => {
        'desi': double.parse(desi.toStringAsFixed(2)),
        if (length != null) 'length': double.parse(length!.toStringAsFixed(2)),
        if (width != null) 'width': double.parse(width!.toStringAsFixed(2)),
        if (height != null) 'height': double.parse(height!.toStringAsFixed(2)),
        if (weight != null) 'weight': double.parse(weight!.toStringAsFixed(2)),
      };
}

class CargoCalculateRequest {
  final dynamic accountId;
  final dynamic localId;
  final dynamic foreignId;
  final PackageData package;
  final bool payOnDelivery;
  final double? payOnDeliveryAmount;
  final dynamic payOnDeliveryType; // 1: cash, 2: credit_card, or 'cash', 'credit_card'
  final bool pastPayOnDelivery;
  final bool podReceiverPays;
  final bool receiverPays;
  final bool controlledDelivery;
  final int status;
  final dynamic direction; // 1: send, 2: receive, or 'send', 'receive'
  final bool printBarcode;
  final String? pickUpDate;

  CargoCalculateRequest({
    required this.accountId,
    this.localId,
    this.foreignId,
    required this.package,
    this.payOnDelivery = false,
    this.payOnDeliveryAmount,
    this.payOnDeliveryType = 1,
    this.pastPayOnDelivery = false,
    this.podReceiverPays = false,
    this.receiverPays = false,
    this.controlledDelivery = false,
    this.status = 1,
    this.direction = 1,
    this.printBarcode = false,
    this.pickUpDate,
  });

  Map<String, dynamic> toJson({bool useIntegerEnums = true}) {
    final isReceive = direction == 'receive' || direction == '2' || direction == 2;
    final isCreditCard = payOnDeliveryType == 'credit_card' || payOnDeliveryType == '2' || payOnDeliveryType == 2;

    dynamic accId = accountId;
    if (accId is String) {
      final parsed = int.tryParse(accId);
      if (parsed != null) accId = parsed;
    }

    dynamic lId = localId;
    if (lId is String && lId.isNotEmpty) {
      final parsed = int.tryParse(lId);
      if (parsed != null) lId = parsed;
    }

    dynamic fId = foreignId;
    if (fId is String && fId.isNotEmpty) {
      final parsed = int.tryParse(fId);
      if (parsed != null) fId = parsed;
    }

    return {
      'account_id': accId,
      'cargo_company_id': '',
      if (lId != null && (lId is! String || lId.isNotEmpty)) 'local_id': lId,
      if (fId != null && (fId is! String || fId.isNotEmpty)) 'foreign_id': fId,
      'package': package.toJson(),
      'pay_on_delivery': payOnDelivery,
      'pay_on_delivery_amount': payOnDelivery ? (payOnDeliveryAmount ?? 0) : 0,
      'pay_on_delivery_type': useIntegerEnums
          ? (isCreditCard ? 2 : 1)
          : (isCreditCard ? 'credit_card' : 'cash'),
      'past_pay_on_delivery': pastPayOnDelivery,
      'pod_receiver_pays': podReceiverPays,
      'receiver_pays': receiverPays,
      'controlled_delivery': controlledDelivery,
      'status': status,
      'direction': useIntegerEnums ? (isReceive ? 2 : 1) : (isReceive ? 'receive' : 'send'),
      'print_barcode': printBarcode,
      if (pickUpDate != null && pickUpDate!.isNotEmpty) 'pick_up_date': pickUpDate,
    };
  }
}
