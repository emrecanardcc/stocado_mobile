// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiTester {
  static const String baseUrl = "https://api.kargopaneli.com/v1";
  String? _token;

  Future<void> runAllTests(String email, String password) async {
    print("--- API TESTLERI BASLIYOR ---");

    // 1. Giris Yap ve Token Al
    print("\n1. POST /auth/login testi yapiliyor...");
    try {
      final loginRes = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (loginRes.statusCode == 200) {
        final data = jsonDecode(loginRes.body);
        _token = data['token'];
        print("[SUCCESS] Basarili! Token alindi.");
      } else {
        print("[FAIL] Login Basarisiz: ${loginRes.statusCode} - ${loginRes.body}");
        return;
      }

      // 2. Ulkeleri Listele
      print("\n2. GET /locations/countries testi yapiliyor...");
      final countryRes = await http.get(
        Uri.parse('$baseUrl/locations/countries'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      print("Durum: ${countryRes.statusCode}");
      print("Donen JSON: ${countryRes.body}");

      // 3. Para Birimlerini Listele
      print("\n3. GET /currencies testi yapiliyor...");
      final currencyRes = await http.get(
        Uri.parse('$baseUrl/currencies'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      print("Durum: ${currencyRes.statusCode}");
      print("Donen JSON: ${currencyRes.body}");

      print("\n--- API TESTLERI TAMAMLANDI ---");
    } catch (e) {
      print("Ag Hatasi: $e");
    }
  }
}
