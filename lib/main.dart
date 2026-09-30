import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';

void main() {
  runApp(const StocadoApp());
}

class StocadoApp extends StatelessWidget {
  const StocadoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stocado',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, 
      home: const LoginScreen(), // Başlangıç ekranımızı Login yaptık
    );
  }
}