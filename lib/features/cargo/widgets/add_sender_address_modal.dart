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
    final locationService = LocationService();
    final titleCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final corpCtrl = TextEditingController();
    final vknCtrl = TextEditingController();
    final respNameCtrl = TextEditingController();
    final respLastCtrl = TextEditingController();
    final respTcknCtrl = TextEditingController();
    final postalCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();
    City? modalCity = cities.isNotEmpty ? cities.first : null;
    District? modalDistrict;
    List<District> modalDistricts = [];
    bool isLoadingDistricts = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            if (modalCity != null && modalDistricts.isEmpty && !isLoadingDistricts) {
              isLoadingDistricts = true;
              locationService.getDistricts(modalCity!.id).then((dists) {
                if (modalCtx.mounted) {
                  setModalState(() {
                    modalDistricts = dists;
                    modalDistrict = dists.isNotEmpty ? dists.first : null;
                    isLoadingDistricts = false;
                  });
                }
              });
            }

            return Container(
              height: MediaQuery.of(modalCtx).size.height * 0.88,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 16,
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
                        onPressed: () => Navigator.pop(modalCtx),
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
                            controller: titleCtrl,
                            decoration: InputDecoration(
                              labelText: 'Adres Başlığı (Örn: Merkez Depo)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: nameCtrl,
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
                                  controller: phoneCtrl,
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
                                  controller: emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'E-Posta',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: corpCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'Şirket Ünvanı',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: vknCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Vergi No (VKN)',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: respNameCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'Yetkili Adı',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: respLastCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'Yetkili Soyadı',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: respTcknCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Yetkili TCKN',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: postalCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Posta Kodu',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'İl *',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<City>(
                                      isExpanded: true,
                                      isDense: true,
                                      value: cities.contains(modalCity) ? modalCity : null,
                                      items: cities.map((city) {
                                        return DropdownMenuItem<City>(
                                          value: city,
                                          child: Text(city.name, overflow: TextOverflow.ellipsis),
                                        );
                                      }).toList(),
                                      onChanged: (city) async {
                                        if (city == null) return;
                                        setModalState(() {
                                          modalCity = city;
                                          modalDistrict = null;
                                          modalDistricts = [];
                                          isLoadingDistricts = true;
                                        });
                                        final dists = await locationService.getDistricts(city.id);
                                        if (modalCtx.mounted) {
                                          setModalState(() {
                                            modalDistricts = dists;
                                            modalDistrict = dists.isNotEmpty ? dists.first : null;
                                            isLoadingDistricts = false;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: isLoadingDistricts ? 'İlçe yükleniyor...' : 'İlçe *',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    suffixIcon: isLoadingDistricts
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: Padding(
                                              padding: EdgeInsets.all(12),
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<District>(
                                      isExpanded: true,
                                      isDense: true,
                                      value: modalDistricts.contains(modalDistrict) ? modalDistrict : null,
                                      items: modalDistricts.map((district) {
                                        return DropdownMenuItem<District>(
                                          value: district,
                                          child: Text(district.name, overflow: TextOverflow.ellipsis),
                                        );
                                      }).toList(),
                                      onChanged: (dist) {
                                        setModalState(() {
                                          modalDistrict = dist;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: detailsCtrl,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Açık Adres (Mahalle, Cadde, No...) *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameCtrl.text.trim().isEmpty ||
                            phoneCtrl.text.trim().isEmpty ||
                            detailsCtrl.text.trim().isEmpty ||
                            modalCity == null ||
                            modalDistrict == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lütfen Gönderici Adı, Telefon, İl, İlçe ve Açık Adres alanlarını doldurunuz.'),
                              backgroundColor: AppColors.warning,
                            ),
                          );
                          return;
                        }

                        final result = await notifier.createSenderAddress(
                          title: titleCtrl.text.trim(),
                          name: nameCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                          corporateName: corpCtrl.text.trim().isNotEmpty ? corpCtrl.text.trim() : null,
                          vkn: vknCtrl.text.trim().isNotEmpty ? vknCtrl.text.trim() : null,
                          responsiblePersonName: respNameCtrl.text.trim().isNotEmpty ? respNameCtrl.text.trim() : null,
                          responsiblePersonLastname: respLastCtrl.text.trim().isNotEmpty ? respLastCtrl.text.trim() : null,
                          responsiblePersonTckn: respTcknCtrl.text.trim().isNotEmpty ? respTcknCtrl.text.trim() : null,
                          postalCode: postalCtrl.text.trim().isNotEmpty ? postalCtrl.text.trim() : null,
                          cityId: modalCity!.id,
                          districtId: modalDistrict!.id,
                          details: detailsCtrl.text.trim(),
                        );

                        if (result.isSuccess) {
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.message ?? 'Gönderici adresi başarıyla eklendi.'),
                                backgroundColor: AppColors.secondary,
                              ),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.message ?? 'Adres eklenirken bir hata oluştu.'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Adresi Kaydet ve Seç'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
