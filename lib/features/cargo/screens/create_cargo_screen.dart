import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/cargo_service.dart';

class CreateCargoScreen extends StatefulWidget {
  final String token;

  const CreateCargoScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<CreateCargoScreen> createState() => _CreateCargoScreenState();
}

class _CreateCargoScreenState extends State<CreateCargoScreen> {
  final CargoService _cargoService = CargoService();
  bool _isLoading = false;
  double _calculatedDesi = 0.0;

  // Form Kontrolcüleri
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  void _calculateDesi() {
    double width = double.tryParse(_widthController.text) ?? 0;
    double length = double.tryParse(_lengthController.text) ?? 0;
    double height = double.tryParse(_heightController.text) ?? 0;

    setState(() {
      _calculatedDesi = (width * length * height) / 3000;
    });
  }

  Future<void> _submitCargo() async {
    if (_nameController.text.trim().isEmpty || _calculatedDesi <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli ölçüler ve alıcı bilgisi girin.'), backgroundColor: AppColors.warning),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Ölçü Değerleri
    double width = double.tryParse(_widthController.text) ?? 0;
    double length = double.tryParse(_lengthController.text) ?? 0;
    double height = double.tryParse(_heightController.text) ?? 0;
    double weight = double.tryParse(_weightController.text) ?? 0;

    // API servisimizi yeni zorunlu parametrelerle çağırıyoruz
    final success = await _cargoService.createCargo(
      token: widget.token,
      recipientName: _nameController.text.trim(),
      recipientPhone: _phoneController.text.trim(),
      recipientAddressDetails: _addressController.text.trim().isEmpty ? "Açık adres girilmedi" : _addressController.text.trim(),
      cityId: 34, // TODO: GET locations/cities API'si ile Dropdown'dan alınacak
      districtId: 123, // TODO: GET locations/districts API'si ile Dropdown'dan alınacak
      desi: _calculatedDesi,
      width: width,
      length: length,
      height: height,
      weight: weight,
      cargoCompanyId: "ups", // TODO: Kargo firmaları listesinden seçilecek
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kargo Başarıyla Oluşturuldu!'), backgroundColor: AppColors.secondary),
      );
      // Formu temizle
      _nameController.clear();
      _phoneController.clear();
      _addressController.clear();
      _widthController.clear();
      _lengthController.clear();
      _heightController.clear();
      _weightController.clear();
      setState(() => _calculatedDesi = 0.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İşlem başarısız. Lütfen konsolu kontrol edin.'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _widthController.dispose();
    _lengthController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Kargo Oluştur')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alıcı Bilgileri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 16),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Ad Soyad')),
            const SizedBox(height: 12),
            TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefon')),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Açık Adres', hintText: 'Mahalle, Sokak, No, Daire'),
            ),
            
            const SizedBox(height: 32),
            const Text('Paket Ölçüleri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: TextField(controller: _widthController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'En (cm)'), onChanged: (_) => _calculateDesi())),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _lengthController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Boy (cm)'), onChanged: (_) => _calculateDesi())),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _heightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Yükseklik (cm)'), onChanged: (_) => _calculateDesi())),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: _weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ağırlık (Gram)', hintText: 'Örn: 1500')),
            
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primary)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Hesaplanan Desi:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  Text(_calculatedDesi.toStringAsFixed(2), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitCargo,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Kargo Oluştur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}