import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: StocadoApp(),
    ),
  );
}

class StocadoApp extends ConsumerWidget {
  const StocadoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hafızadaki oturum durumunu reaktif olarak dinler
    final authState = ref.watch(authProvider);

    // İlk açılışta storage'dan token kontrolü sürerken yükleme ekranı göster
    if (!authState.isInitialized) {
      return MaterialApp(
        title: 'Stocado',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Stocado',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // State-Driven Routing: Token doğrulanmışsa MainScreen'e, değilse LoginScreen'e
      home: authState.isAuthenticated ? const MainScreen() : const LoginScreen(),
    );
  }
}