import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/address_model.dart';
import '../models/location_model.dart';
import '../providers/create_cargo_provider.dart';
import 'add_sender_address_modal.dart';

class Step1AddressesWidget extends StatelessWidget {
  final CreateCargoState state;
  final CreateCargoNotifier notifier;
  final List<City> cities;
  final List<District> districts;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController postalCodeController;

  const Step1AddressesWidget({
    super.key,
    required this.state,
    required this.notifier,
    required this.cities,
    required this.districts,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.postalCodeController,
  });

  @override
  Widget build(BuildContext context) {
    final isReverse = state.direction == 'receive';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Yönlendirme Seçimi (Kargo Gönder vs Kargo Bana Gelsin)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Kargo Gönder')),
                  selected: state.direction == 'send',
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  onSelected: (val) {
                    if (val) notifier.setDirection('send');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Kargo Bana Gelsin')),
                  selected: state.direction == 'receive',
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  onSelected: (val) {
                    if (val) notifier.setDirection('receive');
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (isReverse)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.blue),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tersine Lojistik: Kargo müşteriden alınarak sizin seçtiğiniz şirket/depo adresinize teslim edilecektir.',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),

        // 1. KUTU: Kendi Şirket/Depo Adresiniz (Gönderici)
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isReverse ? 'Teslim Alacak Adresiniz (Şirketiniz)' : 'Gönderici Adresi (Kendi Adresiniz)',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => AddSenderAddressModal.show(context, cities, notifier),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Yeni Adres', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (state.isLoadingAddresses)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: LinearProgressIndicator(),
                  )
                else if (state.senderAddresses.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Kayıtlı gönderici adresi bulunamadı. Lütfen "Yeni Adres" butonuna dokunarak adres ekleyin.',
                            style: TextStyle(fontSize: 12, color: Colors.brown),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<AddressModel>(
                    key: ValueKey(state.selectedSenderAddress?.id),
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: isReverse ? 'Varış Deponuzu Seçin' : 'Kayıtlı Gönderici Adresini Seçin *',
                      prefixIcon: const Icon(Icons.warehouse_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    initialValue: state.senderAddresses.contains(state.selectedSenderAddress)
                        ? state.selectedSenderAddress
                        : null,
                    items: state.senderAddresses.map((addr) {
                      return DropdownMenuItem<AddressModel>(
                        value: addr,
                        child: Text(
                          addr.displayName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => notifier.setSenderAddress(val),
                  ),

                if (state.selectedSenderAddress != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${state.selectedSenderAddress!.name} · ${state.selectedSenderAddress!.phone}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        if (state.selectedSenderAddress!.details.isNotEmpty)
                          Text(
                            state.selectedSenderAddress!.details,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // 2. KUTU: Alıcı / Müşteri Bilgileri
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isReverse ? 'Gönderici Müşteri Bilgileri' : 'Alıcı Bilgileri',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 12),

                // Kayıtlı Alıcı Seç vs Yeni Alıcı Girişi
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      label: Text('Kayıtlı Alıcı Seç'),
                      icon: Icon(Icons.people_outline, size: 16),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text('Yeni Alıcı Girişi'),
                      icon: Icon(Icons.person_add_outlined, size: 16),
                    ),
                  ],
                  selected: {state.isManualRecipient},
                  onSelectionChanged: (val) {
                    final manual = val.first;
                    notifier.toggleManualRecipient(manual);
                    if (!manual && state.selectedRecipientAddress != null) {
                      nameController.text = state.selectedRecipientAddress!.name;
                      phoneController.text = state.selectedRecipientAddress!.phone;
                      addressController.text = state.selectedRecipientAddress!.details;
                      emailController.text = state.selectedRecipientAddress!.email ?? '';
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Kayıtlı Alıcı Seçim Alanı
                if (!state.isManualRecipient) ...[
                  if (state.recipientAddresses.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Henüz kayıtlı alıcı bulunamadı. "Yeni Alıcı Girişi" sekmesini kullanarak yeni alıcı bilgisi girebilirsiniz.',
                              style: TextStyle(fontSize: 12, color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<AddressModel>(
                      key: ValueKey(state.selectedRecipientAddress?.id),
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Kayıtlı Alıcı Seçin',
                        prefixIcon: const Icon(Icons.person_search_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      initialValue: state.recipientAddresses.contains(state.selectedRecipientAddress)
                          ? state.selectedRecipientAddress
                          : null,
                      items: state.recipientAddresses.map((addr) {
                        return DropdownMenuItem<AddressModel>(
                          value: addr,
                          child: Text(
                            '${addr.name} - ${addr.phone}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (addr) {
                        notifier.selectRecipientAddress(addr);
                        if (addr != null) {
                          nameController.text = addr.name;
                          phoneController.text = addr.phone;
                          addressController.text = addr.details;
                          emailController.text = addr.email ?? '';
                          postalCodeController.text = addr.postalCode ?? '';
                        }
                      },
                    ),
                  const SizedBox(height: 12),
                ],

                // Manuel Form Girişleri (Yeni Alıcı veya Seçili Alıcı Düzenleme)
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: isReverse ? 'Gönderici Ad Soyad *' : 'Alıcı Ad Soyad *',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) => notifier.updateRecipientInfo(name: val),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Telefon Numarası *',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) => notifier.updateRecipientInfo(phone: val),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-Posta Adresi (Opsiyonel)',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) => notifier.updateRecipientInfo(email: val),
                ),
                const SizedBox(height: 12),

                // İl & İlçe Seçimi (Canlı Lokasyon Veritabanı)
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<City>(
                        decoration: InputDecoration(
                          labelText: 'İl *',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        isExpanded: true,
                        initialValue: cities.any((c) => c.id == state.selectedCity?.id)
                            ? cities.firstWhere((c) => c.id == state.selectedCity?.id)
                            : null,
                        hint: const Text('İl Seçiniz', style: TextStyle(fontSize: 13)),
                        items: cities.map((city) {
                          return DropdownMenuItem<City>(
                            value: city,
                            child: Text(city.name, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (city) => notifier.selectCity(city),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<District>(
                        decoration: InputDecoration(
                          labelText: state.isLoadingDistricts ? 'İlçe yükleniyor...' : 'İlçe *',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          suffixIcon: state.isLoadingDistricts
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
                        isExpanded: true,
                        initialValue: districts.any((d) => d.id == state.selectedDistrict?.id)
                            ? districts.firstWhere((d) => d.id == state.selectedDistrict?.id)
                            : null,
                        hint: const Text('İlçe Seçiniz', style: TextStyle(fontSize: 13)),
                        items: districts.map((district) {
                          return DropdownMenuItem<District>(
                            value: district,
                            child: Text(district.name, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: state.selectedCity == null
                            ? null
                            : (dist) => notifier.selectDistrict(dist),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Açık Adres (Mahalle, Cadde, No...) *',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) => notifier.updateRecipientInfo(details: val),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
