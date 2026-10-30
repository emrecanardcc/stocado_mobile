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

  CargoOffer({
    required this.cargoCompany,
    required this.price,
  });

  factory CargoOffer.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['total'] ?? json['price'];
    return CargoOffer(
      cargoCompany: json['cargo_company'] is Map<String, dynamic>
          ? CargoCompany.fromJson(json['cargo_company'])
          : CargoCompany(id: 'bilinmeyen', title: 'Kargo Firması'),
      price: (rawPrice is num)
          ? rawPrice.toDouble()
          : double.tryParse(rawPrice?.toString() ?? '') ?? 0.0,
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
  final dynamic payOnDeliveryType; // 'cash', 'credit_card', or int
  final bool pastPayOnDelivery;
  final bool podReceiverPays;
  final bool receiverPays;
  final bool controlledDelivery;
  final int status;
  final dynamic direction; // 'send', 'receive', or int
  final bool printBarcode;

  CargoCalculateRequest({
    required this.accountId,
    this.localId,
    this.foreignId,
    required this.package,
    this.payOnDelivery = false,
    this.payOnDeliveryAmount,
    this.payOnDeliveryType,
    this.pastPayOnDelivery = false,
    this.podReceiverPays = false,
    this.receiverPays = false,
    this.controlledDelivery = false,
    this.status = 1,
    this.direction = 'send',
    this.printBarcode = false,
  });

  Map<String, dynamic> toJson({bool useIntegerEnums = false}) {
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
      if (lId != null && (lId is! String || lId.isNotEmpty)) 'local_id': lId,
      if (fId != null && (fId is! String || fId.isNotEmpty)) 'foreign_id': fId,
      'package': package.toJson(),
      'pay_on_delivery': payOnDelivery,
      if (payOnDelivery && payOnDeliveryAmount != null) 'pay_on_delivery_amount': payOnDeliveryAmount,
      if (payOnDelivery)
        'pay_on_delivery_type': useIntegerEnums
            ? (isCreditCard ? 2 : 1)
            : (isCreditCard ? 'credit_card' : 'cash'),
      'past_pay_on_delivery': pastPayOnDelivery,
      'pod_receiver_pays': receiverPays || podReceiverPays,
      'receiver_pays': receiverPays,
      'controlled_delivery': controlledDelivery,
      'status': status,
      'direction': useIntegerEnums ? (isReceive ? 2 : 1) : (isReceive ? 'receive' : 'send'),
      'print_barcode': printBarcode,
    };
  }
}
