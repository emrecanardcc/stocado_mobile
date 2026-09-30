import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Stocado Kargo Paneli API Temel Adresi
  static const String baseUrl = "https://api.kargopaneli.com/v1";

  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email, // Ekip aksini söylerse 'username' olarak değiştireceğiz
          'password': password,
        }),
      );

      // 200 Başarılı giriş kodu
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token']; // API'den dönen JWT token
      } else {
        print('Giriş reddedildi. Durum Kodu: ${response.statusCode}');
        print('Sunucu Yanıtı: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Ağ hatası veya sunucuya ulaşılamadı: $e');
      return null;
    }
  }
}