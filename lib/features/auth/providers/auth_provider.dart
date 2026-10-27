import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthState {
  final String? token;
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isInitialized;

  const AuthState({
    this.token,
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isInitialized = false,
  });

  bool get isAuthenticated => token != null && token!.isNotEmpty;
  String? get accountId => user?.accountId;

  AuthState copyWith({
    String? token,
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool? isInitialized,
    bool clearToken = false,
    bool clearUser = false,
  }) {
    return AuthState(
      token: clearToken ? null : (token ?? this.token),
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  static const String userCacheKey = "cached_user_profile";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final AuthService _authService;

  @override
  AuthState build() {
    _authService = AuthService();
    
    // Global 401 hatası yakalandığında otomatik logout tetikle
    ApiClient.onUnauthorized = () {
      logout();
    };

    // Uygulama açılışında kayıtlı oturumu doğrula
    Future.microtask(() => _initializeAuth());

    return const AuthState();
  }

  /// Açılışta Secure Storage'dan token okur ve kullanıcı bilgilerini doğrular
  Future<void> _initializeAuth() async {
    try {
      final token = await _storage.read(key: ApiClient.tokenKey);
      if (token != null && token.isNotEmpty) {
        UserModel? cachedUser;
        final cachedUserJson = await _storage.read(key: userCacheKey);
        if (cachedUserJson != null && cachedUserJson.isNotEmpty) {
          try {
            cachedUser = UserModel.fromJson(jsonDecode(cachedUserJson));
          } catch (_) {}
        }

        // Önbellekteki oturum bilgisiyle hemen aktif et
        state = state.copyWith(
          token: token,
          user: cachedUser,
          isLoading: true,
        );

        final user = await _authService.getMe().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            debugPrint('Oturum doğrulama zaman aşımı (3s) - Çevrimdışı modda devam ediliyor');
            return null;
          },
        );
        if (user != null) {
          try {
            await _storage.write(key: userCacheKey, value: jsonEncode(user.toJson()));
          } catch (_) {}

          state = state.copyWith(
            token: token,
            user: user,
            isLoading: false,
            isInitialized: true,
          );
          return;
        } else {
          // Ağ hatası veya sunucu yanıt vermeme durumunda kullanıcının token'ı SİLİNMEZ!
          // Önbellekteki kullanıcı ile oturum korunur.
          // Token yalnızca 401 Unauthorized durumunda ApiClient.onUnauthorized ile silinir.
          state = state.copyWith(
            token: token,
            user: cachedUser,
            isLoading: false,
            isInitialized: true,
          );
          return;
        }
      }
    } catch (e) {
      debugPrint('Oturum doğrulama hatası: $e');
    }

    state = const AuthState(isInitialized: true);
  }

  /// Giriş Yapma İşlemi
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _authService.login(email, password);

    if (result.isSuccess && result.token != null) {
      await _storage.write(key: ApiClient.tokenKey, value: result.token!);

      // Giriş yapan kullanıcının hesap detaylarını (/auth/me) anında çek
      final user = await _authService.getMe();
      if (user != null) {
        try {
          await _storage.write(key: userCacheKey, value: jsonEncode(user.toJson()));
        } catch (_) {}
      }

      state = state.copyWith(
        token: result.token,
        user: user,
        isLoading: false,
        isInitialized: true,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.errorMessage ?? 'Giriş başarısız.',
      );
      return false;
    }
  }

  /// Manuel Token Atama (Örn. mock veya test için)
  Future<void> setToken(String token) async {
    await _storage.write(key: ApiClient.tokenKey, value: token);
    state = state.copyWith(token: token, isLoading: true);
    final user = await _authService.getMe();
    if (user != null) {
      try {
        await _storage.write(key: userCacheKey, value: jsonEncode(user.toJson()));
      } catch (_) {}
    }
    state = state.copyWith(token: token, user: user, isLoading: false, isInitialized: true);
  }

  /// Çıkış Yapma İşlemi
  Future<void> logout() async {
    await _storage.delete(key: ApiClient.tokenKey);
    await _storage.delete(key: userCacheKey);
    state = const AuthState(isInitialized: true);
  }
}

// Global Provider Tanımlaması (Riverpod 3.0 NotifierProvider)
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});