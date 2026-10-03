import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = "https://api.kargopaneli.com/v1";
  final _storage = const FlutterSecureStorage();

  // Tüm isteklere ortak header'ları ve Token'ı otomatik ekler
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Ortak GET İsteği
  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
    _handleErrors(response);
    return response;
  }

  // Ortak POST İsteği
  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    _handleErrors(response);
    return response;
  }

  // Ortak Hata Yönetimi
  void _handleErrors(http.Response response) {
    if (response.statusCode == 401) {
      print("HATA: Oturum süresi dolmuş veya token geçersiz!");
      // TODO: Riverpod üzerinden authProvider.logout() tetiklenip kullanıcı Login'e atılacak
    } else if (response.statusCode >= 500) {
      print("HATA: Sunucu taraflı bir sorun var. Status: ${response.statusCode}");
    }
  }
}