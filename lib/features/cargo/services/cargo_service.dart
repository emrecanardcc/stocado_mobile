import 'dart:convert';
import '../models/location_model.dart';
import '../../../core/network/api_client.dart';

class CargoService {
  final ApiClient _apiClient = ApiClient();

  // DİKKAT: Artık parametre olarak token almıyoruz!
  Future<List<Country>> getCountries() async {
    try {
      // Sadece endpoint'i yazıyoruz, gerisini ApiClient hallediyor
      final response = await _apiClient.get('/locations/countries');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Country.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Lokasyonlar çekilemedi: $e');
      return [];
    }
  }

  // DİKKAT: Artık parametre olarak token almıyoruz!
  Future<bool> createCargo({
    required String recipientName,
    required String recipientPhone,
    required String recipientAddressDetails,
    required int cityId,
    required int districtId,
    required double desi,
    required double width,
    required double length,
    required double height,
    required double weight,
    required String cargoCompanyId,
  }) async {
    final Map<String, dynamic> cargoData = {
      "account_id": "01JTKX1J501BSD8DAG1A6ZPBPM", 
      "local_id": "01JTKX24X2GCVNHST3HJGJC8JP",   
      "cargo_company_id": cargoCompanyId,
      "direction": 1,
      "source": "mobile",
      "status": 1,
      "foreign_address": {
        "name": recipientName,
        "phone": recipientPhone,
        "details": recipientAddressDetails,
        "country_id": "TR", 
        "city_id": cityId,
        "district_id": districtId,
        "type": 1 
      },
      "package": {
        "desi": desi,
        "width": width,
        "length": length,
        "height": height,
        "weight": weight
      },
      "pay_on_delivery": false
    };

    try {
      // Sadece endpoint ve body yolluyoruz
      final response = await _apiClient.post('/cargos', body: cargoData);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}