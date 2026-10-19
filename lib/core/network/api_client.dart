import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = "https://api.kargopaneli.com/v1";
  static const String tokenKey = "auth_token";
  
  final FlutterSecureStorage _storage;
  
  /// Global 401 (Unauthorized) durumunda tetiklenecek callback (örn: authProvider.logout)
  static VoidCallback? onUnauthorized;

  ApiClient({FlutterSecureStorage? storage}) 
      : _storage = storage ?? const FlutterSecureStorage();

  /// İstek başlıklarını hazırlar ve Secure Storage'daki JWT'yi ekler
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: tokenKey);
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Endpoint ve Query parametrelerini Uri objesine dönüştürür
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final baseUri = Uri.parse('$baseUrl$cleanEndpoint');
    
    if (queryParameters == null || queryParameters.isEmpty) {
      return baseUri;
    }

    final Map<String, String> stringParams = {};
    queryParameters.forEach((key, value) {
      if (value != null) {
        stringParams[key] = value.toString();
      }
    });

    return baseUri.replace(queryParameters: stringParams);
  }

  /// Ortak GET İsteği
  Future<http.Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    final uri = _buildUri(endpoint, queryParameters);
    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers);
    _handleErrors(response);
    return response;
  }

  /// Ortak POST İsteği
  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async {
    final uri = _buildUri(endpoint, queryParameters);
    final headers = await _getHeaders();
    final response = await http.post(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    _handleErrors(response);
    return response;
  }

  /// Ortak PUT İsteği
  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async {
    final uri = _buildUri(endpoint, queryParameters);
    final headers = await _getHeaders();
    final response = await http.put(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    _handleErrors(response);
    return response;
  }

  /// Ortak DELETE İsteği
  Future<http.Response> delete(String endpoint, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async {
    final uri = _buildUri(endpoint, queryParameters);
    final headers = await _getHeaders();
    final response = await http.delete(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    _handleErrors(response);
    return response;
  }

  /// Ortak Hata Yönetimi
  void _handleErrors(http.Response response) {
    if (response.statusCode == 401) {
      debugPrint("ApiClient HATA (401): Oturum süresi dolmuş veya token geçersiz!");
      onUnauthorized?.call();
    } else if (response.statusCode >= 500) {
      debugPrint("ApiClient HATA (${response.statusCode}): Sunucu hatası.");
    }
  }

  /// JSON parse yardımcısı
  static dynamic decodeResponse(http.Response response) {
    if (response.body.isEmpty) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}