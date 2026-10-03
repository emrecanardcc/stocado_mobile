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
          ? (json['cities'] as List).map((i) => City.fromJson(i)).toList() 
          : [],
    );
  }
}

class City {
  final int id;
  final String name;
  final List<District> districts;

  City({
    required this.id,
    required this.name,
    required this.districts,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      districts: json['districts'] != null 
          ? (json['districts'] as List).map((i) => District.fromJson(i)).toList() 
          : [],
    );
  }
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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}