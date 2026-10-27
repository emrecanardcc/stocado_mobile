import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/location_model.dart';
import '../providers/create_cargo_provider.dart';
import '../services/location_service.dart';

class AddSenderAddressModal {
  static void show(
    BuildContext context,
    List<City> cities,
    CreateCargoNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddSenderAddressSheetContent(cities: cities, notifier: notifier),
    );
  }
}

class _AddSenderAddressSheetContent extends StatefulWidget {
  final List<City> cities;
  final CreateCargoNotifier notifier;

  const _AddSenderAddressSheetContent({
    required this.cities,
    required this.notifier,
  });

  @override
  State<_AddSenderAddressSheetContent> createState() => _AddSenderAddressSheetContentState();
}

class _AddSenderAddressSheetContentState extends State<_AddSenderAddressSheetContent> {
  final LocationService _locationService = LocationService();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _corpCtrl;
  late final TextEditingController _vknCtrl;
  late final TextEditingController _respNameCtrl;
  late final TextEditingController _respLastCtrl;
  late final TextEditingController _respTcknCtrl;
  late final TextEditingController _postalCtrl;
  late final TextEditingController _detailsCtrl;

  City? _modalCity;
  District? _modalDistrict;
  List<District> _modalDistricts = [];
  bool _isLoadingDistricts = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _corpCtrl = TextEditingController();
    _vknCtrl = TextEditingController();
    _respNameCtrl = TextEditingController();
    _respLastCtrl = TextEditingController();
    _respTcknCtrl = TextEditingController();
    _postalCtrl = TextEditingController();
    _detailsCtrl = TextEditingController();

    _modalCity = widget.cities.isNotEmpty ? widget.cities.first : null;
    if (_modalCity != null) {
      _loadDistrictsForCity(_modalCity!.id);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _corpCtrl.dispose();
    _vknCtrl.dispose();
    _respNameCtrl.dispose();
    _respLastCtrl.dispose();
    _respTcknCtrl.dispose();
    _postalCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDistrictsForCity(int cityId) async {
    setState(() {
      _isLoadingDistricts = true;
    });

    final dists = await _locationService.getDistricts(cityId);

    if (mounted) {
      setState(() {
        _modalDistricts = dists;
        _modalDistrict = dists.isNotEmpty ? dists.first : null;
        _isLoadingDistricts = false;
      });
    }
  }

  Future<void> _handleSave() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final vkn = _vknCtrl.text.trim();
    final tckn = _respTcknCtrl.text.trim();
    final details = _detailsCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen firma veya gönderici adını giriniz.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final phoneDigits = phone.replaceAll(RegExp(r'\D'), '');
    if (phoneDigits.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir telefon numarası (en az 10 hane) giriniz.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (vkn.isNotEmpty && vkn.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vergi Numarası (VKN) tam olarak 10 haneli olmalıdır.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (tckn.isNotEmpty && tckn.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yetkili TCKN tam olarak 11 haneli olmalıdır.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_modalCity == null || _modalDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen il ve ilçe seçimini yapınız.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (details.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen açık adres (cadde, sokak, no) bilgisini giriniz.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final messenger = ScaffoldMessenger.of(context);

    final result = await widget.notifier.createSenderAddress(
      title: _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : name,
      name: name,
      phone: phone,
      email: email.isNotEmpty ? email : null,
      corporateName: _corpCtrl.text.trim().isNotEmpty ? _corpCtrl.text.trim() : null,
      vkn: vkn.isNotEmpty ? vkn : null,
      responsiblePersonName: _respNameCtrl.text.trim().isNotEmpty ? _respNameCtrl.text.trim() : null,
      responsiblePersonLastname: _respLastCtrl.text.trim().isNotEmpty ? _respLastCtrl.text.trim() : null,
      responsiblePersonTckn: tckn.isNotEmpty ? tckn : null,
      postalCode: _postalCtrl.text.trim().isNotEmpty ? _postalCtrl.text.trim() : null,
      cityId: _modalCity!.id,
      districtId: _modalDistrict!.id,
      details: details,
    );

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      if (result.isSuccess) {
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Gönderici adresi başarıyla eklendi.'),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Adres eklenirken bir hata oluştu.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Yeni Gönderici Adresi Ekle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Adres Başlığı (Örn: Merkez Depo)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Firma / Gönderici Adı *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Telefon *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'E-Posta',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Firma & Vergi Bilgileri (İsteğe Bağlı)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _corpCtrl,
                    decoration: InputDecoration(
                      labelText: 'Şirket Resmi Unvanı',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _vknCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText: 'Vergi Kimlik Numarası (VKN - 10 Hane)',
                      counterText: '',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Yetkili Kişi Bilgileri (İsteğe Bağlı)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _respNameCtrl,
                          decoration: InputDecoration(
                            labelText: 'Yetkili Adı',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _respLastCtrl,
                          decoration: InputDecoration(
                            labelText: 'Yetkili Soyadı',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _respTcknCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 11,
                    decoration: InputDecoration(
                      labelText: 'Yetkili T.C. Kimlik No (11 Hane)',
                      counterText: '',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Adres Konumu *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<City>(
                          key: ValueKey(_modalCity?.id),
                          initialValue: _modalCity,
                          decoration: InputDecoration(
                            labelText: 'İl *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          menuMaxHeight: 220,
                          items: widget.cities.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                          onChanged: (newCity) {
                            if (newCity != null) {
                              setState(() {
                                _modalCity = newCity;
                                _modalDistrict = null;
                                _modalDistricts = [];
                              });
                              _loadDistrictsForCity(newCity.id);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _isLoadingDistricts
                            ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                            : DropdownButtonFormField<District>(
                                key: ValueKey(_modalDistrict?.id),
                                initialValue: _modalDistrict,
                                decoration: InputDecoration(
                                  labelText: 'İlçe *',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                menuMaxHeight: 220,
                                items: _modalDistricts.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
                                onChanged: (newDist) {
                                  setState(() {
                                    _modalDistrict = newDist;
                                  });
                                },
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _postalCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    decoration: InputDecoration(
                      labelText: 'Posta Kodu',
                      counterText: '',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _detailsCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Açık Adres (Cadde, Mahalle, Sokak, No, Daire) *',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _isSaving ? null : _handleSave,
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Adresi Kaydet ve Seç'),
            ),
          ),
        ],
      ),
    );
  }
}
