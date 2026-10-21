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

  Widget _buildDirectionOption({
    required bool isSelected,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? AppColors.softShadow : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            color: AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _buildDirectionOption(
                isSelected: state.direction == 'send',
                label: 'Kargo Gönder',
                icon: Icons.outbox_rounded,
                onTap: () => notifier.setDirection('send'),
              ),
              _buildDirectionOption(
                isSelected: state.direction == 'receive',
                label: 'Kargo Bana Gelsin',
                icon: Icons.move_to_inbox_rounded,
                onTap: () => notifier.setDirection('receive'),
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
              color: AppColors.infoLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 20, color: AppColors.info),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tersine Lojistik: Kargo müşteriden alınarak sizin kayıtlı depo adresinize getirilecektir.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

        // 1. KUTU: Kendi Şirket/Depo Adresiniz (Gönderici)
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isReverse ? 'Teslim Alacak Adresiniz' : 'Gönderici Adresi (Kendi Adresiniz)',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => AddSenderAddressModal.show(context, cities, notifier),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Yeni Adres', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
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
                  child: LinearProgressIndicator(color: AppColors.primary),
                )
              else if (state.senderAddresses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kayıtlı gönderici adresi bulunamadı. Lütfen "Yeni Adres" butonuna dokunarak ekleyin.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
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
                    prefixIcon: const Icon(Icons.warehouse_outlined, size: 20),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${state.selectedSenderAddress!.name} • ${state.selectedSenderAddress!.phone}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                      ),
                      if (state.selectedSenderAddress!.details.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          state.selectedSenderAddress!.details,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. KUTU: Alıcı / Müşteri Bilgileri
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isReverse ? 'Gönderici Müşteri Bilgileri' : 'Alıcı Bilgileri',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              // Kayıtlı Alıcı Seç vs Yeni Alıcı Girişi
              SegmentedButton<bool>(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                ),
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
                      color: AppColors.infoLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: AppColors.info, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Henüz kayıtlı alıcı bulunamadı. "Yeni Alıcı Girişi" sekmesini kullanarak yeni alıcı bilgisi girebilirsiniz.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<AddressModel>(
                    key: ValueKey(state.selectedRecipientAddress?.id),
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Kayıtlı Alıcı Seçin',
                      prefixIcon: Icon(Icons.person_search_outlined, size: 20),
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

              // Manuel Form Girişleri
              TextField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: isReverse ? 'Gönderici Ad Soyad *' : 'Alıcı Ad Soyad *',
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                ),
                onChanged: (val) => notifier.updateRecipientInfo(name: val),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Telefon Numarası *',
                  prefixIcon: Icon(Icons.phone_outlined, size: 20),
                ),
                onChanged: (val) => notifier.updateRecipientInfo(phone: val),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'E-Posta Adresi (Opsiyonel)',
                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                ),
                onChanged: (val) => notifier.updateRecipientInfo(email: val),
              ),
              const SizedBox(height: 12),

              // İl & İlçe Seçimi (Canlı Lokasyon Veritabanı)
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<City>(
                      key: ValueKey('city_${state.selectedCity?.id}'),
                      decoration: const InputDecoration(
                        labelText: 'İl *',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                      key: ValueKey('district_${state.selectedCity?.id}_${state.selectedDistrict?.id}'),
                      decoration: InputDecoration(
                        labelText: state.isLoadingDistricts ? 'İlçe yükleniyor...' : 'İlçe *',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        suffixIcon: state.isLoadingDistricts
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
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
                decoration: const InputDecoration(
                  labelText: 'Açık Adres (Mahalle, Cadde, No...) *',
                  prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                ),
                onChanged: (val) => notifier.updateRecipientInfo(details: val),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
