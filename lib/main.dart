import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
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

    // İlk açılışta storage'dan token kontrolü sürerken şık açılış ekranı göster
    if (!authState.isInitialized) {
      return MaterialApp(
        title: 'Stocado',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _SplashScreen(),
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

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.local_shipping_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Stocado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Güvenli Lojistik Altyapısı',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}