import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/location_model.dart';
import '../../../core/network/api_client.dart';

class LocationService {
  final ApiClient _apiClient;
  static List<Country>? _cachedCountries;
  static List<City>? _cachedCities;
  static final Map<int, List<District>> _cachedDistricts = {};
  static bool _isLoadingLocalAsset = false;

  LocationService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Varlıklar (assets) içindeki 81 il ve tüm ilçeleri barındıran yerel JSON'ı okur
  Future<void> _loadLocalLocations() async {
    if (_cachedCities != null && _cachedCities!.isNotEmpty) return;
    if (_isLoadingLocalAsset) return;
    _isLoadingLocalAsset = true;

    try {
      final jsonStr = await rootBundle.loadString('assets/data/turkey_locations.json');
      final decoded = jsonDecode(jsonStr);
      if (decoded is List && decoded.isNotEmpty) {
        final List<Country> countries = [];
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final country = Country.fromJson(item);
            countries.add(country);
            if (country.id == 'TR') {
              _cachedCities = country.cities;
              for (final city in country.cities) {
                if (city.districts.isNotEmpty) {
                  _cachedDistricts[city.id] = city.districts;
                }
              }
            }
          }
        }
        if (countries.isNotEmpty) {
          _cachedCountries = countries;
        }
      }
    } catch (e) {
      debugPrint('LocationService yerel JSON yükleme hatası: $e');
    } finally {
      _isLoadingLocalAsset = false;
    }
  }

  /// Canlı veritabanından tüm ülkeleri çeker
  /// GET /locations/countries
  Future<List<Country>> getCountries() async {
    if (_cachedCountries != null && _cachedCountries!.isNotEmpty) {
      return _cachedCountries!;
    }

    try {
      final response = await _apiClient.get('/locations/countries');
      if (response.statusCode == 200) {
        final decoded = ApiClient.decodeResponse(response);
        if (decoded is List) {
          _cachedCountries = decoded
              .map((json) => Country.fromJson(json as Map<String, dynamic>))
              .toList();
          return _cachedCountries!;
        }
      }
    } catch (e) {
      debugPrint('LocationService.getCountries hatası: $e');
    }

    await _loadLocalLocations();
    return _cachedCountries ?? [Country(id: 'TR', name: 'Türkiye', cities: _cachedCities ?? _defaultCities)];
  }

  /// Seçili ülkeye ait şehirleri canlı API'den getirir (Varsayılan: 'TR' - Türkiye)
  /// GET /locations/countries/{countryId}/cities veya GET /locations/cities
  Future<List<City>> getCities([String countryId = 'TR']) async {
    if (_cachedCities != null && _cachedCities!.isNotEmpty) {
      return _cachedCities!;
    }

    try {
      var response = await _apiClient.get('/locations/countries/$countryId/cities');
      if (response.statusCode != 200) {
        response = await _apiClient.get('/locations/cities');
      }

      if (response.statusCode == 200) {
        final decoded = ApiClient.decodeResponse(response);
        if (decoded is List) {
          final list = decoded
              .map((json) => City.fromJson(json as Map<String, dynamic>))
              .toList();
          _cachedCities = list;
          return list;
        }
      }
    } catch (e) {
      debugPrint('LocationService.getCities hatası: $e');
    }

    // API erişilemezse yerel paketteki tüm 81 ili yükle
    await _loadLocalLocations();
    if (_cachedCities != null && _cachedCities!.isNotEmpty) {
      return _cachedCities!;
    }

    // En son emniyet fallback'i
    return _defaultCities;
  }

  /// Seçili şehre ait ilçeleri canlı API'den getirir
  /// GET /locations/cities/{cityId}/districts
  Future<List<District>> getDistricts(int cityId) async {
    if (_cachedDistricts.containsKey(cityId) && _cachedDistricts[cityId]!.isNotEmpty) {
      return _cachedDistricts[cityId]!;
    }

    try {
      final response = await _apiClient.get('/locations/cities/$cityId/districts');
      if (response.statusCode == 200) {
        final decoded = ApiClient.decodeResponse(response);
        if (decoded is List) {
          final list = decoded
              .map((json) => District.fromJson(json as Map<String, dynamic>))
              .toList();
          if (list.isNotEmpty) {
            _cachedDistricts[cityId] = list;
            return list;
          }
        }
      }
    } catch (e) {
      debugPrint('LocationService.getDistricts hatası: $e');
    }

    // API erişilemezse yerel paketteki ilçe verisini yükle
    await _loadLocalLocations();
    if (_cachedDistricts.containsKey(cityId) && _cachedDistricts[cityId]!.isNotEmpty) {
      return _cachedDistricts[cityId]!;
    }

    // Ağ hatasında formun kilitlenmesini önlemek için varsayılan ilçe fallback'i
    return [District(id: cityId * 100 + 1, name: 'Merkez')];
  }

  static final List<City> _defaultCities = [
    City(id: 34, name: 'İstanbul'),
    City(id: 6, name: 'Ankara'),
    City(id: 35, name: 'İzmir'),
    City(id: 1, name: 'Adana'),
    City(id: 7, name: 'Antalya'),
    City(id: 16, name: 'Bursa'),
    City(id: 20, name: 'Denizli'),
    City(id: 21, name: 'Diyarbakır'),
    City(id: 26, name: 'Eskişehir'),
    City(id: 27, name: 'Gaziantep'),
    City(id: 31, name: 'Hatay'),
    City(id: 38, name: 'Kayseri'),
    City(id: 41, name: 'Kocaeli'),
    City(id: 42, name: 'Konya'),
    City(id: 45, name: 'Manisa'),
    City(id: 33, name: 'Mersin'),
    City(id: 48, name: 'Muğla'),
    City(id: 52, name: 'Ordu'),
    City(id: 54, name: 'Sakarya'),
    City(id: 55, name: 'Samsun'),
    City(id: 59, name: 'Tekirdağ'),
    City(id: 61, name: 'Trabzon'),
    City(id: 63, name: 'Şanlıurfa'),
  ];
}
