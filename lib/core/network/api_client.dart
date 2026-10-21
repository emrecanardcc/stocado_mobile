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
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      return null;
    }
  }

  /// Sunucudan gelen http.Response veya Exception'lardan kullanıcı dostu,
  /// net ve boş olmayan Türkçe hata mesajı türetir.
  static String parseError(dynamic errorOrResponse, {String defaultMessage = 'İşlem gerçekleştirilemedi.'}) {
    if (errorOrResponse == null) return defaultMessage;

    // 1. Ağ veya Sistem İstisnası (Exception / Error)
    if (errorOrResponse is Exception || errorOrResponse is Error) {
      final errStr = errorOrResponse.toString().toLowerCase();
      if (errStr.contains('socketexception') ||
          errStr.contains('connection refused') ||
          errStr.contains('network is unreachable') ||
          errStr.contains('failed host lookup') ||
          errStr.contains('no address associated with hostname')) {
        return 'İnternet bağlantısı kurulamadı. Lütfen ağınızı kontrol edip tekrar deneyin.';
      }
      if (errStr.contains('timeoutexception') || errStr.contains('timed out')) {
        return 'Sunucu yanıt vermedi (Zaman aşımı). Lütfen birazdan tekrar deneyiniz.';
      }
      if (errStr.contains('formatexception')) {
        return 'Sunucudan beklenmeyen veri formatı alındı.';
      }
      if (errStr.contains('clientexception')) {
        return 'Ağ bağlantısı koptu. Lütfen tekrar deneyin.';
      }
      return 'Bağlantı hatası: ${errorOrResponse.toString()}';
    }

    // 2. HTTP Yanıtı (http.Response)
    if (errorOrResponse is http.Response) {
      final statusCode = errorOrResponse.statusCode;
      final rawBody = errorOrResponse.body.trim();

      if (rawBody.isEmpty) {
        return _statusToMessage(statusCode, defaultMessage);
      }

      try {
        final decoded = jsonDecode(utf8.decode(errorOrResponse.bodyBytes));
        if (decoded is Map<String, dynamic>) {
          // A) Form doğrulama hataları (Laravel 'errors' haritası)
          if (decoded['errors'] is Map<String, dynamic>) {
            final errorsMap = decoded['errors'] as Map<String, dynamic>;
            final List<String> fieldErrors = [];

            errorsMap.forEach((field, val) {
              final fieldLabel = _translateFieldName(field);
              if (val is List && val.isNotEmpty) {
                fieldErrors.add('$fieldLabel: ${val.join(", ")}');
              } else if (val is String && val.isNotEmpty) {
                fieldErrors.add('$fieldLabel: $val');
              }
            });

            if (fieldErrors.isNotEmpty) {
              return fieldErrors.join(' • ');
            }
          }

          // B) Mesaj dizisi (Stocado 'messages' listesi)
          if (decoded['messages'] is List) {
            final msgs = decoded['messages'] as List;
            final List<String> texts = [];
            for (final m in msgs) {
              if (m is Map && m['text'] != null && m['text'].toString().trim().isNotEmpty) {
                texts.add(m['text'].toString().trim());
              } else if (m is String && m.trim().isNotEmpty) {
                texts.add(m.trim());
              }
            }
            if (texts.isNotEmpty) {
              return texts.join(' • ');
            }
          }

          // C) Doğrudan 'message', 'error', 'detail' anahtarları
          for (final key in ['message', 'error', 'detail', 'reason', 'error_description']) {
            if (decoded[key] != null && decoded[key].toString().trim().isNotEmpty) {
              final val = decoded[key].toString().trim();
              final lower = val.toLowerCase();
              if (lower == 'the given data was invalid.' || lower == 'validation error') {
                return 'Girilen bilgiler geçersiz. Lütfen form alanlarını kontrol ediniz.';
              }
              if (lower == 'unauthenticated.' || lower == 'unauthorized') {
                return 'Oturum süresi dolmuş veya giriş yetkiniz bulunmuyor.';
              }
              return val;
            }
          }
        } else if (decoded is List && decoded.isNotEmpty) {
          final first = decoded.first;
          if (first is Map && first['text'] != null) {
            return first['text'].toString();
          } else if (first is String && first.isNotEmpty) {
            return first;
          }
        }
      } catch (_) {
        // Body JSON değilse (örn. HTML sunucu hata sayfası)
      }

      return _statusToMessage(statusCode, defaultMessage);
    }

    final str = errorOrResponse.toString().trim();
    return str.isNotEmpty ? str : defaultMessage;
  }

  /// HTTP durum koduna göre Türkçe açıklama döner
  static String _statusToMessage(int statusCode, String defaultMessage) {
    switch (statusCode) {
      case 400:
        return 'Geçersiz istek parametreleri gönderildi.';
      case 401:
        return 'Oturum süreniz doldu veya giriş yetkiniz yok. Lütfen tekrar giriş yapın.';
      case 403:
        return 'Bu işlem için yetkiniz bulunmuyor.';
      case 404:
        return 'Aradığınız kayıt veya işlem noktası bulunamadı.';
      case 409:
        return 'Bu kayıt veya bilgi sistemde zaten mevcut.';
      case 422:
        return 'Girilen form bilgileri geçersiz. Lütfen alanları kontrol ediniz.';
      case 429:
        return 'Çok fazla istek yapıldı. Lütfen biraz bekleyip tekrar deneyin.';
      case 500:
        return 'Sunucu hatası oluştu (500). Lütfen daha sonra tekrar deneyiniz.';
      case 502:
        return 'Sunucu geçidi yanıt vermiyor (502). Bakım çalışması yapılıyor olabilir.';
      case 503:
        return 'Hizmet şu anda kullanılamıyor (503). Sunucu geçici bakımda.';
      case 504:
        return 'Sunucu zaman aşımına uğradı (504). Lütfen tekrar deneyin.';
      default:
        return defaultMessage;
    }
  }

  /// API alan adlarını Türkçe etiketlere dönüştürür
  static String _translateFieldName(String field) {
    switch (field.toLowerCase()) {
      case 'phone':
        return 'Telefon';
      case 'name':
        return 'Ad / Firma';
      case 'email':
        return 'E-posta';
      case 'password':
        return 'Şifre';
      case 'city_id':
        return 'İl';
      case 'district_id':
        return 'İlçe';
      case 'details':
        return 'Açık Adres';
      case 'postal_code':
        return 'Posta Kodu';
      case 'vkn':
        return 'Vergi No (VKN)';
      case 'tckn':
      case 'responsible_person_tckn':
        return 'TCKN';
      case 'responsible_person_name':
        return 'Yetkili Adı';
      case 'responsible_person_lastname':
        return 'Yetkili Soyadı';
      case 'corporate_name':
        return 'Şirket Ünvanı';
      case 'desi':
        return 'Desi';
      case 'weight':
        return 'Ağırlık';
      case 'width':
        return 'En';
      case 'height':
        return 'Yükseklik';
      case 'length':
        return 'Boy';
      case 'price':
        return 'Fiyat';
      case 'barcode':
        return 'Barkod';
      case 'code':
        return 'Ürün Kodu';
      case 'pay_on_delivery_amount':
        return 'Kapıda Ödeme Tutarı';
      case 'cargo_company_id':
        return 'Kargo Şirketi';
      case 'sender_id':
      case 'local_id':
        return 'Gönderici Adresi';
      case 'receiver_id':
      case 'foreign_id':
        return 'Alıcı Adresi';
      default:
        return field;
    }
  }
}