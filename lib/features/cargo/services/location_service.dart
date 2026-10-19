import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../../../core/network/api_client.dart';

class LocationService {
  final ApiClient _apiClient;
  static List<Country>? _cachedCountries;
  static List<City>? _cachedCities;
  static final Map<int, List<District>> _cachedDistricts = {};

  LocationService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

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

    return [];
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

    return [];
  }

  /// Seçili şehre ait ilçeleri canlı API'den getirir
  /// GET /locations/cities/{cityId}/districts
  Future<List<District>> getDistricts(int cityId) async {
    if (_cachedDistricts.containsKey(cityId)) {
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
          _cachedDistricts[cityId] = list;
          return list;
        }
      }
    } catch (e) {
      debugPrint('LocationService.getDistricts hatası: $e');
    }

    return [];
  }
}
