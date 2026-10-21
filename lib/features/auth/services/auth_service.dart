import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../models/user_model.dart';

class LoginResult {
  final bool isSuccess;
  final String? token;
  final String? errorMessage;

  LoginResult({required this.isSuccess, this.token, this.errorMessage});
}

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// POST /auth/login
  Future<LoginResult> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final token = data['token'] as String?;
        if (token != null && token.isNotEmpty) {
          return LoginResult(isSuccess: true, token: token);
        }
        return LoginResult(isSuccess: false, errorMessage: 'Sunucudan yetkilendirme anahtarı alınamadı.');
      } else {
        final errorMsg = ApiClient.parseError(
          response,
          defaultMessage: response.statusCode == 401
              ? 'E-posta adresi veya şifre hatalı.'
              : 'Giriş yapılamadı. Lütfen bilgilerinizi kontrol ediniz.',
        );
        return LoginResult(isSuccess: false, errorMessage: errorMsg);
      }
    } catch (e) {
      debugPrint('AuthService.login hatası: $e');
      return LoginResult(
        isSuccess: false,
        errorMessage: ApiClient.parseError(e, defaultMessage: 'Ağ bağlantısı kurulamadı. Lütfen internetinizi kontrol edin.'),
      );
    }
  }

  /// GET /auth/me & GET /users/{userId}/accounts
  Future<UserModel?> getMe() async {
    try {
      final response = await _apiClient.get('/auth/me');
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final userId = data['id']?.toString() ?? '';

        List<AccountModel> accounts = [];
        if (userId.isNotEmpty) {
          try {
            final accResponse = await _apiClient.get('/users/$userId/accounts');
            if (accResponse.statusCode == 200) {
              final accData = jsonDecode(utf8.decode(accResponse.bodyBytes));
              if (accData is List) {
                accounts = accData
                    .map((item) => AccountModel.fromJson(item as Map<String, dynamic>))
                    .toList();
              } else if (accData is Map<String, dynamic>) {
                if (accData['data'] is List) {
                  accounts = (accData['data'] as List)
                      .map((item) => AccountModel.fromJson(item as Map<String, dynamic>))
                      .toList();
                } else if (accData['id'] != null) {
                  accounts = [AccountModel.fromJson(accData)];
                }
              }
            }
          } catch (e) {
            debugPrint('Kullanıcı hesapları çekilirken hata: $e');
          }
        }

        return UserModel.fromJson(data, accountsList: accounts);
      } else {
        debugPrint('AuthService.getMe başarısız: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('AuthService.getMe hatası: $e');
      return null;
    }
  }
}