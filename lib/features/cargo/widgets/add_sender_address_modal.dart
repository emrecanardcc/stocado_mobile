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
                                      menuMaxHeight: 220,
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
                                      menuMaxHeight: 220,
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
                        final name = nameCtrl.text.trim();
                        final phone = phoneCtrl.text.trim();
                        final phoneDigits = phone.replaceAll(RegExp(r'\D'), '');
                        final email = emailCtrl.text.trim();
                        final details = detailsCtrl.text.trim();
                        final vkn = vknCtrl.text.trim();
                        final tckn = respTcknCtrl.text.trim();

                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lütfen Firma / Gönderici Adı alanını doldurunuz.'),
                              backgroundColor: AppColors.warning,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        if (phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lütfen telefon numarasını giriniz.'),
                              backgroundColor: AppColors.warning,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        if (phoneDigits.length < 10) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lütfen en az 10 haneli geçerli bir telefon numarası giriniz.'),
                              backgroundColor: AppColors.warning,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        if (email.isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lütfen geçerli bir e-posta adresi giriniz.'),
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

                        if (modalCity == null || modalDistrict == null) {
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

                        final result = await notifier.createSenderAddress(
                          title: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : name,
                          name: name,
                          phone: phone,
                          email: email.isNotEmpty ? email : null,
                          corporateName: corpCtrl.text.trim().isNotEmpty ? corpCtrl.text.trim() : null,
                          vkn: vkn.isNotEmpty ? vkn : null,
                          responsiblePersonName: respNameCtrl.text.trim().isNotEmpty ? respNameCtrl.text.trim() : null,
                          responsiblePersonLastname: respLastCtrl.text.trim().isNotEmpty ? respLastCtrl.text.trim() : null,
                          responsiblePersonTckn: tckn.isNotEmpty ? tckn : null,
                          postalCode: postalCtrl.text.trim().isNotEmpty ? postalCtrl.text.trim() : null,
                          cityId: modalCity!.id,
                          districtId: modalDistrict!.id,
                          details: details,
                        );

                        if (result.isSuccess) {
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.message ?? 'Gönderici adresi başarıyla eklendi.'),
                                backgroundColor: AppColors.secondary,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.message ?? 'Adres eklenirken bir hata oluştu.'),
                                backgroundColor: AppColors.error,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 4),
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
