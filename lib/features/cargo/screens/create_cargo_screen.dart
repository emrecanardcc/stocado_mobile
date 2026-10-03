import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/cargo_service.dart';
import '../models/location_model.dart'; // Lokasyon modelimizi import ettik

class CreateCargoScreen extends StatefulWidget {
  // DİKKAT: Token parametresi tamamen silindi!
  const CreateCargoScreen({Key? key}) : super(key: key);

  @override
  State<CreateCargoScreen> createState() => _CreateCargoScreenState();
}

class _CreateCargoScreenState extends State<CreateCargoScreen> {
  final CargoService _cargoService = CargoService();
  bool _isLoading = false;
  bool _isLoadingLocations = true;
  double _calculatedDesi = 0.0;

  // Lokasyon Verileri
  List<Country> _countries = [];
  Country? _selectedCountry;
  City? _selectedCity;
  District? _selectedDistrict;

  // Form Kontrolcüleri
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  // API'den ülkeleri, şehirleri ve ilçeleri çeker
  Future<void> _fetchLocations() async {
    // DİKKAT: Artık parametre olarak token göndermiyoruz, ApiClient hallediyor!
    final countries = await _cargoService.getCountries();
    if (mounted) {
      setState(() {
        _countries = countries;
        _isLoadingLocations = false;
      });
    }
  }

  void _calculateDesi() {
    double width = double.tryParse(_widthController.text) ?? 0;
    double length = double.tryParse(_lengthController.text) ?? 0;
    double height = double.tryParse(_heightController.text) ?? 0;

    setState(() {
      _calculatedDesi = (width * length * height) / 3000;
    });
  }

  Future<void> _submitCargo() async {
    // Şehir ve ilçe seçimi de kontrol ediliyor
    if (_nameController.text.trim().isEmpty || _calculatedDesi <= 0 || _selectedCity == null || _selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen il/ilçe dahil tüm zorunlu alanları doldurun.'), backgroundColor: AppColors.warning),
      );
      return;
    }

    setState(() => _isLoading = true);

    double width = double.tryParse(_widthController.text) ?? 0;
    double length = double.tryParse(_lengthController.text) ?? 0;
    double height = double.tryParse(_heightController.text) ?? 0;
    double weight = double.tryParse(_weightController.text) ?? 0;

    // DİKKAT: token: widget.token satırı silindi!
    final success = await _cargoService.createCargo(
      recipientName: _nameController.text.trim(),
      recipientPhone: _phoneController.text.trim(),
      recipientAddressDetails: _addressController.text.trim().isEmpty ? "Açık adres girilmedi" : _addressController.text.trim(),
      cityId: _selectedCity!.id,         // Statik 34 yerine dinamik ID
      districtId: _selectedDistrict!.id, // Statik 123 yerine dinamik ID
      desi: _calculatedDesi,
      width: width,
      length: length,
      height: height,
      weight: weight,
      cargoCompanyId: "ups",
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
      setState(() {
        _calculatedDesi = 0.0;
        _selectedCountry = null;
        _selectedCity = null;
        _selectedDistrict = null;
      });
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
      body: _isLoadingLocations 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
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
            
            // Dinamik Ülke Seçimi
            DropdownButtonFormField<Country>(
              decoration: const InputDecoration(labelText: 'Ülke'),
              value: _selectedCountry,
              items: _countries.map((country) => DropdownMenuItem(value: country, child: Text(country.name))).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                  _selectedCity = null;     
                  _selectedDistrict = null;
                });
              },
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                // Dinamik İl Seçimi
                Expanded(
                  child: DropdownButtonFormField<City>(
                    decoration: const InputDecoration(labelText: 'İl'),
                    value: _selectedCity,
                    items: _selectedCountry?.cities.map((city) => DropdownMenuItem(value: city, child: Text(city.name))).toList() ?? [],
                    onChanged: _selectedCountry == null ? null : (value) {
                      setState(() {
                        _selectedCity = value;
                        _selectedDistrict = null; 
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Dinamik İlçe Seçimi
                Expanded(
                  child: DropdownButtonFormField<District>(
                    decoration: const InputDecoration(labelText: 'İlçe'),
                    value: _selectedDistrict,
                    items: _selectedCity?.districts.map((district) => DropdownMenuItem(value: district, child: Text(district.name))).toList() ?? [],
                    onChanged: _selectedCity == null ? null : (value) {
                      setState(() {
                        _selectedDistrict = value;
                      });
                    },
                  ),
                ),
              ],
            ),
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