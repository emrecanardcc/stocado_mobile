import 'package:flutter/material.dart';

class AppColors {
  // Ana Renkler (Paneldeki koyu lacivert/mavi ve yeşil tonları)
  static const Color primary = Color(0xFF1E3A8A); // Kurumsal Mavi
  static const Color secondary = Color(0xFF10B981); // Onay/Başarı Yeşili
  
  // Arka Plan ve Yüzey Renkleri
  static const Color background = Color(0xFFF3F4F6); // Uygulama geneli açık gri arka plan
  static const Color surface = Colors.white; // Kart ve form arka planları
  
  // Metin Renkleri
  static const Color textPrimary = Color(0xFF111827); // Koyu gri (Başlıklar)
  static const Color textSecondary = Color(0xFF6B7280); // Açık gri (Alt başlıklar ve etiketler)
  
  // Durum Renkleri (Border ve Hata)
  static const Color border = Color(0xFFE5E7EB); // İnce kenarlık rengi
  static const Color error = Color(0xFFEF4444); // Hata/İptal kırmızı
  static const Color warning = Color(0xFFF59E0B); // Bekleyen işlem turuncu
}