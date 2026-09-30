import 'dart:convert';
import 'package:http/http.dart' as http;

class CargoService {
  // Stocado Kargo Paneli API Temel Adresi
  static const String baseUrl = "https://api.kargopaneli.com/v1";

  /// Yeni kargo oluşturma isteği atar.
  /// API dokümanına uygun olarak [foreign_address] ve [package] objeleri zorunludur.
  Future<bool> createCargo({
    required String token,
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
    required String cargoCompanyId, // Örn: "ups", "hepsijet", "ptt-kargo", "surat-kargo", "yurtici-kargo", "kolay-gelsin"
  }) async {
    
    // Sunucuya gönderilecek tam JSON gövdesi (Request Body)
    final Map<String, dynamic> cargoData = {
      // TODO: Giriş yapan kullanıcının kendi account_id ve local_id (gönderici adres) verilerini API'den çekip buraya eklemelisin.
      // Şimdilik sunucunun 400 Bad Request dönmemesi için dokümandaki örnek/test ID'leri kullanıyoruz.
      "account_id": "01JTKX1J501BSD8DAG1A6ZPBPM", 
      "local_id": "01JTKX24X2GCVNHST3HJGJC8JP",   
      "cargo_company_id": cargoCompanyId,
      "direction": 1, // Kargo Yönü (1 genelde normal gönderimdir)
      "source": "mobile", // Kargonun mobil uygulamadan oluşturulduğunu belirtir
      "status": 1, // 1: Aktif, 2: Taslak
      
      // Alıcı Adres Objesi
      "foreign_address": {
        "name": recipientName,
        "phone": recipientPhone,
        "details": recipientAddressDetails,
        "country_id": "TR", 
        "city_id": cityId,
        "district_id": districtId,
        "type": 1 // 1: Şahıs/Bireysel, 4: Kurumsal
      },
      
      // Paket Ölçüleri Objesi
      "package": {
        "desi": desi,
        "width": width,
        "length": length,
        "height": height,
        "weight": weight // Gram cinsinden ağırlık
      },
      
      "pay_on_delivery": false // Kapıda ödeme seçeneği
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cargos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(cargoData),
      );

      // Başarılı durum kontrolü (200 OK veya 201 Created)
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Kargo başarıyla oluşturuldu: ${response.body}');
        return true;
      } else {
        // Hata durumunda konsola detaylı bilgi yazdırıyoruz ki sorunu anında çözelim
        print('HATA: Kargo reddedildi. Status Kodu: ${response.statusCode}');
        print('Hata Detayı: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Ağ veya sunucu bağlantı hatası: $e');
      return false;
    }
  }
}