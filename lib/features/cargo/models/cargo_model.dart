import '../../../core/utils/app_formatters.dart';
import 'address_model.dart';
import 'cargo_offer_model.dart';

class CargoTransaction {
  final int? type;
  final String description;
  final String? location;
  final DateTime? createdAt;

  CargoTransaction({
    this.type,
    required this.description,
    this.location,
    this.createdAt,
  });

  factory CargoTransaction.fromJson(Map<String, dynamic> json) {
    return CargoTransaction(
      type: json['type'] is int ? json['type'] : int.tryParse(json['type']?.toString() ?? ''),
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString(),
      createdAt: AppFormatters.parseUtcDateTime(json['created_at']),
    );
  }
}

class CargoParty {
  final dynamic id;
  final String name;
  final String phone;
  final String? title;
  final LocationRef? city;
  final LocationRef? district;

  CargoParty({
    required this.id,
    required this.name,
    required this.phone,
    this.title,
    this.city,
    this.district,
  });

  factory CargoParty.fromJson(Map<String, dynamic> json) {
    LocationRef? cityRef;
    if (json['city'] is Map<String, dynamic>) {
      cityRef = LocationRef.fromJson(json['city']);
    } else if (json['city.name'] != null || json['city_name'] != null || json['city_id'] != null) {
      cityRef = LocationRef(
        id: json['city_id']?.toString(),
        name: json['city.name']?.toString() ?? json['city_name']?.toString() ?? '',
      );
    }

    LocationRef? distRef;
    if (json['district'] is Map<String, dynamic>) {
      distRef = LocationRef.fromJson(json['district']);
    } else if (json['district.name'] != null || json['district_name'] != null || json['district_id'] != null) {
      distRef = LocationRef(
        id: json['district_id']?.toString(),
        name: json['district.name']?.toString() ?? json['district_name']?.toString() ?? '',
      );
    }

    return CargoParty(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      title: json['title']?.toString() ?? json['details']?.toString(),
      city: cityRef,
      district: distRef,
    );
  }

  factory CargoParty.fromAddress(AddressModel address) {
    return CargoParty(
      id: address.id,
      name: address.name,
      phone: address.phone,
      title: address.title,
      city: address.cityId != null
          ? LocationRef(id: address.cityId, name: address.city?.name ?? '')
          : null,
      district: address.districtId != null
          ? LocationRef(id: address.districtId, name: address.district?.name ?? '')
          : null,
    );
  }
}

class CargoModel {
  final dynamic id;
  final String processNumber;
  final String outTrackingCode;
  final String? outTrackingLink;
  final String? orderNumber;
  final int status; // 0 = taslak, 1 = aktif, 2 = yolda, 3 = iptal/kapandı, 4 = iptal
  final bool payOnDelivery;
  final double? payOnDeliveryAmount;
  final double? payOnDeliveryCost;
  final String? podTransactionId;
  final dynamic collectionPeriod;
  final int? payOnDeliveryType;
  final int? payOnDeliveryStatus;
  final DateTime? payOnDeliveryOffsetDate;
  final double? totalPrice;
  final double? userDesi;
  final double? validDesi;
  final String? senderId;
  final String? receiverId;
  final String? cargoCompanyId;
  final String? description;
  final DateTime? createdAt;
  final DateTime? deliveredAt;
  final CargoParty? receiver;
  final CargoParty? sender;
  final CargoCompany? cargoCompany;
  final CargoTransaction? latestTransaction;
  final int? latestTransactionType;
  final List<CargoTransaction> transactions;

  CargoModel({
    required this.id,
    required this.processNumber,
    required this.outTrackingCode,
    this.outTrackingLink,
    this.orderNumber,
    required this.status,
    required this.payOnDelivery,
    this.payOnDeliveryAmount,
    this.payOnDeliveryCost,
    this.podTransactionId,
    this.collectionPeriod,
    this.payOnDeliveryType,
    this.payOnDeliveryStatus,
    this.payOnDeliveryOffsetDate,
    this.totalPrice,
    this.userDesi,
    this.validDesi,
    this.senderId,
    this.receiverId,
    this.cargoCompanyId,
    this.description,
    this.createdAt,
    this.deliveredAt,
    this.receiver,
    this.sender,
    this.cargoCompany,
    this.latestTransaction,
    this.latestTransactionType,
    this.transactions = const [],
  });

  bool get isDraft => status == 0;

  bool get hasCarrierBarcode => outTrackingCode.trim().isNotEmpty;

  int? get effectiveTransactionType => latestTransaction?.type ?? latestTransactionType;

  double get effectiveDesi =>
      (validDesi != null && validDesi! > 0) ? validDesi! : (userDesi ?? 1.0);

  double get payOnDeliveryNetAmount =>
      (payOnDeliveryAmount ?? 0) - (payOnDeliveryCost ?? 0);

  /// Web portalindeki "Son Hareket" başlığı
  String get latestActionTitle {
    final type = effectiveTransactionType;
    if (type != null) {
      switch (type) {
        case 0:
          return 'Entegrasyon Hatası';
        case 1:
          return 'Gönderime Hazır';
        case 2:
          return 'Çıkış Şubesi';
        case 3:
          return 'Transferde';
        case 4:
          return 'Teslimat Şubesi';
        case 5:
          return 'Dağıtımda';
        case 6:
          return 'Teslim Edildi';
        case 7:
          if (latestTransaction?.description.toLowerCase().contains('posta') ?? false) {
            return 'Posta Kağıdı Bırakıldı';
          }
          return 'Beklemede';
        case 8:
          return 'Posta Kağıdı Bırakıldı';
        case 9:
          return 'Şubeye Transfer Edildi';
        case 10:
          return 'İadede';
        case 11:
          return 'Göndericiye İade Edildi';
        case 12:
          return 'Gönderici İptal';
        case 13:
          return 'Yönetici İptal';
      }
    }
    final desc = latestTransaction?.description;
    if (desc != null && desc.trim().isNotEmpty) {
      return desc.trim();
    }
    return statusText;
  }

  /// Kargoları oluşturulma tarihine veya ID önceliğine göre sıralar.
  /// 'desc' (varsayılan): En yeni kargo (kullanıcının güncel tarih/saatine en yakın olan) en üstte (index 0).
  /// 'asc': En eski kargo en üstte.
  static int compareCargos(CargoModel a, CargoModel b, {String sortDirection = 'desc'}) {
    final isAsc = sortDirection == 'asc';
    if (a.createdAt != null && b.createdAt != null) {
      final cmp = a.createdAt!.compareTo(b.createdAt!);
      if (cmp != 0) {
        return isAsc ? cmp : -cmp;
      }
    } else if (a.createdAt == null && b.createdAt != null) {
      return 1;
    } else if (a.createdAt != null && b.createdAt == null) {
      return -1;
    }

    // Tie-breaker: ID bazlı sıralama (sayısal veya alfabetik ULID/UUID uyumlu)
    final aIdStr = a.id.toString();
    final bIdStr = b.id.toString();
    final aNum = int.tryParse(aIdStr);
    final bNum = int.tryParse(bIdStr);
    if (aNum != null && bNum != null) {
      final cmp = aNum.compareTo(bNum);
      return isAsc ? cmp : -cmp;
    }
    final cmp = aIdStr.compareTo(bIdStr);
    return isAsc ? cmp : -cmp;
  }

  /// Resmi kargo şirketi takip sayfasına giden doğrudan URL bağlantısı
  String? get trackingUrl {
    if (outTrackingLink != null && outTrackingLink!.isNotEmpty) {
      return outTrackingLink;
    }
    final code = outTrackingCode.isNotEmpty ? outTrackingCode : processNumber;
    if (code.isEmpty) return null;

    final company = (cargoCompanyId ?? cargoCompany?.id ?? '').toLowerCase();
    if (company.contains('hepsijet')) {
      return 'https://www.hepsijet.com/gonderi-takibi/$code';
    } else if (company.contains('yurtici') || company.contains('yurtiçi')) {
      return 'https://www.yurticikargo.com/tr/online-servisler/gonderi-sorgula?code=$code';
    } else if (company.contains('ptt')) {
      return 'https://gonderitakip.ptt.gov.tr/Track/Verify?q=$code';
    } else if (company.contains('surat') || company.contains('sürat')) {
      return 'https://www.suratkargo.com.tr/KargoTakip/?kargotakipno=$code';
    } else if (company.contains('ups')) {
      return 'https://www.ups.com.tr/kargo_takip.aspx?takip_no=$code';
    } else if (company.contains('kolay') || company.contains('gelsin')) {
      return 'https://kolaygelsin.com/kargom-nerede?trackingNumber=$code';
    } else if (company.contains('aras')) {
      return 'https://kargotakip.araskargo.com.tr/?code=$code';
    } else if (company.contains('mng')) {
      return 'https://kargotakip.mngkargo.com.tr/?takipNo=$code';
    } else if (company.contains('trendyol')) {
      return 'https://kargotakip.trendyol.com/?trackingCode=$code';
    }
    return null;
  }

  String get statusText {
    if (status == 0) return 'Taslak';

    // Transaction tipine göre öncelikli durum çözümleme (Web Paneli ile %100 Parite)
    final type = effectiveTransactionType;
    if (type != null) {
      switch (type) {
        case 12:
        case 13:
          return 'İptal Edildi';
        case 6:
          return 'Teslim Edildi';
        case 5:
          return 'Dağıtımda';
        case 2:
        case 3:
        case 4:
        case 9:
          return 'Yolda / Transfer';
        case 1:
          return 'Kabul Bekleniyor';
        case 7:
          return 'Teslim Edilemedi';
        case 10:
        case 11:
          return 'İade Edildi';
      }
    }

    // Transaction yoksa status kodundan dinamik çözümle
    // Not: DB'de status == 3 iptal edilen/kapanan kargolardır (2.432 adet type 12/13 iptal kargo status=3'tür)
    switch (status) {
      case 0:
        return 'Taslak';
      case 1:
        return 'Kabul Bekleniyor';
      case 2:
        return 'Yolda';
      case 3:
      case 4:
        return 'İptal Edildi';
      default:
        return 'Durum #$status';
    }
  }

  String? get payOnDeliveryTypeText {
    if (payOnDeliveryType == 1) return 'Nakit';
    if (payOnDeliveryType == 2) return 'Kredi Kartı';
    return null;
  }

  String? get payOnDeliveryStatusText {
    switch (payOnDeliveryStatus) {
      case 0:
        return 'Tahsil Edilecek';
      case 1:
        return 'Tahsil Edildi';
      case 2:
        return 'Firmadan Tahsil Edildi';
      case 3:
        return 'Tamamlandı';
      case 4:
        return 'İptal Edildi';
      case 5:
        return 'Kargo Firması Tarafından Ödendi';
      default:
        return null;
    }
  }

  CargoModel copyWith({
    CargoParty? receiver,
    CargoParty? sender,
    CargoCompany? cargoCompany,
    CargoTransaction? latestTransaction,
    int? latestTransactionType,
    List<CargoTransaction>? transactions,
    String? outTrackingLink,
    DateTime? deliveredAt,
    int? status,
    double? payOnDeliveryCost,
    String? podTransactionId,
    dynamic collectionPeriod,
  }) {
    return CargoModel(
      id: id,
      processNumber: processNumber,
      outTrackingCode: outTrackingCode,
      outTrackingLink: outTrackingLink ?? this.outTrackingLink,
      orderNumber: orderNumber,
      status: status ?? this.status,
      payOnDelivery: payOnDelivery,
      payOnDeliveryAmount: payOnDeliveryAmount,
      payOnDeliveryCost: payOnDeliveryCost ?? this.payOnDeliveryCost,
      podTransactionId: podTransactionId ?? this.podTransactionId,
      collectionPeriod: collectionPeriod ?? this.collectionPeriod,
      payOnDeliveryType: payOnDeliveryType,
      payOnDeliveryStatus: payOnDeliveryStatus,
      payOnDeliveryOffsetDate: payOnDeliveryOffsetDate,
      totalPrice: totalPrice,
      userDesi: userDesi,
      validDesi: validDesi,
      senderId: senderId,
      receiverId: receiverId,
      cargoCompanyId: cargoCompanyId,
      description: description,
      createdAt: createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      receiver: receiver ?? this.receiver,
      sender: sender ?? this.sender,
      cargoCompany: cargoCompany ?? this.cargoCompany,
      latestTransaction: latestTransaction ?? this.latestTransaction,
      latestTransactionType: latestTransactionType ?? this.latestTransactionType,
      transactions: transactions ?? this.transactions,
    );
  }

  factory CargoModel.fromJson(Map<String, dynamic> json) {
    // Kargo şirketi çözümleme (ilişki veya company ID)
    CargoCompany? company;
    if (json['cargo_company'] is Map<String, dynamic>) {
      company = CargoCompany.fromJson(json['cargo_company']);
    } else if (json['cargo_company_id'] != null) {
      final cid = json['cargo_company_id'].toString();
      String title = cid;
      if (cid == 'ptt-kargo') title = 'PTT Kargo';
      if (cid == 'hepsijet') title = 'HEPSİJET';
      if (cid == 'surat-kargo') title = 'Sürat Kargo';
      if (cid == 'yurtici-kargo') title = 'Yurtiçi Kargo';
      if (cid == 'ups') title = 'UPS Kargo';
      if (cid == 'kolay-gelsin') title = 'Kolay Gelsin';
      company = CargoCompany(id: cid, title: title);
    }

    // Hareket listesi çözümleme
    List<CargoTransaction> txList = [];
    if (json['transactions'] is List) {
      txList = (json['transactions'] as List)
          .whereType<Map<String, dynamic>>()
          .map((t) => CargoTransaction.fromJson(t))
          .toList();
    }

    CargoParty? receiverParty;
    if (json['receiver'] is Map<String, dynamic>) {
      receiverParty = CargoParty.fromJson(json['receiver']);
    } else if (json['receiver.name'] != null || json['receiver.phone'] != null) {
      LocationRef? recCity;
      if (json['receiver.city.name'] != null || json['receiver.city_id'] != null) {
        recCity = LocationRef(
          id: json['receiver.city_id']?.toString(),
          name: json['receiver.city.name']?.toString() ?? '',
        );
      }
      LocationRef? recDist;
      if (json['receiver.district.name'] != null || json['receiver.district_id'] != null) {
        recDist = LocationRef(
          id: json['receiver.district_id']?.toString(),
          name: json['receiver.district.name']?.toString() ?? '',
        );
      }
      receiverParty = CargoParty(
        id: json['receiver.id']?.toString() ?? json['receiver_id']?.toString() ?? '',
        name: json['receiver.name']?.toString() ?? '',
        phone: json['receiver.phone']?.toString() ?? '',
        title: json['receiver.details']?.toString(),
        city: recCity,
        district: recDist,
      );
    }

    CargoParty? senderParty;
    if (json['sender'] is Map<String, dynamic>) {
      senderParty = CargoParty.fromJson(json['sender']);
    } else if (json['sender.name'] != null || json['sender.phone'] != null) {
      LocationRef? sndCity;
      if (json['sender.city.name'] != null || json['sender.city_id'] != null) {
        sndCity = LocationRef(
          id: json['sender.city_id']?.toString(),
          name: json['sender.city.name']?.toString() ?? '',
        );
      }
      LocationRef? sndDist;
      if (json['sender.district.name'] != null || json['sender.district_id'] != null) {
        sndDist = LocationRef(
          id: json['sender.district_id']?.toString(),
          name: json['sender.district.name']?.toString() ?? '',
        );
      }
      senderParty = CargoParty(
        id: json['sender.id']?.toString() ?? json['sender_id']?.toString() ?? '',
        name: json['sender.name']?.toString() ?? '',
        phone: json['sender.phone']?.toString() ?? '',
        title: json['sender.details']?.toString(),
        city: sndCity,
        district: sndDist,
      );
    }

    CargoTransaction? latestTx;
    if (json['latest_transaction'] is Map<String, dynamic>) {
      latestTx = CargoTransaction.fromJson(json['latest_transaction']);
    } else if (json['latest_transaction.type'] != null || json['latest_transaction.description'] != null) {
      latestTx = CargoTransaction(
        type: json['latest_transaction.type'] is int
            ? json['latest_transaction.type']
            : int.tryParse(json['latest_transaction.type']?.toString() ?? ''),
        description: json['latest_transaction.description']?.toString() ?? '',
        location: json['latest_transaction.location']?.toString(),
        createdAt: AppFormatters.parseUtcDateTime(json['latest_transaction.created_at']),
      );
    } else if (txList.isNotEmpty) {
      latestTx = txList.last;
    }

    final rawTxType = json['latest_transaction_type'] ?? json['latest_transaction.type'];
    final parsedTxType = rawTxType is int
        ? rawTxType
        : int.tryParse(rawTxType?.toString() ?? '');

    return CargoModel(
      id: json['id']?.toString() ?? '',
      processNumber: json['process_number']?.toString() ?? '',
      outTrackingCode: json['out_tracking_code']?.toString() ?? '',
      outTrackingLink: json['out_tracking_link']?.toString(),
      orderNumber: json['order_number']?.toString(),
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      payOnDelivery: json['pay_on_delivery'] == true || json['pay_on_delivery'] == 1,
      payOnDeliveryAmount: (json['pay_on_delivery_amount'] is num)
          ? (json['pay_on_delivery_amount'] as num).toDouble()
          : double.tryParse(json['pay_on_delivery_amount']?.toString() ?? ''),
      payOnDeliveryCost: (json['pay_on_delivery_cost'] is num)
          ? (json['pay_on_delivery_cost'] as num).toDouble()
          : double.tryParse(json['pay_on_delivery_cost']?.toString() ?? ''),
      podTransactionId: json['pod_transaction_id']?.toString(),
      collectionPeriod: json['collection_period'],
      payOnDeliveryType: json['pay_on_delivery_type'] is int
          ? json['pay_on_delivery_type']
          : int.tryParse(json['pay_on_delivery_type']?.toString() ?? ''),
      payOnDeliveryStatus: json['pay_on_delivery_status'] is int
          ? json['pay_on_delivery_status']
          : int.tryParse(json['pay_on_delivery_status']?.toString() ?? ''),
      payOnDeliveryOffsetDate: AppFormatters.parseUtcDateTime(json['pay_on_delivery_offset_date']),
      totalPrice: (json['total_price'] is num)
          ? (json['total_price'] as num).toDouble()
          : double.tryParse(json['total_price']?.toString() ?? ''),
      userDesi: (json['user_desi'] is num)
          ? (json['user_desi'] as num).toDouble()
          : double.tryParse(json['user_desi']?.toString() ?? ''),
      validDesi: (json['valid_desi'] is num)
          ? (json['valid_desi'] as num).toDouble()
          : double.tryParse(json['valid_desi']?.toString() ?? ''),
      senderId: json['sender_id']?.toString(),
      receiverId: json['receiver_id']?.toString(),
      cargoCompanyId: json['cargo_company_id']?.toString(),
      description: json['description']?.toString(),
      createdAt: AppFormatters.parseUtcDateTime(json['created_at']),
      deliveredAt: AppFormatters.parseUtcDateTime(json['delivered_at']),
      receiver: receiverParty,
      sender: senderParty,
      cargoCompany: company,
      latestTransaction: latestTx,
      latestTransactionType: parsedTxType,
      transactions: txList,
    );
  }
}
