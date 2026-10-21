class Country {
  final String id;
  final String name;
  final String? zoneCode;
  final String? region;
  final List<City> cities;

  Country({
    required this.id,
    required this.name,
    this.zoneCode,
    this.region,
    required this.cities,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      zoneCode: json['zone_code'],
      region: json['region'],
      cities: json['cities'] != null 
          ? (json['cities'] as List).map((i) => City.fromJson(i as Map<String, dynamic>)).toList() 
          : [],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class City {
  final int id;
  final String name;
  final List<District> districts;

  City({
    required this.id,
    required this.name,
    this.districts = const [],
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? '',
      districts: json['districts'] != null 
          ? (json['districts'] as List).map((i) => District.fromJson(i as Map<String, dynamic>)).toList() 
          : [],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is City && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class District {
  final int id;
  final String name;

  District({
    required this.id,
    required this.name,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is District && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}