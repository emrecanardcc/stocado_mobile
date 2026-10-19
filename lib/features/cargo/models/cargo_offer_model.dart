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
      id: json['id'] ?? '',
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
  final String? localId;
  final String? foreignId;
  final PackageData package;
  final bool payOnDelivery;
  final double? payOnDeliveryAmount;
  final String? payOnDeliveryType; // cash, credit_card
  final bool pastPayOnDelivery;
  final bool podReceiverPays;
  final bool controlledDelivery;
  final int status;
  final String direction; // send, receive
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
    this.controlledDelivery = false,
    this.status = 1,
    this.direction = 'send',
    this.printBarcode = false,
  });

  Map<String, dynamic> toJson() => {
        'account_id': accountId,
        if (localId != null && localId!.isNotEmpty) 'local_id': localId,
        if (foreignId != null && foreignId!.isNotEmpty) 'foreign_id': foreignId,
        'package': package.toJson(),
        'pay_on_delivery': payOnDelivery,
        if (payOnDelivery && payOnDeliveryAmount != null) 'pay_on_delivery_amount': payOnDeliveryAmount,
        if (payOnDelivery) 'pay_on_delivery_type': payOnDeliveryType == 'credit_card' ? 2 : 1,
        'past_pay_on_delivery': pastPayOnDelivery,
        'pod_receiver_pays': podReceiverPays,
        'receiver_pays': false,
        'controlled_delivery': controlledDelivery,
        'status': status,
        'direction': (direction == 'receive' || direction == '2') ? 2 : 1,
        'print_barcode': printBarcode,
      };
}
