import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CargosScreen extends StatefulWidget {
  const CargosScreen({Key? key}) : super(key: key);

  @override
  State<CargosScreen> createState() => _CargosScreenState();
}

class _CargosScreenState extends State<CargosScreen> {
  // API bağlanana kadar görseldeki verilere benzeyen örnek liste
  final List<Map<String, dynamic>> _mockCargos = [
    {
      "receiver": "Durmuş İngenç",
      "phone": "5393222707",
      "ref_barcode": "5998596498319",
      "company": "PTT Kargo",
      "last_movement": "Yönetici İptal",
      "status": "İptal Edildi",
      "date": "03.10.2026 10:43",
      "desi": "1,00",
      "price": "0,00 ₺",
      "is_active": false,
    },
    {
      "receiver": "Emirhan Güngör",
      "phone": "5321534325",
      "ref_barcode": "5051651530570",
      "company": "PTT Kargo",
      "last_movement": "Gönderime Hazır",
      "status": "Aktif",
      "date": "01.10.2026 00:09",
      "desi": "2,00",
      "price": "123,61 ₺",
      "is_active": true,
    },
    {
      "receiver": "Adorel Lojistik",
      "phone": "5321534325",
      "ref_barcode": "4845555565865",
      "company": "Sürat Kargo",
      "last_movement": "Gönderime Hazır",
      "status": "Aktif",
      "date": "29.09.2026 16:29",
      "desi": "0,00",
      "price": "116,81 ₺",
      "is_active": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kargolarım'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Tümü'),
              Tab(text: 'Kapıda Ödemeli'),
              Tab(text: 'Taslaklar'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {}, // TODO: Arama modülü eklenecek
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {}, // TODO: Filtreleme modülü eklenecek
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildCargoList(),
            const Center(child: Text('Kapıda Ödemeli Kargolar (Yakında)')),
            const Center(child: Text('Taslaklar (Yakında)')),
          ],
        ),
      ),
    );
  }

  Widget _buildCargoList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _mockCargos.length,
      itemBuilder: (context, index) {
        final cargo = _mockCargos[index];
        final isActive = cargo['is_active'] as bool;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Satır: Alıcı ve Durum Rozeti
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: isActive ? Colors.green.shade100 : Colors.red.shade100,
                            child: Text(
                              cargo['receiver'].substring(0, 2).toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.green.shade800 : Colors.red.shade800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cargo['receiver'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.blue.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        cargo['status'],
                        style: TextStyle(
                          color: isActive ? Colors.blue.shade800 : Colors.red.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                
                // 2. Satır: Barkod ve Tarih
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Referans Barkod', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text(cargo['ref_barcode'], style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Oluşturma Tarihi', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text(cargo['date'], style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. Satır: Firma ve Son Hareket
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_shipping, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(cargo['company'], style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        cargo['last_movement'],
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 4. Satır: Desi ve Ücret
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Desi: ${cargo['desi']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text(cargo['price'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}