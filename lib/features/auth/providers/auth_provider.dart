import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _secureStorage = FlutterSecureStorage();

// Riverpod'un en güncel yapısı olan Notifier kullanıyoruz
class AuthNotifier extends Notifier<String?> {
  
  @override
  String? build() {
    // Uygulama açıldığında hafızadaki token'ı okuma işlemini başlatır
    _loadTokenFromStorage();
    return null; // İlk anda token bilinmiyor
  }

  Future<void> _loadTokenFromStorage() async {
    final token = await _secureStorage.read(key: 'auth_token');
    state = token;
  }

  Future<void> setToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
    state = token;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
    state = null;
  }
}

// Global Provider Tanımlaması
final authProvider = NotifierProvider<AuthNotifier, String?>(() {
  return AuthNotifier();
});