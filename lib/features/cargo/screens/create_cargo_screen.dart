import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_formatters.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../dashboard/screens/top_up_balance_screen.dart';
import '../../home/providers/navigation_provider.dart';
import '../../products/models/product_model.dart';
import '../../products/providers/products_provider.dart';
import '../../products/widgets/add_edit_product_modal.dart';
import '../models/location_model.dart';
import '../providers/cargo_list_provider.dart';
import '../providers/create_cargo_provider.dart';
import '../widgets/add_sender_address_modal.dart';
import '../widgets/cargo_company_logo.dart';

class CreateCargoScreen extends ConsumerStatefulWidget {
  const CreateCargoScreen({super.key});

  @override
  ConsumerState<CreateCargoScreen> createState() => _CreateCargoScreenState();
}

class _CreateCargoScreenState extends ConsumerState<CreateCargoScreen> {
  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _desiController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _orderNumberController = TextEditingController();
  final TextEditingController _podAmountController = TextEditingController();
  final TextEditingController _customerSearchController = TextEditingController();

  String _deliveryType = 'standard'; // 'standard', 'pod', 'receiver'
  double _calculatedDesi = 2.0;

  @override
  void initState() {
    super.initState();
    _setInitialDefaults();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsProvider.notifier).loadProducts(reset: true);
      final cargoState = ref.read(createCargoProvider);
      final cargoNotifier = ref.read(createCargoProvider.notifier);
      cargoNotifier.updatePackageDimensions(
        width: 20,
        length: 30,
        height: 10,
        weight: 1000,
        directDesi: 2.0,
      );
      if (cargoState.cities.isEmpty) {
        cargoNotifier.loadCities();
      }
      if (cargoState.senderAddresses.isEmpty) {
        cargoNotifier.loadAllAddresses();
      }
      cargoNotifier.calculateOffers();
    });
  }

  void _setInitialDefaults() {
    _deliveryType = 'standard';
    _widthController.text = '20';
    _lengthController.text = '30';
    _heightController.text = '10';
    _weightController.text = '1';
    _desiController.text = '2.00';
    _calculatedDesi = 2.0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _desiController.dispose();
    _widthController.dispose();
    _lengthController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    _orderNumberController.dispose();
    _podAmountController.dispose();
    _customerSearchController.dispose();
    super.dispose();
  }

  void _setDeliveryType(String type) {
    setState(() {
      _deliveryType = type;
    });

    final notifier = ref.read(createCargoProvider.notifier);
    final state = ref.read(createCargoProvider);
    if (type == 'standard') {
      notifier.updateAdditionalServices(
        payOnDelivery: false,
        receiverPays: false,
      );
    } else if (type == 'pod') {
      final amt = AppFormatters.parseDouble(_podAmountController.text);
      final podAmt = amt > 0 ? amt : 850.0;
      notifier.updateAdditionalServices(
        payOnDelivery: true,
        payOnDeliveryAmount: podAmt,
        payOnDeliveryType: state.payOnDeliveryType.isNotEmpty ? state.payOnDeliveryType : 'cash',
        canOffsetCargoFee: state.canOffsetCargoFee || true,
        receiverPays: false,
      );
      if (_podAmountController.text.isEmpty) {
        _podAmountController.text = '850';
      }
    } else if (type == 'receiver') {
      notifier.updateAdditionalServices(
        payOnDelivery: false,
        receiverPays: true,
      );
    }
    notifier.calculateOffers();
  }

  void _calculateDesi() {
    final w = AppFormatters.parseDouble(_widthController.text);
    final l = AppFormatters.parseDouble(_lengthController.text);
    final h = AppFormatters.parseDouble(_heightController.text);
    final weightKg = AppFormatters.parseDouble(_weightController.text);

    double volumetricDesi = (w > 0 && l > 0 && h > 0) ? (w * l * h) / 3000.0 : 0.0;
    double effective = math.max(volumetricDesi, weightKg);

    final rounded = double.parse(effective.toStringAsFixed(2));
    setState(() {
      _calculatedDesi = rounded >= 0 ? rounded : 0.0;
    });

    _desiController.text = _calculatedDesi.toStringAsFixed(2);
    final notifier = ref.read(createCargoProvider.notifier);
    notifier.updatePackageDimensions(
      width: w,
      length: l,
      height: h,
      weight: weightKg * 1000,
      directDesi: _calculatedDesi,
    );
    notifier.calculateOffers();
  }

  void _populateFromProduct(ProductModel product) {
    final notifier = ref.read(createCargoProvider.notifier);
    notifier.selectProduct(product);

    final pDesi = product.desi > 0 ? product.desi : 2.0;
    double w = (product.width != null && product.width! > 0) ? product.width! : 0;
    double l = (product.length != null && product.length! > 0) ? product.length! : 0;
    double h = (product.height != null && product.height! > 0) ? product.height! : 0;
    if (w <= 0 || l <= 0 || h <= 0) {
      final side = double.parse(math.pow(pDesi * 3000, 1 / 3).toStringAsFixed(1));
      w = side;
      l = side;
      h = side;
    }
    _widthController.text = w.toString();
    _lengthController.text = l.toString();
    _heightController.text = h.toString();
    final weightInKg = (product.weight != null && product.weight! > 0) ? product.weight! : 1.0;
    _weightController.text = weightInKg.toString();

    _descriptionController.text = product.name;
    if (product.price > 0) {
      _podAmountController.text = product.price.toStringAsFixed(2);
      notifier.updateAdditionalServices(payOnDeliveryAmount: product.price);
    }
    _calculateDesi();
  }

  void _clearSelectedProduct() {
    final notifier = ref.read(createCargoProvider.notifier);
    notifier.selectProduct(null);
    setState(() {
      _setInitialDefaults();
    });
    _descriptionController.clear();
    _orderNumberController.clear();
    _podAmountController.clear();
    notifier.updatePackageDimensions(
      width: 20,
      length: 30,
      height: 10,
      weight: 1000,
      directDesi: 2.0,
    );
    notifier.calculateOffers();
  }

  void _clearAllFormFields() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _addressController.clear();
    _postalCodeController.clear();
    _descriptionController.clear();
    _orderNumberController.clear();
    _podAmountController.clear();
    _customerSearchController.clear();
    _setInitialDefaults();
  }

  void _showDesiInputDialog(CreateCargoNotifier notifier) {
    final customDesiController = TextEditingController(text: _calculatedDesi.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Desi Değerini Belirleyin',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evrak, dosya veya özel kargolar için 0.00 dahil olmak üzere doğrudan desi belirleyebilirsiniz:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: customDesiController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Desi',
                suffixText: 'DESİ',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('0.00 Desi (Evrak)'),
                  onPressed: () => customDesiController.text = '0.00',
                ),
                ActionChip(
                  label: const Text('1.00 Desi'),
                  onPressed: () => customDesiController.text = '1.00',
                ),
                ActionChip(
                  label: const Text('2.00 Desi'),
                  onPressed: () => customDesiController.text = '2.00',
                ),
                ActionChip(
                  label: const Text('3.00 Desi'),
                  onPressed: () => customDesiController.text = '3.00',
                ),
                ActionChip(
                  label: const Text('5.00 Desi'),
                  onPressed: () => customDesiController.text = '5.00',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final parsed = double.tryParse(customDesiController.text.replaceAll(',', '.')) ?? 0.0;
              final validDesi = parsed >= 0 ? parsed : 0.0;
              Navigator.pop(ctx);
              setState(() {
                _calculatedDesi = validDesi;
              });
              _desiController.text = validDesi.toStringAsFixed(2);
              if (validDesi == 0.0) {
                _widthController.text = '0';
                _lengthController.text = '0';
                _heightController.text = '0';
                _weightController.text = '0';
                notifier.updatePackageDimensions(
                  width: 0,
                  length: 0,
                  height: 0,
                  weight: 0,
                  directDesi: 0.0,
                );
              } else {
                final side = math.pow(validDesi * 3000, 1 / 3).toDouble();
                final sideStr = side.toStringAsFixed(1);
                _widthController.text = sideStr;
                _lengthController.text = sideStr;
                _heightController.text = sideStr;
                _weightController.text = '1';
                notifier.updatePackageDimensions(
                  width: side,
                  length: side,
                  height: side,
                  weight: 1000,
                  directDesi: validDesi,
                );
              }
              notifier.calculateOffers();
            },
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
  }

  void _showWarning(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFE11D48) : const Color(0xFFD97706),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<String> _checkBalanceAndConfirm(BuildContext context, WidgetRef ref, double cargoFee) async {
    final cargoState = ref.read(createCargoProvider);
    if (cargoState.receiverPays) {
      return 'proceed';
    }
    final balanceState = ref.read(dashboardProvider);
    final availableBalance = balanceState.balance?.availableBalance ??
        balanceState.balance?.balance ??
        balanceState.stats?.availableBalance ??
        0.0;

    if (availableBalance < cargoFee) {
      final choice = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFD97706), size: 22),
              SizedBox(width: 8),
              Text(
                'Yetersiz Bakiye',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kargo taşıma ücreti (${AppFormatters.formatCurrency(cargoFee)}), cüzdan bakiyenizden (${AppFormatters.formatCurrency(availableBalance)}) yüksektir.',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  'Kargonuzu oluşturabilmek için bakiye yükleyebilir veya daha sonra tamamlamak üzere "Taslak" olarak kaydedebilirsiniz.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'cancel'),
              child: const Text(
                'Vazgeç',
                style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w800),
              ),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx, 'draft'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'Taslak Kaydet',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, 'topup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text(
                'Bakiye Yükle',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      );

      if (choice == 'topup') {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TopUpBalanceScreen()),
          );
        }
        return 'topup';
      } else if (choice == 'draft') {
        return 'draft';
      } else {
        return 'cancel';
      }
    }
    return 'proceed';
  }

  void _showSuccessDialog(BuildContext context, String trackingCode, {bool isDraft = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: Color(0xFF0F172A), width: 3),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDraft ? const Color(0xFFEFF6FF) : const Color(0xFFD1FAE5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDraft ? const Color(0xFF93C5FD) : const Color(0xFF6EE7B7),
                  width: 2,
                ),
              ),
              child: Icon(
                isDraft ? Icons.bookmark_added_rounded : Icons.check_rounded,
                color: isDraft ? const Color(0xFF2563EB) : const Color(0xFF059669),
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isDraft ? 'Taslak Kaydedildi!' : 'Kargo Oluşturuldu!',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isDraft
                  ? 'Kargonuz taslak olarak kaydedildi. Dilediğiniz zaman Kargolarım ekranından tamamlayabilirsiniz.'
                  : 'Takip barkodunuz üretildi ve kargo firması sistemine başarıyla işlendi.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
              ),
              child: Text(
                trackingCode.isNotEmpty
                    ? trackingCode
                    : (isDraft ? 'TASLAK GÖNDERİ' : 'STC-7185726557957'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _clearAllFormFields();
                  ref.read(createCargoProvider.notifier).reset();
                  ref.read(cargoListProvider.notifier).refresh();
                  ref.read(dashboardProvider.notifier).refresh();
                  ref.read(mainNavigationProvider.notifier).selectTab(1);
                },
                child: const Text(
                  'KARGOLARIM EKRANINA GİT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitCargoForm({bool isDraft = false}) async {
    final notifier = ref.read(createCargoProvider.notifier);
    final state = ref.read(createCargoProvider);

    final isSend = state.direction == 'send' || state.direction == '1';

    // 1. Gönderici / Varış Deposu Kontrolü
    if (state.selectedSenderAddress == null) {
      _showWarning(
        isSend
            ? 'Lütfen kargonun çıkış yapacağı gönderici deposunu seçiniz.'
            : 'Lütfen kargonun teslim alınacağı varış deposunu seçiniz.',
      );
      return;
    }

    // 2. Karşı Taraf Ad Soyad
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showWarning(isSend ? 'Lütfen alıcı ad ve soyadını giriniz.' : 'Lütfen gönderici ad ve soyadını giriniz.');
      return;
    }
    if (name.length < 3) {
      _showWarning(
        isSend
            ? 'Lütfen geçerli bir alıcı ad ve soyadı giriniz (en az 3 karakter).'
            : 'Lütfen geçerli bir gönderici ad ve soyadı giriniz (en az 3 karakter).',
      );
      return;
    }

    // 3. Telefon
    final phoneDigits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (phoneDigits.length < 10) {
      _showWarning('Lütfen en az 10 haneli geçerli bir telefon numarası giriniz.');
      return;
    }

    // 4. İl & İlçe
    if (state.selectedCity == null) {
      _showWarning(
        isSend ? 'Lütfen teslimat yapılacak ili (şehri) seçiniz.' : 'Lütfen çıkış yapılacak ili (şehri) seçiniz.',
      );
      return;
    }
    if (state.selectedDistrict == null) {
      _showWarning(
        isSend ? 'Lütfen teslimat yapılacak ilçeyi seçiniz.' : 'Lütfen çıkış yapılacak ilçeyi seçiniz.',
      );
      return;
    }

    // 5. Açık Adres
    final address = _addressController.text.trim();
    if (address.isEmpty || address.length < 5) {
      _showWarning(
        isSend ? 'Lütfen geçerli ve detaylı bir teslimat adresi giriniz.' : 'Lütfen geçerli ve detaylı bir çıkış adresi giriniz.',
      );
      return;
    }

    // 6. Kapıda Ödeme
    if (state.payOnDelivery) {
      final podAmount = AppFormatters.parseDouble(_podAmountController.text);
      if (podAmount <= 0) {
        _showWarning('Kapıda ödeme seçildiğinde tahsil edilecek tutar en az 1 TL olmalıdır.');
        return;
      }
      if (podAmount > 30000) {
        _showWarning('Kapıda ödeme yasal tahsilat üst sınırı 30.000 TL\'dir.');
        return;
      }
      notifier.updateAdditionalServices(payOnDeliveryAmount: podAmount);
    }

    // 7. Teklif Kontrolü
    if (!isDraft && state.selectedOffer == null) {
      if (state.offers.isNotEmpty) {
        notifier.selectOffer(state.offers.first);
      } else {
        _showWarning('Lütfen kargonuzu taşımak için bir kargo firması seçiniz.');
        return;
      }
    }

    // 8. Bakiye Yeterlilik Kontrolü
    bool submittingAsDraft = isDraft;
    final currentSelectedOffer = ref.read(createCargoProvider).selectedOffer;
    if (!submittingAsDraft && !state.receiverPays && currentSelectedOffer != null && !state.canOffsetCargoFee) {
      final balanceDecision = await _checkBalanceAndConfirm(
        context,
        ref,
        currentSelectedOffer.price,
      );
      if (balanceDecision == 'cancel' || balanceDecision == 'topup') return;
      if (balanceDecision == 'draft') {
        submittingAsDraft = true;
      }
    }

    // Paket boyutlarını ve ölçüleri tam senkronize et
    final w = AppFormatters.parseDouble(_widthController.text);
    final l = AppFormatters.parseDouble(_lengthController.text);
    final h = AppFormatters.parseDouble(_heightController.text);
    final weightKg = AppFormatters.parseDouble(_weightController.text);
    notifier.updatePackageDimensions(
      width: w,
      length: l,
      height: h,
      weight: weightKg * 1000,
      directDesi: _calculatedDesi,
    );

    notifier.toggleDraft(submittingAsDraft);
    notifier.updateRecipientInfo(
      name: name,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      details: address,
    );
    notifier.updatePackageNotes(
      orderNumber: _orderNumberController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    final success = await notifier.submitCargo();
    if (!mounted) return;

    if (success) {
      final successMsg = ref.read(createCargoProvider).successMessage ?? '';
      _showSuccessDialog(context, successMsg, isDraft: submittingAsDraft);
    } else {
      final error = ref.read(createCargoProvider).errorMessage;
      final displayError = (error != null && error.trim().isNotEmpty)
          ? error
          : 'Kargo oluşturulamadı. Lütfen bilgilerinizi kontrol ediniz.';
      _showWarning(displayError, isError: true);
    }
  }

  void _openDirectoryModal(BuildContext context, CreateCargoState state, CreateCargoNotifier notifier) {
    _customerSearchController.clear();
    final isSend = state.direction == 'send' || state.direction == '1';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = _customerSearchController.text.trim().toLowerCase();
            final filtered = state.recipientAddresses.where((a) {
              if (query.isEmpty) return true;
              return a.name.toLowerCase().contains(query) ||
                  a.phone.contains(query) ||
                  (a.city?.name.toLowerCase().contains(query) ?? false) ||
                  (a.district?.name.toLowerCase().contains(query) ?? false);
            }).toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isSend ? 'KAYITLI ALICI REHBERİ' : 'KAYITLI MÜŞTERİ REHBERİ',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: 0.5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(ctx),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _customerSearchController,
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      hintText: isSend ? 'Müşteri adı veya telefon ara...' : 'Gönderici adı veya telefon ara...',
                      hintStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Flexible(
                    child: filtered.isEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 28),
                            alignment: Alignment.center,
                            child: Text(
                              state.recipientAddresses.isEmpty
                                  ? 'Henüz kayıtlı müşteri bulunmuyor.'
                                  : 'Arama kriterine uygun kayıt bulunamadı.',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            separatorBuilder: (context, _) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final addr = filtered[index];
                              return Material(
                                color: const Color(0xFFF8FAFC),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () async {
                                    _nameController.text = addr.name;
                                    _phoneController.text = addr.phone;
                                    _emailController.text = addr.email ?? '';
                                    _addressController.text = addr.details;
                                    _postalCodeController.text = addr.postalCode ?? '';
                                    await notifier.selectRecipientAddress(addr);
                                    await notifier.calculateOffers();
                                    if (ctx.mounted) {
                                      Navigator.pop(ctx);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          addr.name,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${addr.district?.name ?? ''}, ${addr.city?.name ?? ''} • ${addr.phone}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
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

  void _openSenderModal(BuildContext context, CreateCargoState state, CreateCargoNotifier notifier) {
    final isSend = state.direction == 'send' || state.direction == '1';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSend ? 'GÖNDERİCİ DEPO SEÇİN' : 'VARIŞ DEPOSU SEÇİN',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(ctx),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: state.senderAddresses.isEmpty
                    ? Center(
                        child: Text(
                          isSend ? 'Kayıtlı gönderici depo adresi bulunamadı.' : 'Kayıtlı varış depo adresi bulunamadı.',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: state.senderAddresses.length,
                        separatorBuilder: (context, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final addr = state.senderAddresses[index];
                          final isSelected = state.selectedSenderAddress?.id == addr.id;
                          return Material(
                            color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                                width: isSelected ? 2 : 1.5,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                notifier.setSenderAddress(addr);
                                notifier.calculateOffers();
                                Navigator.pop(ctx);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                addr.name,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w900,
                                                  color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF0F172A),
                                                ),
                                              ),
                                              if (addr.isDefault) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFE2E8F0),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Text(
                                                    'VARSAYILAN',
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w900,
                                                      color: Color(0xFF1E293B),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${addr.district?.name ?? ''}, ${addr.city?.name ?? ''} • ${addr.phone}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 20),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    AddSenderAddressModal.show(context, state.cities, notifier);
                  },
                  icon: const Icon(Icons.add_rounded, size: 18, color: Color(0xFF2563EB)),
                  label: const Text(
                    'YENİ DEPO EKLE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2563EB),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createCargoProvider);
    final notifier = ref.read(createCargoProvider.notifier);
    final productsState = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate-100
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 16,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A), size: 22),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Yeni Kargo Oluştur',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.5),
          child: Divider(height: 1.5, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: (state.isLoadingCities && state.cities.isEmpty)
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // YÖN SEÇİMİ: Kargo Gönder / Kargo Bana Gelsin
                          _buildDirectionSwitch(state, notifier),
                          const SizedBox(height: 14),

                          // 1. GÖNDERİ VE ÖDEME TÜRÜ
                          _buildDeliveryTypeSection(state, notifier),
                          const SizedBox(height: 14),

                          // 2. ADRES BİLGİLERİ
                          _buildAddressSection(state, notifier),
                          const SizedBox(height: 14),

                          // 3. PAKET & SİPARİŞ DETAYLARI
                          _buildPackageDetailsSection(state, notifier, productsState.products),
                          const SizedBox(height: 14),

                          // 4. KARGO FİRMASI SEÇİMİ
                          _buildCarrierOffersSection(state, notifier),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),

                  // SABİT ALT AKSİYON BARI
                  _buildStickyBottomBar(context, state, notifier),
                ],
              ),
            ),
    );
  }

  // BÖLÜM 1: GÖNDERİ TÜRÜ & KAPIDA ÖDEME
  Widget _buildDeliveryTypeSection(CreateCargoState state, CreateCargoNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE11D48),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '1. GÖNDERİ VE ÖDEME TÜRÜ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ZORUNLU',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE11D48),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3'lü Kalın Pill Butonlar
          Container(
            padding: const EdgeInsets.all(3.5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Row(
              children: [
                _buildPillButton(
                  title: 'Standart',
                  isSelected: _deliveryType == 'standard',
                  selectedColor: const Color(0xFF0F172A),
                  onTap: () => _setDeliveryType('standard'),
                ),
                const SizedBox(width: 4),
                _buildPillButton(
                  title: 'Kapıda Ödeme',
                  isSelected: _deliveryType == 'pod',
                  selectedColor: const Color(0xFFE11D48),
                  onTap: () => _setDeliveryType('pod'),
                ),
                const SizedBox(width: 4),
                _buildPillButton(
                  title: 'Alıcı Öder',
                  isSelected: _deliveryType == 'receiver',
                  selectedColor: const Color(0xFF4F46E5),
                  onTap: () => _setDeliveryType('receiver'),
                ),
              ],
            ),
          ),

          // Kapıda Ödeme Dinamik Açılan Detay Alanı
          if (_deliveryType == 'pod') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFFECDD3),
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tutar Girişi (Büyük & Vurgulu)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFDA4AF), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TAHSİL EDİLECEK TUTAR (₺):',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF881337),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Alıcıdan Alınacak',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFBE123C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _podAmountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                          decoration: InputDecoration(
                            suffixText: ' ₺',
                            suffixStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFBE123C),
                            ),
                            hintText: '0.00',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFFDA4AF), width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFFDA4AF), width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE11D48), width: 2),
                            ),
                          ),
                          onChanged: (val) {
                            final parsed = AppFormatters.parseDouble(val);
                            notifier.updateAdditionalServices(payOnDeliveryAmount: parsed);
                            notifier.calculateOffers();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Ödeme Alma Şekli
                  const Text(
                    'ÖDEME ALMA ŞEKLİ:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPodTypeOption(
                          title: 'Nakit Tahsilat',
                          isSelected: state.payOnDeliveryType == 'cash',
                          onTap: () {
                            notifier.updateAdditionalServices(payOnDeliveryType: 'cash');
                            notifier.calculateOffers();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPodTypeOption(
                          title: 'Kredi Kartı',
                          isSelected: state.payOnDeliveryType == 'credit_card',
                          onTap: () {
                            notifier.updateAdditionalServices(payOnDeliveryType: 'credit_card');
                            notifier.calculateOffers();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Mahsup Seçeneği
                  Material(
                    color: const Color(0xFFF8FAFC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        notifier.updateAdditionalServices(canOffsetCargoFee: !state.canOffsetCargoFee);
                        notifier.calculateOffers();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: state.canOffsetCargoFee,
                                activeColor: const Color(0xFFE11D48),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (val) {
                                  notifier.updateAdditionalServices(canOffsetCargoFee: val ?? false);
                                  notifier.calculateOffers();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kargo Taşıma Ücreti Tahsilattan Düşülsün',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                      height: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Kargo bedeli cüzdanınızdan değil, müşteriden toplanan paradan kesilir.',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF64748B),
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Ek Hizmet: Kontrollü Teslimat (Yalnızca PTT Kargo)
          const SizedBox(height: 10),
          Material(
            color: const Color(0xFFF8FAFC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: state.controlledDelivery ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                notifier.updateAdditionalServices(controlledDelivery: !state.controlledDelivery);
                notifier.calculateOffers();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Kontrollü Teslimat',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: state.controlledDelivery ? const Color(0xFF1E40AF) : const Color(0xFF0F172A),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'PTT KARGO',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Alıcı kargoyu teslim almadan önce açıp içeriği kontrol edebilir.',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: state.controlledDelivery,
                      activeTrackColor: const Color(0xFF2563EB),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (val) {
                        notifier.updateAdditionalServices(controlledDelivery: val);
                        notifier.calculateOffers();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillButton({
    required String title,
    required bool isSelected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: selectedColor.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w800,
              color: isSelected ? Colors.white : const Color(0xFF334155),
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodTypeOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF1F2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFE11D48) : const Color(0xFFCBD5E1),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              size: 16,
              color: isSelected ? const Color(0xFFE11D48) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: isSelected ? const Color(0xFF881337) : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // YÖN SEÇİMİ: Kargo Gönder / Kargo Bana Gelsin
  Widget _buildDirectionSwitch(CreateCargoState state, CreateCargoNotifier notifier) {
    final isSend = state.direction == 'send' || state.direction == '1';

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                if (!isSend) {
                  notifier.setDirection('send');
                  notifier.calculateOffers();
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSend ? const Color(0xFF2563EB) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSend
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 15,
                      color: isSend ? Colors.white : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Kargo Gönder',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isSend ? Colors.white : const Color(0xFF64748B),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: () {
                if (isSend) {
                  notifier.setDirection('receive');
                  if (_deliveryType != 'standard') {
                    _setDeliveryType('standard');
                  }
                  notifier.calculateOffers();
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: !isSend ? const Color(0xFF2563EB) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !isSend
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      size: 15,
                      color: !isSend ? Colors.white : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Kargo Bana Gelsin',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: !isSend ? Colors.white : const Color(0xFF64748B),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BÖLÜM 2: ADRES BİLGİLERİ (İki Ayrı Sade Kart Yapısı)
  Widget _buildAddressSection(CreateCargoState state, CreateCargoNotifier notifier) {
    final isSend = state.direction == 'send' || state.direction == '1';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '2',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'ADRES BİLGİLERİ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // KART 1: GÖNDERİCİ BİLGİLERİ
          _buildSenderAddressCard(state, notifier, isSend),
          const SizedBox(height: 12),

          // KART 2: ALICI BİLGİLERİ
          _buildReceiverAddressCard(state, notifier, isSend),
        ],
      ),
    );
  }

  Widget _buildWarehouseEmptyCard(BuildContext context, CreateCargoState state, CreateCargoNotifier notifier, bool isSend) {
    final title = isSend ? 'Gönderici Deposu Seçiniz' : 'Varış Deposu Seçiniz';
    final subtitle = isSend ? 'Kargonuzun çıkış yapacağı deponuzu seçin' : 'Kargonuzun teslim alınacağı deponuzu seçin';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
            ),
            child: const Icon(
              Icons.warehouse_rounded,
              color: Color(0xFF2563EB),
              size: 26,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _openSenderModal(context, state, notifier),
              icon: const Icon(Icons.warehouse_rounded, size: 20),
              label: const Text(
                'Depo Seç',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => AddSenderAddressModal.show(context, state.cities, notifier),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Text(
                '+ Yeni Depo Ekle',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseSelectedCard(BuildContext context, CreateCargoState state, CreateCargoNotifier notifier, bool isSend) {
    final senderName = state.selectedSenderAddress!.name;
    final senderLocation = '${state.selectedSenderAddress!.district?.name ?? state.selectedSenderAddress!.city?.name ?? ""}'
        '${state.selectedSenderAddress!.phone.isNotEmpty ? " • ${state.selectedSenderAddress!.phone}" : ""}';
    final details = state.selectedSenderAddress!.details;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2563EB), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.warehouse_rounded,
              color: Color(0xFF1E40AF),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        senderName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (state.selectedSenderAddress!.isDefault) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'VARSAYILAN',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  senderLocation,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    details,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: const Size(0, 34),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => _openSenderModal(context, state, notifier),
                child: const Text(
                  'Değiştir',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () {
                  notifier.setSenderAddress(null);
                  notifier.calculateOffers();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Kaldır',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSenderAddressCard(CreateCargoState state, CreateCargoNotifier notifier, bool isSend) {
    if (isSend) {
      // Standart Mod: Gönderici = Kullanıcının Deposu
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.storefront_outlined, size: 18, color: Color(0xFF2563EB)),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Gönderici Bilgileri',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => AddSenderAddressModal.show(context, state.cities, notifier),
                  child: const Text(
                    '+ Yeni Depo',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            state.selectedSenderAddress == null
                ? _buildWarehouseEmptyCard(context, state, notifier, true)
                : _buildWarehouseSelectedCard(context, state, notifier, true),
          ],
        ),
      );
    } else {
      // Tersine Lojistik: Gönderici = Dış Müşteri / Tedarikçi
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_pin_circle_outlined, size: 18, color: Color(0xFF2563EB)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Gönderici Müşteri Bilgileri',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildCustomerFormFields(state, notifier, isSenderMode: true),
          ],
        ),
      );
    }
  }

  Widget _buildReceiverAddressCard(CreateCargoState state, CreateCargoNotifier notifier, bool isSend) {
    if (isSend) {
      // Standart Mod: Alıcı = Dış Müşteri
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_pin_circle_outlined, size: 18, color: Color(0xFF2563EB)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Alıcı Müşteri Bilgileri',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildCustomerFormFields(state, notifier, isSenderMode: false),
          ],
        ),
      );
    } else {
      // Tersine Lojistik: Alıcı = Kullanıcının Deposu (Varış Deposu)
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.warehouse_outlined, size: 18, color: Color(0xFF2563EB)),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Varış Deposu Bilgileri',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => AddSenderAddressModal.show(context, state.cities, notifier),
                  child: const Text(
                    '+ Yeni Depo',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            state.selectedSenderAddress == null
                ? _buildWarehouseEmptyCard(context, state, notifier, false)
                : _buildWarehouseSelectedCard(context, state, notifier, false),
          ],
        ),
      );
    }
  }

  Widget _buildCustomerFormFields(CreateCargoState state, CreateCargoNotifier notifier, {required bool isSenderMode}) {
    final nameLabel = isSenderMode ? 'GÖNDERİCİ AD SOYAD *' : 'ALICI AD SOYAD *';
    final addressLabel = isSenderMode ? 'ÇIKIŞ ADRESİ *' : 'TESLİMAT ADRESİ *';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kayıtlı Rehberden Seç Butonu (Büyük, Şık, Kolay Tıklanabilir)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _openDirectoryModal(context, state, notifier),
            icon: const Icon(Icons.contacts_rounded, size: 20, color: Colors.white),
            label: Text(
              isSenderMode ? 'Kayıtlı Gönderici Rehberinden Seç' : 'Kayıtlı Alıcı Rehberinden Seç',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        if (state.selectedRecipientAddress != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF93C5FD), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rehberden Seçildi: ${state.selectedRecipientAddress!.name}',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E40AF),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (state.selectedRecipientAddress!.phone.isNotEmpty || state.selectedRecipientAddress!.city != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${state.selectedRecipientAddress!.phone} • ${state.selectedRecipientAddress!.district?.name ?? ''}, ${state.selectedRecipientAddress!.city?.name ?? ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () => _openDirectoryModal(context, state, notifier),
                        icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: Color(0xFF2563EB)),
                        label: const Text(
                          'Farklı Kişi Seç',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () => notifier.clearSelectedRecipientAddress(),
                        icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF475569)),
                        label: const Text(
                          'Manuel Düzenle',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nameLabel,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'Ad Soyad',
                      hintStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                      ),
                    ),
                    onChanged: (val) => notifier.updateRecipientInfo(name: val, clearSelectedRecipient: true),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TELEFON NO *',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: '05xx xxx xx xx',
                      hintStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                      ),
                    ),
                    onChanged: (val) => notifier.updateRecipientInfo(phone: val, clearSelectedRecipient: true),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'İL (ŞEHİR) *',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<City>(
                    key: ValueKey('city_${state.selectedCity?.id}'),
                    menuMaxHeight: 250,
                    isExpanded: true,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                      ),
                    ),
                    hint: const Text('Şehir Seçiniz', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                    initialValue: state.cities.any((c) => c.id == state.selectedCity?.id)
                        ? state.cities.firstWhere((c) => c.id == state.selectedCity?.id)
                        : null,
                    items: state.cities.map((city) {
                      return DropdownMenuItem<City>(
                        value: city,
                        child: Text(city.name, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (city) {
                      notifier.selectCity(city);
                      notifier.calculateOffers();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'İLÇE *',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<District>(
                    key: ValueKey('district_${state.selectedCity?.id}_${state.selectedDistrict?.id}'),
                    menuMaxHeight: 250,
                    isExpanded: true,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                      ),
                    ),
                    hint: Text(
                      state.isLoadingDistricts ? 'Yükleniyor...' : 'İlçe Seçiniz',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                    ),
                    initialValue: state.districts.any((d) => d.id == state.selectedDistrict?.id)
                        ? state.districts.firstWhere((d) => d.id == state.selectedDistrict?.id)
                        : null,
                    items: state.districts.map((dist) {
                      return DropdownMenuItem<District>(
                        value: dist,
                        child: Text(dist.name, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: state.selectedCity == null
                        ? null
                        : (dist) {
                            notifier.selectDistrict(dist);
                            notifier.calculateOffers();
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              addressLabel,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _addressController,
              maxLines: 2,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'Cadde, sokak, bina no, daire, tarif...',
                hintStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                ),
              ),
              onChanged: (val) => notifier.updateRecipientInfo(details: val, clearSelectedRecipient: true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickDesiChip(String label, double desi, CreateCargoNotifier notifier) {
    final isSelected = (_calculatedDesi - desi).abs() < 0.01;
    return GestureDetector(
      onTap: () {
        if (desi == 0.0) {
          _widthController.text = '0';
          _lengthController.text = '0';
          _heightController.text = '0';
          _weightController.text = '0';
          _desiController.text = '0.00';
          setState(() {
            _calculatedDesi = 0.0;
          });
          notifier.updatePackageDimensions(
            width: 0,
            length: 0,
            height: 0,
            weight: 0,
            directDesi: 0.0,
          );
        } else {
          final side = math.pow(desi * 3000, 1 / 3).toDouble();
          final sideStr = side.toStringAsFixed(1);
          _widthController.text = sideStr;
          _lengthController.text = sideStr;
          _heightController.text = sideStr;
          _weightController.text = '1';
          _desiController.text = desi.toStringAsFixed(2);
          setState(() {
            _calculatedDesi = desi;
          });
          notifier.updatePackageDimensions(
            width: side,
            length: side,
            height: side,
            weight: 1000,
            directDesi: desi,
          );
        }
        notifier.calculateOffers();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF059669) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF059669) : const Color(0xFFCBD5E1),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  // BÖLÜM 3: PAKET & SİPARİŞ DETAYLARI
  Widget _buildPackageDetailsSection(
    CreateCargoState state,
    CreateCargoNotifier notifier,
    List<ProductModel> products,
  ) {
    ProductModel? matchedProduct;
    if (state.selectedProduct != null) {
      matchedProduct = products.cast<ProductModel?>().firstWhere(
        (p) => p?.id == state.selectedProduct?.id,
        orElse: () => null,
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '3',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'PAKET & SİPARİŞ DETAYLARI',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _showDesiInputDialog(notifier),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF6EE7B7), width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_calculatedDesi.toStringAsFixed(2)} DESİ',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF065F46),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF065F46)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. Paket Ölçüleri (En, Boy, Yükseklik ve Ağırlık) - Birincil ve Kolay Giriş
          const Text(
            'PAKET ÖLÇÜLERİ VE AĞIRLIK:',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFF475569),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Ölçüleri giriniz; desi hacim formülüyle ((En x Boy x Yükseklik) / 3000) otomatik hesaplanır.',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),

          // 2x2 Temiz, Ferah ve Anlaşılır Boyut Grid'i (En, Boy / Yükseklik, Ağırlık)
          Row(
            children: [
              _buildDimensionInput('EN (CM)', _widthController, 'Örn: 20'),
              const SizedBox(width: 10),
              _buildDimensionInput('BOY (CM)', _lengthController, 'Örn: 30'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildDimensionInput('YÜKSEKLİK (CM)', _heightController, 'Örn: 10'),
              const SizedBox(width: 10),
              _buildDimensionInput('AĞIRLIK (KG)', _weightController, 'Örn: 1.0'),
            ],
          ),
          const SizedBox(height: 10),

          // Otomatik Hesaplanan Desi & Hızlı Evrak Seçimi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.calculate_outlined, size: 18, color: Color(0xFF16A34A)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Hesaplanan Desi: ${_calculatedDesi.toStringAsFixed(2)} Desi',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF15803D),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                _buildQuickDesiChip('Evrak (0 Desi)', 0.0, notifier),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Hızlı Kayıtlı Ürün Seçimi
          const Text(
            'KAYITLI ÜRÜNLERDEN SEÇ (İSTEĞE BAĞLI):',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ProductModel?>(
                  key: ValueKey('product_${state.selectedProduct?.id}'),
                  menuMaxHeight: 250,
                  isExpanded: true,
                  initialValue: matchedProduct,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<ProductModel?>(
                      value: null,
                      child: Text('Özel / Manuel Paket Boyutu', overflow: TextOverflow.ellipsis),
                    ),
                    ...products.map((p) {
                      return DropdownMenuItem<ProductModel?>(
                        value: p,
                        child: Text(
                          '${p.name} (${p.desi.toStringAsFixed(1)} Desi - ${AppFormatters.formatCurrency(p.price)})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                  onChanged: (p) {
                    if (p != null) {
                      _populateFromProduct(p);
                    } else {
                      _clearSelectedProduct();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                ),
                child: IconButton(
                  tooltip: 'Yeni Ürün Ekle',
                  icon: const Icon(Icons.add_rounded, size: 22, color: Color(0xFF0F172A)),
                  onPressed: () => AddEditProductModal.show(context, ref),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Sipariş No & İçerik Açıklaması
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SİPARİŞ / FATURA NO',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _orderNumberController,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'Örn: TY-84920',
                        hintStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                        ),
                      ),
                      onChanged: (val) => notifier.updatePackageNotes(orderNumber: val),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KARGO İÇERİK / ETİKET',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _descriptionController,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'Örn: Tekstil, Ayakkabı',
                        hintStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                        ),
                      ),
                      onChanged: (val) => notifier.updatePackageNotes(description: val),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionInput(String label, TextEditingController controller, [String? hint]) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Color(0xFF475569),
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
                ),
              ),
              onChanged: (_) => _calculateDesi(),
            ),
          ],
        ),
      ),
    );
  }

  // BÖLÜM 4: CANLI KARGO TEKLİFLERİ
  Widget _buildCarrierOffersSection(CreateCargoState state, CreateCargoNotifier notifier) {
    double minPrice = 0.0;
    if (state.offers.isNotEmpty) {
      minPrice = state.offers.map((o) => o.price).reduce(math.min);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '4',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'KARGO FİRMASI SEÇİMİ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'CANLI TARİFELER',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6D28D9),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (state.isLoadingOffers)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  CircularProgressIndicator(color: Color(0xFF7C3AED), strokeWidth: 2.5),
                  SizedBox(height: 10),
                  Text(
                    'Anlık kargo tarifeleri hesaplanıyor...',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          else if (state.offers.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Text(
                    'Tarife bulunamadı.',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => notifier.calculateOffers(),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Teklifleri Yenile', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.offers.length,
              separatorBuilder: (context, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final offer = state.offers[index];
                final isSelected = state.selectedOffer != null &&
                    state.selectedOffer!.cargoCompany.id.toString() == offer.cargoCompany.id.toString();
                // KULLANICI AÇIK TALİMATI: En hızlı olan önemli değil, sadece en uygun fiyatlı olanı belirtmemiz yeterli!
                final isCheapest = state.offers.length > 1 && (offer.price - minPrice).abs() < 0.01;

                return Material(
                  color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                      width: isSelected ? 3.0 : 1.5,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => notifier.selectOffer(offer),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      child: Row(
                        children: [
                          CargoCompanyLogo(
                            companyId: offer.cargoCompany.id.toString(),
                            companyName: offer.cargoCompany.title,
                            width: 76,
                            height: 32,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        offer.cargoCompany.title,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF0F172A),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // Yalnızca en ucuz olan teklife EN UYGUN FİYAT rozeti verilir
                                    if (isCheapest) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF059669),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: const Text(
                                          'EN UYGUN FİYAT',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getCarrierDeliverySubtitle(offer.cargoCompany.id.toString()),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 130),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: state.receiverPays
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              AppFormatters.formatCurrency(offer.price),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF94A3B8),
                                                decoration: TextDecoration.lineThrough,
                                                decorationColor: Color(0xFF94A3B8),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '0,00 ₺',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                                color: isCheapest ? const Color(0xFF059669) : const Color(0xFF2563EB),
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          AppFormatters.formatCurrency(offer.price),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: isCheapest ? const Color(0xFF059669) : const Color(0xFF0F172A),
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                ),
                                Text(
                                  state.receiverPays ? 'ALICI ÖDER' : 'KDV DAHİL',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: state.receiverPays ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  String _getCarrierDeliverySubtitle(String rawId) {
    final lower = rawId.toLowerCase();
    if (lower.contains('hepsijet')) return 'Ertesi Gün Teslimat';
    if (lower.contains('surat')) return '1-2 İş Günü';
    if (lower.contains('ptt')) return '2-3 İş Günü';
    if (lower.contains('kolay')) return 'Adresten Kurye Alımı';
    if (lower.contains('yurtici')) return '1-2 İş Günü';
    return '1-3 İş Günü';
  }

  // ALT SABİT ONAY BARI
  Widget _buildStickyBottomBar(BuildContext context, CreateCargoState state, CreateCargoNotifier notifier) {
    final carrierTitle = state.selectedOffer != null
        ? state.selectedOffer!.cargoCompany.title
        : 'Firma Seçiniz';
    final totalPrice = state.receiverPays ? 0.0 : (state.selectedOffer?.price ?? 0.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SEÇİLEN FİRMA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        carrierTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'TOPLAM KARGO BEDELİ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          AppFormatters.formatCurrency(totalPrice),
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Taslak Olarak Kaydet Butonu
                Container(
                  width: 52,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                  ),
                  child: IconButton(
                    tooltip: 'Taslak Olarak Kaydet',
                    icon: const Icon(Icons.bookmark_add_outlined, color: Color(0xFF0F172A), size: 22),
                    onPressed: state.isSubmitting ? null : () => _submitCargoForm(isDraft: true),
                  ),
                ),
                const SizedBox(width: 10),
                // Kargoyu Oluştur Butonu
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.3),
                      ),
                      onPressed: state.isSubmitting ? null : () => _submitCargoForm(isDraft: false),
                      child: state.isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'KARGOYU OLUŞTUR',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}