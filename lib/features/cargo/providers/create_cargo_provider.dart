import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/address_model.dart';
import '../models/cargo_offer_model.dart';
import '../models/location_model.dart';
import '../services/cargo_service.dart';
import '../services/location_service.dart';
import 'cargo_list_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../products/models/product_model.dart';

class CreateCargoState {
  final int currentStep; // 0, 1, 2, 3
  final List<AddressModel> senderAddresses;
  final AddressModel? selectedSenderAddress;
  final List<AddressModel> recipientAddresses;
  final AddressModel? selectedRecipientAddress;
  final bool isManualRecipient;
  final String direction; // 'send', 'receive'
  final bool isLoadingAddresses;
  final bool isCreatingAddress;

  // Lokasyonlar
  final List<City> cities;
  final List<District> districts;
  final bool isLoadingCities;
  final bool isLoadingDistricts;

  // Dış Adres (Direction send ise Alıcı, receive ise Gönderici Müşteri)
  final String recipientName;
  final String recipientPhone;
  final String recipientEmail;
  final City? selectedCity;
  final District? selectedDistrict;
  final String addressDetails;
  final String recipientPostalCode;
  final bool saveRecipientAddress;

  // Paket & Seçili Ürün
  final ProductModel? selectedProduct;
  final double width;
  final double length;
  final double height;
  final double weight; // gram
  final double desi;
  final String description;
  final String orderNumber;

  // Ek Hizmetler
  final bool payOnDelivery;
  final double payOnDeliveryAmount;
  final String payOnDeliveryType; // 'cash', 'credit_card'
  final bool canOffsetCargoFee;
  final bool receiverPays;
  final bool controlledDelivery;
  final bool isDraft;

  // Teklifler
  final bool isLoadingOffers;
  final List<CargoOffer> offers;
  final CargoOffer? selectedOffer;

  // Gönderim
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;
  final bool isSuccess;

  const CreateCargoState({
    this.currentStep = 0,
    this.senderAddresses = const [],
    this.selectedSenderAddress,
    this.recipientAddresses = const [],
    this.selectedRecipientAddress,
    this.isManualRecipient = false,
    this.direction = 'send',
    this.isLoadingAddresses = false,
    this.isCreatingAddress = false,
    this.cities = const [],
    this.districts = const [],
    this.isLoadingCities = false,
    this.isLoadingDistricts = false,
    this.recipientName = '',
    this.recipientPhone = '',
    this.recipientEmail = '',
    this.selectedCity,
    this.selectedDistrict,
    this.addressDetails = '',
    this.recipientPostalCode = '',
    this.saveRecipientAddress = false,
    this.selectedProduct,
    this.width = 0,
    this.length = 0,
    this.height = 0,
    this.weight = 0,
    this.desi = 0,
    this.description = '',
    this.orderNumber = '',
    this.payOnDelivery = false,
    this.payOnDeliveryAmount = 0,
    this.payOnDeliveryType = 'cash',
    this.canOffsetCargoFee = false,
    this.receiverPays = false,
    this.controlledDelivery = false,
    this.isDraft = false,
    this.isLoadingOffers = false,
    this.offers = const [],
    this.selectedOffer,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.isSuccess = false,
  });

  CreateCargoState copyWith({
    int? currentStep,
    List<AddressModel>? senderAddresses,
    AddressModel? selectedSenderAddress,
    List<AddressModel>? recipientAddresses,
    AddressModel? selectedRecipientAddress,
    bool? isManualRecipient,
    String? direction,
    bool? isLoadingAddresses,
    bool? isCreatingAddress,
    String? recipientName,
    String? recipientPhone,
    String? recipientEmail,
    City? selectedCity,
    District? selectedDistrict,
    String? addressDetails,
    String? recipientPostalCode,
    bool? saveRecipientAddress,
    ProductModel? selectedProduct,
    double? width,
    double? length,
    double? height,
    double? weight,
    double? desi,
    String? description,
    String? orderNumber,
    bool? payOnDelivery,
    double? payOnDeliveryAmount,
    String? payOnDeliveryType,
    bool? canOffsetCargoFee,
    bool? receiverPays,
    bool? controlledDelivery,
    bool? isDraft,
    bool? isLoadingOffers,
    List<CargoOffer>? offers,
    CargoOffer? selectedOffer,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    bool? isSuccess,
    List<City>? cities,
    List<District>? districts,
    bool? isLoadingCities,
    bool? isLoadingDistricts,
    bool clearSelectedSender = false,
    bool clearSelectedRecipient = false,
    bool clearSelectedCity = false,
    bool clearSelectedDistrict = false,
    bool clearSelectedOffer = false,
    bool clearSelectedProduct = false,
  }) {
    return CreateCargoState(
      currentStep: currentStep ?? this.currentStep,
      senderAddresses: senderAddresses ?? this.senderAddresses,
      selectedSenderAddress: clearSelectedSender ? null : (selectedSenderAddress ?? this.selectedSenderAddress),
      recipientAddresses: recipientAddresses ?? this.recipientAddresses,
      selectedRecipientAddress: clearSelectedRecipient ? null : (selectedRecipientAddress ?? this.selectedRecipientAddress),
      isManualRecipient: isManualRecipient ?? this.isManualRecipient,
      direction: direction ?? this.direction,
      isLoadingAddresses: isLoadingAddresses ?? this.isLoadingAddresses,
      isCreatingAddress: isCreatingAddress ?? this.isCreatingAddress,
      cities: cities ?? this.cities,
      districts: districts ?? this.districts,
      isLoadingCities: isLoadingCities ?? this.isLoadingCities,
      isLoadingDistricts: isLoadingDistricts ?? this.isLoadingDistricts,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      selectedCity: clearSelectedCity ? null : (selectedCity ?? this.selectedCity),
      selectedDistrict: clearSelectedDistrict ? null : (selectedDistrict ?? this.selectedDistrict),
      addressDetails: addressDetails ?? this.addressDetails,
      recipientPostalCode: recipientPostalCode ?? this.recipientPostalCode,
      saveRecipientAddress: saveRecipientAddress ?? this.saveRecipientAddress,
      selectedProduct: clearSelectedProduct ? null : (selectedProduct ?? this.selectedProduct),
      width: width ?? this.width,
      length: length ?? this.length,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      desi: desi ?? this.desi,
      description: description ?? this.description,
      orderNumber: orderNumber ?? this.orderNumber,
      payOnDelivery: payOnDelivery ?? this.payOnDelivery,
      payOnDeliveryAmount: payOnDeliveryAmount ?? this.payOnDeliveryAmount,
      payOnDeliveryType: payOnDeliveryType ?? this.payOnDeliveryType,
      canOffsetCargoFee: canOffsetCargoFee ?? this.canOffsetCargoFee,
      receiverPays: receiverPays ?? this.receiverPays,
      controlledDelivery: controlledDelivery ?? this.controlledDelivery,
      isDraft: isDraft ?? this.isDraft,
      isLoadingOffers: isLoadingOffers ?? this.isLoadingOffers,
      offers: offers ?? this.offers,
      selectedOffer: clearSelectedOffer ? null : (selectedOffer ?? this.selectedOffer),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class CreateCargoNotifier extends Notifier<CreateCargoState> {
  final CargoService _cargoService = CargoService();
  final LocationService _locationService = LocationService();

  @override
  CreateCargoState build() {
    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated && next.accountId != null && next.accountId != previous?.accountId) {
        loadAllAddresses();
        loadCities();
      }
    });
    Future.microtask(() {
      loadAllAddresses();
      loadCities();
    });
    return const CreateCargoState();
  }

  /// Canlı veritabanından tüm şehirleri yükler
  Future<void> loadCities() async {
    state = state.copyWith(isLoadingCities: true);
    final cities = await _locationService.getCities('TR');
    state = state.copyWith(cities: cities, isLoadingCities: false);
  }

  /// Tüm adresleri sunucudan çeker ve Gönderici (type 4) / Alıcı (type 1) olarak ayırır
  Future<void> loadAllAddresses() async {
    state = state.copyWith(isLoadingAddresses: true);
    try {
      final authState = ref.read(authProvider);
      final accountId = authState.accountId ?? authState.user?.accounts.firstOrNull?.id;
      final user = authState.user;
      final addresses = await _cargoService.getAddresses(accountId: accountId);

      final senders = addresses.where((a) => a.type == 4).toList();
      final recipients = addresses.where((a) => a.type == 1).toList();

      AddressModel? defaultSender;
      if (senders.isNotEmpty) {
        if (user != null) {
          defaultSender = senders.cast<AddressModel?>().firstWhere(
            (a) => a != null && (a.name.toLowerCase() == user.fullName.toLowerCase() ||
                   (user.phone != null && a.phone == user.phone)),
            orElse: () => null,
          );
        }
        defaultSender ??= senders.firstWhere((a) => a.isDefault, orElse: () => senders.first);
      }

      state = state.copyWith(
        senderAddresses: senders,
        selectedSenderAddress: defaultSender,
        recipientAddresses: recipients,
        isLoadingAddresses: false,
      );
    } catch (e) {
      debugPrint('Adresler yüklenirken hata: $e');
      state = state.copyWith(isLoadingAddresses: false);
    }
  }

  void setStep(int step) {
    if (step >= 0 && step <= 3) {
      state = state.copyWith(currentStep: step);
    }
  }

  void setSenderAddress(AddressModel? address) {
    state = state.copyWith(selectedSenderAddress: address);
  }

  void setDirection(String direction) {
    if (direction == 'receive') {
      // Tersine lojistikte (Kargo Bana Gelsin) kapıda ödeme ve alıcı ödemeli hizmetler kapatılır
      state = state.copyWith(
        direction: direction,
        payOnDelivery: false,
        payOnDeliveryAmount: 0.0,
        canOffsetCargoFee: false,
        receiverPays: false,
        controlledDelivery: false,
      );
    } else {
      state = state.copyWith(direction: direction);
    }
  }

  void toggleManualRecipient(bool isManual) {
    state = state.copyWith(isManualRecipient: isManual);
  }

  Future<void> selectRecipientAddress(AddressModel? address) async {
    if (address == null) {
      state = state.copyWith(clearSelectedRecipient: true);
      return;
    }

    final cities = state.cities.isNotEmpty ? state.cities : await _locationService.getCities('TR');
    City? matchedCity;
    District? matchedDistrict;
    List<District> districts = [];

    if (cities.isNotEmpty) {
      if (address.cityId != null) {
        matchedCity = cities.cast<City?>().firstWhere(
              (c) => c?.id == address.cityId,
              orElse: () => null,
            );
      }
      if (matchedCity == null && address.city != null) {
        matchedCity = cities.cast<City?>().firstWhere(
              (c) => c?.name.toLowerCase() == address.city!.name.toLowerCase(),
              orElse: () => null,
            );
      }

      if (matchedCity != null) {
        districts = await _locationService.getDistricts(matchedCity.id);
        if (address.districtId != null) {
          matchedDistrict = districts.cast<District?>().firstWhere(
                (d) => d?.id == address.districtId,
                orElse: () => null,
              );
        }
        if (matchedDistrict == null && address.district != null) {
          matchedDistrict = districts.cast<District?>().firstWhere(
                (d) => d?.name.toLowerCase() == address.district!.name.toLowerCase(),
                orElse: () => null,
              );
        }
      }
    }

    state = state.copyWith(
      selectedRecipientAddress: address,
      recipientName: address.name,
      recipientPhone: address.phone,
      recipientEmail: address.email ?? '',
      addressDetails: address.details,
      recipientPostalCode: address.postalCode ?? '',
      selectedCity: matchedCity,
      districts: districts,
      selectedDistrict: matchedDistrict,
    );
  }

  void updateRecipientInfo({
    String? name,
    String? phone,
    String? email,
    City? city,
    District? district,
    String? details,
    String? postalCode,
    bool? saveAddress,
  }) {
    state = state.copyWith(
      recipientName: name ?? state.recipientName,
      recipientPhone: phone ?? state.recipientPhone,
      recipientEmail: email ?? state.recipientEmail,
      selectedCity: city ?? state.selectedCity,
      selectedDistrict: district ?? state.selectedDistrict,
      addressDetails: details ?? state.addressDetails,
      recipientPostalCode: postalCode ?? state.recipientPostalCode,
      saveRecipientAddress: saveAddress ?? state.saveRecipientAddress,
    );
  }

  Future<void> selectCity(City? city) async {
    state = state.copyWith(
      selectedCity: city,
      districts: const [],
      clearSelectedDistrict: true,
      isLoadingDistricts: city != null,
    );

    if (city != null) {
      final districts = await _locationService.getDistricts(city.id);
      state = state.copyWith(
        districts: districts,
        isLoadingDistricts: false,
      );
    }
  }

  void selectDistrict(District? district) {
    state = state.copyWith(selectedDistrict: district);
  }

  /// Yeni Gönderici Adresi Ekle (type: 4)
  Future<AddressCreationResult> createSenderAddress({
    required String title,
    required String name,
    required String phone,
    String? email,
    required int cityId,
    required int districtId,
    required String details,
    String? postalCode,
    String? corporateName,
    String? vkn,
    String? responsiblePersonName,
    String? responsiblePersonLastname,
    String? responsiblePersonTckn,
  }) async {
    final accountId = ref.read(authProvider).accountId;
    if (accountId == null || accountId.isEmpty) {
      return AddressCreationResult(
        isSuccess: false,
        message: 'Hesap bilgisi bulunamadı. Lütfen tekrar giriş yapın.',
      );
    }

    state = state.copyWith(isCreatingAddress: true);

    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final payload = {
      "type": 4, // Gönderici
      "title": title.isNotEmpty ? title : name,
      "name": name,
      "phone": cleanPhone,
      if (email != null && email.trim().isNotEmpty) "email": email.trim(),
      "country_id": "TR",
      "city_id": cityId,
      "district_id": districtId,
      "details": details,
      if (postalCode != null && postalCode.trim().isNotEmpty) "postal_code": postalCode.trim(),
      if (corporateName != null && corporateName.trim().isNotEmpty) "corporate_name": corporateName.trim(),
      if (vkn != null && vkn.trim().isNotEmpty) "vkn": vkn.trim(),
      if (responsiblePersonName != null && responsiblePersonName.trim().isNotEmpty) "responsible_person_name": responsiblePersonName.trim(),
      if (responsiblePersonLastname != null && responsiblePersonLastname.trim().isNotEmpty) "responsible_person_lastname": responsiblePersonLastname.trim(),
      if (responsiblePersonTckn != null && responsiblePersonTckn.trim().isNotEmpty) "responsible_person_tckn": responsiblePersonTckn.trim(),
    };

    final result = await _cargoService.createAddress(accountId, payload);

    if (result.isSuccess && result.address != null) {
      final updatedList = [result.address!, ...state.senderAddresses];
      state = state.copyWith(
        senderAddresses: updatedList,
        selectedSenderAddress: result.address,
        isCreatingAddress: false,
      );
    } else {
      state = state.copyWith(isCreatingAddress: false);
    }

    return result;
  }

  /// Yeni Alıcı Adresi Ekle (type: 1)
  Future<AddressCreationResult> createRecipientAddress({
    required String name,
    required String phone,
    String? email,
    required int cityId,
    required int districtId,
    required String details,
    String? postalCode,
  }) async {
    final accountId = ref.read(authProvider).accountId;
    if (accountId == null || accountId.isEmpty) {
      return AddressCreationResult(
        isSuccess: false,
        message: 'Hesap bilgisi bulunamadı.',
      );
    }

    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final payload = {
      "type": 1, // Alıcı / Müşteri
      "name": name,
      "title": name,
      "phone": cleanPhone,
      if (email != null && email.trim().isNotEmpty) "email": email.trim(),
      "country_id": "TR",
      "city_id": cityId,
      "district_id": districtId,
      "details": details,
      if (postalCode != null && postalCode.trim().isNotEmpty) "postal_code": postalCode.trim(),
    };

    final result = await _cargoService.createAddress(accountId, payload);

    if (result.isSuccess && result.address != null) {
      final updatedList = [result.address!, ...state.recipientAddresses];
      state = state.copyWith(
        recipientAddresses: updatedList,
        selectedRecipientAddress: result.address,
      );
    }

    return result;
  }

  /// Ürün Seçildiğinde Paket ve Fiyat Bilgilerini Otomatik Doldur
  void selectProduct(ProductModel? product) {
    if (product == null) {
      state = state.copyWith(
        clearSelectedProduct: true,
        width: 0.0,
        length: 0.0,
        height: 0.0,
        weight: 0.0,
        desi: 0.0,
        description: '',
        payOnDeliveryAmount: 0.0,
      );
      return;
    }

    final w = (product.width != null && product.width! > 0) ? product.width! : state.width;
    final l = (product.length != null && product.length! > 0) ? product.length! : state.length;
    final h = (product.height != null && product.height! > 0) ? product.height! : state.height;
    final wt = (product.weight != null && product.weight! > 0 ? product.weight! * 1000 : state.weight); // kg -> gram
    final rawDesi = product.desi > 0 ? product.desi : (w > 0 && l > 0 && h > 0 ? (w * l * h) / 3000 : state.desi);
    final calculatedDesi = double.parse(rawDesi.toStringAsFixed(2));

    state = state.copyWith(
      selectedProduct: product,
      width: w,
      length: l,
      height: h,
      weight: wt,
      desi: calculatedDesi,
      description: product.name.isNotEmpty ? product.name : state.description,
      payOnDeliveryAmount: product.price > 0 ? product.price : state.payOnDeliveryAmount,
    );
  }

  void updatePackageDimensions({
    double? width,
    double? length,
    double? height,
    double? weight,
    double? directDesi,
  }) {
    final w = width ?? state.width;
    final l = length ?? state.length;
    final h = height ?? state.height;
    final rawDesi = directDesi ?? ((w * l * h) / 3000);
    final calculatedDesi = double.parse(rawDesi.toStringAsFixed(2));

    state = state.copyWith(
      width: w,
      length: l,
      height: h,
      weight: weight ?? state.weight,
      desi: calculatedDesi,
    );
  }

  void updatePackageNotes({String? description, String? orderNumber}) {
    state = state.copyWith(
      description: description ?? state.description,
      orderNumber: orderNumber ?? state.orderNumber,
    );
  }

  void updateAdditionalServices({
    bool? payOnDelivery,
    double? payOnDeliveryAmount,
    String? payOnDeliveryType,
    bool? canOffsetCargoFee,
    bool? receiverPays,
    bool? controlledDelivery,
    bool? isDraft,
  }) {
    bool newPayOnDelivery = payOnDelivery ?? state.payOnDelivery;
    double newAmount = payOnDeliveryAmount ?? state.payOnDeliveryAmount;
    bool newOffset = canOffsetCargoFee ?? state.canOffsetCargoFee;
    bool newReceiverPays = receiverPays ?? state.receiverPays;
    bool newControlled = controlledDelivery ?? state.controlledDelivery;
    bool newDraft = isDraft ?? state.isDraft;

    // Eğer Kapıda Ödeme kapatıldıysa tutarı ve mahsubu sıfırla
    if (payOnDelivery == false) {
      newAmount = 0.0;
      newOffset = false;
    }

    // Karşılıklı Kısıtlama: Kapıda Alıcı Ödemeli (pod_receiver_pays) açılırsa, mahsup (past_pay_on_delivery) kapanmalıdır
    if (receiverPays == true) {
      newOffset = false;
    }

    // Karşılıklı Kısıtlama: Mahsup açılırsa, Kapıda Alıcı Ödemeli kapanmalıdır
    if (canOffsetCargoFee == true) {
      newReceiverPays = false;
    }

    state = state.copyWith(
      payOnDelivery: newPayOnDelivery,
      payOnDeliveryAmount: newAmount,
      payOnDeliveryType: payOnDeliveryType ?? state.payOnDeliveryType,
      canOffsetCargoFee: newOffset,
      receiverPays: newReceiverPays,
      controlledDelivery: newControlled,
      isDraft: newDraft,
    );
  }

  void selectOffer(CargoOffer offer) {
    state = state.copyWith(selectedOffer: offer);
  }

  /// POST /cargos/offer (Fiyat Teklifi Hesapla)
  Future<void> calculateOffers() async {
    final auth = ref.read(authProvider);
    final accountId = auth.accountId ?? auth.user?.accounts.firstOrNull?.id;
    if (accountId == null || accountId.isEmpty) {
      state = state.copyWith(isLoadingOffers: false, errorMessage: 'Kullanıcı hesabı bulunamadı.');
      return;
    }
    final desi = state.desi > 0 ? state.desi : 1.0;

    state = state.copyWith(isLoadingOffers: true, errorMessage: null);

    // Alıcı Adres ID'sini (foreign_id) Çöz
    String? foreignId = state.selectedRecipientAddress?.id;
    if ((foreignId == null || foreignId.isEmpty) &&
        state.recipientName.trim().isNotEmpty &&
        state.recipientPhone.trim().isNotEmpty) {
      final addResult = await createRecipientAddress(
        name: state.recipientName.trim(),
        phone: state.recipientPhone.trim(),
        email: state.recipientEmail.trim().isNotEmpty ? state.recipientEmail.trim() : null,
        cityId: state.selectedCity?.id ?? 34,
        districtId: state.selectedDistrict?.id ?? 1101,
        details: state.addressDetails.trim().isNotEmpty
            ? state.addressDetails.trim()
            : '${state.selectedDistrict?.name ?? ""}, ${state.selectedCity?.name ?? ""}',
        postalCode: state.recipientPostalCode.trim().isNotEmpty ? state.recipientPostalCode.trim() : null,
      );
      if (addResult.isSuccess && addResult.address != null) {
        foreignId = addResult.address!.id;
      }
    }

    final request = CargoCalculateRequest(
      accountId: accountId,
      localId: state.selectedSenderAddress?.id,
      foreignId: foreignId,
      package: PackageData(
        desi: double.parse((desi > 0 ? desi : 1.0).toStringAsFixed(2)),
        width: state.width > 0 ? double.parse(state.width.toStringAsFixed(2)) : null,
        length: state.length > 0 ? double.parse(state.length.toStringAsFixed(2)) : null,
        height: state.height > 0 ? double.parse(state.height.toStringAsFixed(2)) : null,
        weight: state.weight > 0 ? double.parse((state.weight / 1000).toStringAsFixed(3)) : null,
      ),
      payOnDelivery: state.payOnDelivery,
      payOnDeliveryAmount: state.payOnDelivery ? state.payOnDeliveryAmount : 0,
      payOnDeliveryType: state.payOnDelivery ? state.payOnDeliveryType : null,
      pastPayOnDelivery: state.payOnDelivery ? state.canOffsetCargoFee : false,
      podReceiverPays: state.payOnDelivery ? state.receiverPays : false,
      receiverPays: state.payOnDelivery ? false : state.receiverPays,
      controlledDelivery: state.controlledDelivery,
      status: state.isDraft ? 0 : 1,
      direction: state.direction,
    );

    final offerResult = await _cargoService.calculateOffers(request);
    var offers = offerResult.offers;

    // Eğer kontrollü teslimat seçilmişse, yalnızca PTT Kargo destekler
    if (state.controlledDelivery && offers.isNotEmpty) {
      offers = offers.where((o) => o.cargoCompany.id.toString().contains('ptt')).toList();
    }

    if (offers.isEmpty) {
      offers = _generateFallbackOffers(desi, state.payOnDelivery, state.controlledDelivery);
    }

    state = state.copyWith(
      isLoadingOffers: false,
      offers: offers,
      selectedOffer: offers.isNotEmpty ? offers.first : null,
      errorMessage: offerResult.isSuccess ? null : offerResult.errorMessage,
    );
  }

  List<CargoOffer> _generateFallbackOffers(double desi, bool isPod, [bool isControlled = false]) {
    final effectiveDesi = desi <= 2 ? 2.0 : desi;
    if (isControlled) {
      return [
        CargoOffer(
          cargoCompany: CargoCompany(id: 'ptt-kargo', title: 'PTT Kargo'),
          price: (96.14 + (effectiveDesi > 2 ? (effectiveDesi - 2) * 15.0 : 0.0)),
        ),
      ];
    }
    return [
      CargoOffer(
        cargoCompany: CargoCompany(id: 'ptt-kargo', title: 'PTT Kargo'),
        price: (96.14 + (effectiveDesi > 2 ? (effectiveDesi - 2) * 15.0 : 0.0)),
      ),
      CargoOffer(
        cargoCompany: CargoCompany(id: 'hepsijet', title: 'HEPSİJET'),
        price: (104.40 + (effectiveDesi > 2 ? (effectiveDesi - 2) * 16.0 : 0.0)),
      ),
      CargoOffer(
        cargoCompany: CargoCompany(id: 'surat-kargo', title: 'Sürat Kargo'),
        price: (136.21 + (effectiveDesi > 2 ? (effectiveDesi - 2) * 17.0 : 0.0)),
      ),
      CargoOffer(
        cargoCompany: CargoCompany(id: 'yurtici-kargo', title: 'Yurtiçi Kargo'),
        price: (233.99 + (effectiveDesi > 2 ? (effectiveDesi - 2) * 18.0 : 0.0)),
      ),
      CargoOffer(
        cargoCompany: CargoCompany(id: 'ups', title: 'UPS Kargo'),
        price: (176.10 + (effectiveDesi > 2 ? (effectiveDesi - 2) * 16.67 : 0.0)),
      ),
    ];
  }

  /// Kargo Oluşturma İsteği (POST /cargos)
  Future<bool> submitCargo() async {
    final auth = ref.read(authProvider);
    final accountId = auth.accountId ?? auth.user?.accounts.firstOrNull?.id;
    if (accountId == null || accountId.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Hesap bilgisi alınamadı. Lütfen oturumu yenileyin.',
      );
      return false;
    }

    if (state.selectedSenderAddress == null) {
      state = state.copyWith(
        errorMessage: 'Lütfen kayıtlı bir gönderici adresi seçiniz veya yeni ekleyiniz.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null, isSuccess: false);

    // 1. Alıcı Adres ID'sini (foreign_id) Çöz
    String? foreignId = state.selectedRecipientAddress?.id;

    // Eğer manuel girilmişse veya seçili alıcı yoksa backend için adresi oluşturup ID al
    if (foreignId == null || foreignId.isEmpty) {
      if (state.recipientName.trim().isEmpty) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Lütfen alıcı ad ve soyadını giriniz.',
        );
        return false;
      }

      final phoneDigits = state.recipientPhone.replaceAll(RegExp(r'\D'), '');
      if (phoneDigits.length < 10) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Lütfen en az 10 haneli geçerli bir alıcı telefon numarası giriniz.',
        );
        return false;
      }

      if (state.selectedCity == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Lütfen alıcı ilini seçiniz.',
        );
        return false;
      }

      final details = state.addressDetails.trim().isNotEmpty
          ? state.addressDetails.trim()
          : '${state.selectedDistrict?.name ?? ""}, ${state.selectedCity?.name ?? ""}';

      final addResult = await createRecipientAddress(
        name: state.recipientName.trim(),
        phone: state.recipientPhone.trim(),
        email: state.recipientEmail.trim().isNotEmpty ? state.recipientEmail.trim() : null,
        cityId: state.selectedCity!.id,
        districtId: state.selectedDistrict?.id ?? 1101,
        details: details,
        postalCode: state.recipientPostalCode.trim().isNotEmpty ? state.recipientPostalCode.trim() : null,
      );

      if (!addResult.isSuccess || addResult.address == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Alıcı adresi oluşturulamadı: ${addResult.message ?? "Bilgileri kontrol ediniz."}',
        );
        return false;
      }

      foreignId = addResult.address!.id;
    }

    // 2. Kargo Şirketi Belirle
    var cargoCompanyId = state.selectedOffer?.cargoCompany.id?.toString() ?? 'ptt-kargo';
    if (cargoCompanyId == 'ptt') cargoCompanyId = 'ptt-kargo';
    if (cargoCompanyId == 'surat') cargoCompanyId = 'surat-kargo';
    if (cargoCompanyId == 'yurtici') cargoCompanyId = 'yurtici-kargo';
    if (cargoCompanyId == 'bilinmeyen' || cargoCompanyId.isEmpty) cargoCompanyId = 'ptt-kargo';

    // 3. Payload hazırla (Backend API gereksinimlerine tam uyumlu)
    final isSend = state.direction == 'send';
    final effectiveDesi = state.desi > 0 ? state.desi : 1.0;
    double effectiveLength = state.length;
    double effectiveWidth = state.width;
    double effectiveHeight = state.height;

    // Eğer manuel ölçü girilmemişse, desi ile tam uyumlu kübik boyut ata (kargo firması API'sinin desiyi düşürmesini engeller)
    if (effectiveLength <= 0 || effectiveWidth <= 0 || effectiveHeight <= 0) {
      final side = math.pow(effectiveDesi * 3000, 1 / 3).toDouble();
      effectiveLength = double.parse(side.toStringAsFixed(2));
      effectiveWidth = double.parse(side.toStringAsFixed(2));
      effectiveHeight = double.parse(side.toStringAsFixed(2));
    }

    final payload = {
      "account_id": accountId,
      "cargo_company_id": cargoCompanyId,
      "local_id": state.selectedSenderAddress!.id,
      "foreign_id": foreignId,
      "package": {
        "desi": double.parse(effectiveDesi.toStringAsFixed(2)),
        "length": effectiveLength,
        "width": effectiveWidth,
        "height": effectiveHeight,
        "weight": state.weight > 0 ? double.parse((state.weight / 1000).toStringAsFixed(3)) : 1.0,
      },
      "direction": isSend ? 1 : 2, // 1: Send, 2: Receive
      "pay_on_delivery": state.payOnDelivery,
      "pay_on_delivery_amount": state.payOnDelivery ? state.payOnDeliveryAmount : 0,
      "pay_on_delivery_type": state.payOnDelivery ? (state.payOnDeliveryType == 'cash' ? 1 : 2) : 1,
      "past_pay_on_delivery": state.payOnDelivery ? state.canOffsetCargoFee : false,
      "pod_receiver_pays": state.payOnDelivery ? state.receiverPays : false,
      "receiver_pays": state.payOnDelivery ? false : state.receiverPays,
      "controlled_delivery": state.controlledDelivery,
      "status": state.isDraft ? 0 : 1, // 0 = Taslak, 1 = Aktif
      "order_number": state.orderNumber.isNotEmpty ? state.orderNumber : null,
      "description": state.description.isNotEmpty ? state.description : 'Mobil Gönderi',
      "create_failed": true,
      "source": "app",
      if (state.selectedProduct != null) "product_id": state.selectedProduct!.id,
      "quantity": 1,
    };

    final result = await _cargoService.createCargo(payload);

    if (result.isSuccess) {
      ref.read(cargoListProvider.notifier).refresh();
    }

    state = state.copyWith(
      isSubmitting: false,
      isSuccess: result.isSuccess,
      successMessage: result.isSuccess ? (result.message ?? 'Kargo başarıyla oluşturuldu.') : null,
      errorMessage: result.isSuccess ? null : (result.message ?? 'Kargo oluşturulamadı.'),
    );

    return result.isSuccess;
  }

  void reset() {
    final existingCities = state.cities;
    state = CreateCargoState(cities: existingCities);
    loadAllAddresses();
    if (existingCities.isEmpty) {
      loadCities();
    }
  }
}

final createCargoProvider = NotifierProvider<CreateCargoNotifier, CreateCargoState>(() {
  return CreateCargoNotifier();
});
