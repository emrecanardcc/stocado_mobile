class LocationRef {
  final dynamic id;
  final String name;

  LocationRef({required this.id, required this.name});

  factory LocationRef.fromJson(Map<String, dynamic> json) {
    return LocationRef(
      id: json['id'],
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationRef && runtimeType == other.runtimeType && id?.toString() == other.id?.toString();

  @override
  int get hashCode => id?.toString().hashCode ?? 0;
}

class AddressModel {
  final String id;
  final String title;
  final String name;
  final String phone;
  final String? email;
  final String details;
  final bool isDefault;
  final int type; // 1=Alıcı, 2=İletişim, 3=Fatura, 4=Gönderici
  final int? cityId;
  final int? districtId;
  final String? countryId;
  final LocationRef? city;
  final LocationRef? district;
  final LocationRef? country;
  final String? postalCode;
  final String? corporateName;
  final String? vkn;
  final String? responsiblePersonName;
  final String? responsiblePersonLastname;
  final String? responsiblePersonTckn;
  final int? status;

  AddressModel({
    required this.id,
    required this.title,
    required this.name,
    required this.phone,
    this.email,
    required this.details,
    required this.isDefault,
    required this.type,
    this.cityId,
    this.districtId,
    this.countryId,
    this.city,
    this.district,
    this.country,
    this.postalCode,
    this.corporateName,
    this.vkn,
    this.responsiblePersonName,
    this.responsiblePersonLastname,
    this.responsiblePersonTckn,
    this.status,
  });

  bool get isSender => type == 4;
  bool get isCustomer => type == 1;
  bool get isActive => status == null || status == 1;

  String get displayName {
    if (name.isNotEmpty) return name;
    if (title.isNotEmpty) return title;
    if (corporateName != null && corporateName!.isNotEmpty) return corporateName!;
    return 'Adres ($id)';
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    LocationRef? parsedCity;
    if (json['city'] is Map<String, dynamic>) {
      parsedCity = LocationRef.fromJson(json['city']);
    }

    LocationRef? parsedDistrict;
    if (json['district'] is Map<String, dynamic>) {
      parsedDistrict = LocationRef.fromJson(json['district']);
    }

    LocationRef? parsedCountry;
    if (json['country'] is Map<String, dynamic>) {
      parsedCountry = LocationRef.fromJson(json['country']);
    }

    final cId = json['city_id'] is int
        ? json['city_id'] as int
        : (int.tryParse(json['city_id']?.toString() ?? '') ?? (parsedCity?.id is int ? parsedCity?.id as int : null));

    final dId = json['district_id'] is int
        ? json['district_id'] as int
        : (int.tryParse(json['district_id']?.toString() ?? '') ?? (parsedDistrict?.id is int ? parsedDistrict?.id as int : null));

    return AddressModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      details: json['details']?.toString() ?? '',
      isDefault: json['is_default'] == true,
      type: json['type'] is int ? json['type'] : int.tryParse(json['type']?.toString() ?? '') ?? 1,
      cityId: cId,
      districtId: dId,
      countryId: json['country_id']?.toString() ?? 'TR',
      city: parsedCity,
      district: parsedDistrict,
      country: parsedCountry,
      postalCode: json['postal_code']?.toString(),
      corporateName: json['corporate_name']?.toString(),
      vkn: json['vkn']?.toString(),
      responsiblePersonName: json['responsible_person_name']?.toString(),
      responsiblePersonLastname: json['responsible_person_lastname']?.toString(),
      responsiblePersonTckn: json['responsible_person_tckn']?.toString(),
      status: json['status'] is int
          ? json['status'] as int
          : int.tryParse(json['status']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'name': name,
      'phone': phone,
      'email': email,
      'details': details,
      'is_default': isDefault,
      'type': type,
      'city_id': cityId,
      'district_id': districtId,
      'country_id': countryId,
      'city': city?.toJson(),
      'district': district?.toJson(),
      'country': country?.toJson(),
      'postal_code': postalCode,
      'corporate_name': corporateName,
      'vkn': vkn,
      'responsible_person_name': responsiblePersonName,
      'responsible_person_lastname': responsiblePersonLastname,
      'responsible_person_tckn': responsiblePersonTckn,
      'status': status,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
