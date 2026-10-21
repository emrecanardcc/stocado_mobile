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
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
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
    return CargoParty(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      title: json['title']?.toString(),
      city: json['city'] is Map<String, dynamic> ? LocationRef.fromJson(json['city']) : null,
      district: json['district'] is Map<String, dynamic> ? LocationRef.fromJson(json['district']) : null,
    );
  }

  factory CargoParty.fromAddress(AddressModel address) {
    return CargoParty(
      id: address.id,
      name: address.name,
      phone: address.phone,
      title: address.title,
      city: address.city,
      district: address.district,
    );
  }
}

class CargoModel {
  final dynamic id;
  final String processNumber;
  final String outTrackingCode;
  final String? orderNumber;
  final int status; // 0 = taslak, 1 = aktif vb.
  final bool payOnDelivery;
  final double? payOnDeliveryAmount;
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
  final CargoParty? receiver;
  final CargoParty? sender;
  final CargoCompany? cargoCompany;
  final CargoTransaction? latestTransaction;

  CargoModel({
    required this.id,
    required this.processNumber,
    required this.outTrackingCode,
    this.orderNumber,
    required this.status,
    required this.payOnDelivery,
    this.payOnDeliveryAmount,
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
    this.receiver,
    this.sender,
    this.cargoCompany,
    this.latestTransaction,
  });

  bool get isDraft => status == 0;

  String get statusText {
    if (status == 0) return 'Taslak';
    if (status == 4) return 'İptal Edildi';

    // Transaction tipine göre öncelikli durum çözümleme
    if (latestTransaction != null && latestTransaction!.type != null) {
      switch (latestTransaction!.type!) {
        case 1:
          return 'Gönderime Hazır';
        case 2:
        case 3:
        case 4:
        case 9:
          return 'Yolda / Transfer';
        case 5:
          return 'Dağıtımda';
        case 6:
          return 'Teslim Edildi';
        case 7:
          return 'Teslim Edilemedi';
        case 10:
        case 11:
          return 'İade Edildi';
        case 13:
          return 'Sorunlu / İptal';
      }
    }

    // Transaction yoksa genel status kodundan çözümle
    switch (status) {
      case 0:
        return 'Taslak';
      case 1:
        return 'Gönderime Hazır';
      case 2:
        return 'Yolda';
      case 3:
        return 'Teslim Edildi';
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
        return 'Stocado\'da';
      case 3:
        return 'Tamamlandı';
      case 4:
        return 'İptal';
      case 5:
        return 'Firma Ödedi';
      default:
        return null;
    }
  }

  CargoModel copyWith({
    CargoParty? receiver,
    CargoParty? sender,
    CargoCompany? cargoCompany,
  }) {
    return CargoModel(
      id: id,
      processNumber: processNumber,
      outTrackingCode: outTrackingCode,
      orderNumber: orderNumber,
      status: status,
      payOnDelivery: payOnDelivery,
      payOnDeliveryAmount: payOnDeliveryAmount,
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
      receiver: receiver ?? this.receiver,
      sender: sender ?? this.sender,
      cargoCompany: cargoCompany ?? this.cargoCompany,
      latestTransaction: latestTransaction,
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

    return CargoModel(
      id: json['id']?.toString() ?? '',
      processNumber: json['process_number']?.toString() ?? '',
      outTrackingCode: json['out_tracking_code']?.toString() ?? '',
      orderNumber: json['order_number']?.toString(),
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      payOnDelivery: json['pay_on_delivery'] == true || json['pay_on_delivery'] == 1,
      payOnDeliveryAmount: (json['pay_on_delivery_amount'] is num)
          ? (json['pay_on_delivery_amount'] as num).toDouble()
          : double.tryParse(json['pay_on_delivery_amount']?.toString() ?? ''),
      payOnDeliveryType: json['pay_on_delivery_type'] is int
          ? json['pay_on_delivery_type']
          : int.tryParse(json['pay_on_delivery_type']?.toString() ?? ''),
      payOnDeliveryStatus: json['pay_on_delivery_status'] is int
          ? json['pay_on_delivery_status']
          : int.tryParse(json['pay_on_delivery_status']?.toString() ?? ''),
      payOnDeliveryOffsetDate: json['pay_on_delivery_offset_date'] != null
          ? DateTime.tryParse(json['pay_on_delivery_offset_date'].toString())
          : null,
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
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      receiver: json['receiver'] is Map<String, dynamic> ? CargoParty.fromJson(json['receiver']) : null,
      sender: json['sender'] is Map<String, dynamic> ? CargoParty.fromJson(json['sender']) : null,
      cargoCompany: company,
      latestTransaction: json['latest_transaction'] is Map<String, dynamic>
          ? CargoTransaction.fromJson(json['latest_transaction'])
          : null,
    );
  }
}
