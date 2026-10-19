import 'package:flutter/material.dart';

class AppColors {
  // Kurumsal Stocado Ana Renkleri (Lacivert & Yıldız Kırmızısı)
  static const Color primary = Color(0xFF16325B); // Stocado Laciverti
  static const Color primaryLight = Color(0xFF22487A);
  static const Color primaryDark = Color(0xFF0F223D);
  
  static const Color accent = Color(0xFFE53935); // Stocado Yıldız Kırmızısı
  static const Color accentLight = Color(0xFFFEE2E2);

  // Durum Renkleri (Web Paneli ile Uyumlu)
  static const Color secondary = Color(0xFF10B981); // Teslim Edildi / Başarı Yeşili
  static const Color secondaryLight = Color(0xFFD1FAE5);
  
  static const Color warning = Color(0xFFF59E0B); // Bekleyen Paketler / Uyarı Turuncusu
  static const Color warningLight = Color(0xFFFEF3C7);
  
  static const Color info = Color(0xFF3B82F6); // Yolda Olan Paketler / Bilgi Mavisi
  static const Color infoLight = Color(0xFFDBEAFE);
  
  static const Color error = Color(0xFFEF4444); // Sorunlu Paketler / Hata Kırmızısı
  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color returned = Color(0xFFEA580C); // Geri Dönen Paketler Turuncusu
  static const Color returnedLight = Color(0xFFFFEDD5);

  // Arka Plan ve Yüzey Renkleri (Modern SaaS Slate Teması)
  static const Color background = Color(0xFFF8FAFC); // Slate-50 temiz sayfa zemini
  static const Color surface = Colors.white; // Saf beyaz kart ve panel zemini
  static const Color surfaceSecondary = Color(0xFFF1F5F9); // Slate-100 pasif alanlar
  
  // Kenarlık ve Ayırıcılar
  static const Color border = Color(0xFFE2E8F0); // Slate-200 zarif kenarlık
  static const Color borderLight = Color(0xFFF1F5F9);

  // Metin Renkleri
  static const Color textPrimary = Color(0xFF0F172A); // Slate-900 yüksek okunabilirlik
  static const Color textSecondary = Color(0xFF64748B); // Slate-500 açıklama ve alt başlıklar
  static const Color textMuted = Color(0xFF94A3B8); // Slate-400 placeholder & devre dışı

  // Modern Gölgeler
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x060F172A),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}