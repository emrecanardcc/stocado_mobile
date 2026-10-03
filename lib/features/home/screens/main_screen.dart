import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../cargo/screens/create_cargo_screen.dart';
import 'dashboard_screen.dart';
import '../../cargo/screens/cargos_screen.dart';
import '../../products/screens/products_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Alt menüdeki sayfaların listesi
  // Yukarıdaki import satırlarına bunu ekle:


// _screens listesini şu şekilde güncelle:
 final List<Widget> _screens = [
    const DashboardScreen(),
    const CreateCargoScreen(),
    const CargosScreen(),
    const ProductsScreen(), // <-- Eklenen kısım
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Özet'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), activeIcon: Icon(Icons.add_box), label: 'Yeni Kargo'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), activeIcon: Icon(Icons.local_shipping), label: 'Kargolar'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Ürünler'),
        ],
      ),
    );
  }
}