import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  // API bağlanana kadar görünümü test etmek için örnek ürün listesi
  final List<Map<String, dynamic>> _mockProducts = const [
    {
      "name": "Siyah T-Shirt (Erkek - M)",
      "sku": "TSH-BLK-M-01",
      "stock": 145,
      "price": "299,90 ₺",
      "desi": 0.5,
      "image": Icons.checkroom
    },
    {
      "name": "Kablosuz Kulaklık V2",
      "sku": "ELK-KUL-V2",
      "stock": 32,
      "price": "1.499,00 ₺",
      "desi": 1.2,
      "image": Icons.headphones
    },
    {
      "name": "Spor Su Matarası 750ml",
      "sku": "SPR-MAT-750",
      "stock": 0, // Stokta olmayan ürün senaryosu
      "price": "149,50 ₺",
      "desi": 0.8,
      "image": Icons.local_drink
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürünlerim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {}, // TODO: Ürünlerde arama
          ),
        ],
      ),
      // Yeni ürün ekleme butonu (Sağ altta havada duran buton)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Yeni ürün ekleme formu (Bottom Sheet veya Dialog) açılacak
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Yeni Ürün', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _mockProducts.length,
        itemBuilder: (context, index) {
          final product = _mockProducts[index];
          final isOutOfStock = product['stock'] == 0;

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(product['image'] as IconData, color: AppColors.primary),
              ),
              title: Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text('Stok Kodu: ${product['sku']}'),
                  const SizedBox(height: 2),
                  Text('Desi: ${product['desi']}  •  Fiyat: ${product['price']}'),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Stok', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOutOfStock ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product['stock'].toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isOutOfStock ? Colors.red : Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                // TODO: Ürün detayı veya düzenleme sayfası açılacak
              },
            ),
          );
        },
      ),
    );
  }
}