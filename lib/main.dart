import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/cargo/screens/create_cargo_screen.dart';
import 'features/home/screens/main_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: StocadoApp(),
    ),
  );
}

// State'leri dinleyebilmek için ConsumerWidget kullanıyoruz
class StocadoApp extends ConsumerWidget {
  const StocadoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hafızadaki token durumunu anlık olarak dinler
    final token = ref.watch(authProvider);

    return MaterialApp(
      title: 'Stocado',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
      ),
      // MANTIK ŞU: Token hala yükleniyorsa (null değilse ama boşsa vs.) veya yoksa Login'e at,
      // Token varsa direkt Kargo (ileride Dashboard) ekranına at.
      home: token == null ? const LoginScreen() : const MainScreen(),
    );
  }
}