import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiTester {
  static const String baseUrl = "https://api.kargopaneli.com/v1";
  String? _token;

  Future<void> runAllTests(String email, String password) async {
    print("--- API TESTLERİ BAŞLIYOR ---");

    // 1. Giriş Yap ve Token Al
    print("\n1. POST /auth/login testi yapılıyor...");
    try {
      final loginRes = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (loginRes.statusCode == 200) {
        final data = jsonDecode(loginRes.body);
        _token = data['token'];
        print("✅ Başarılı! Token alındı.");
      } else {
        print("❌ Login Başarısız: ${loginRes.statusCode} - ${loginRes.body}");
        return; // Token yoksa diğer testlere geçemeyiz
      }

      // 2. Ülkeleri Listele
      print("\n2. GET /locations/countries testi yapılıyor...");
      final countryRes = await http.get(
        Uri.parse('$baseUrl/locations/countries'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      print("Durum: ${countryRes.statusCode}");
      print("Dönen JSON: ${countryRes.body}");

      // 3. Para Birimlerini Listele
      print("\n3. GET /currencies testi yapılıyor...");
      final currencyRes = await http.get(
        Uri.parse('$baseUrl/currencies'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      print("Durum: ${currencyRes.statusCode}");
      print("Dönen JSON: ${currencyRes.body}");

      print("\n--- API TESTLERİ TAMAMLANDI ---");
    } catch (e) {
      print("Ağ Hatası: $e");
    }
  }
}