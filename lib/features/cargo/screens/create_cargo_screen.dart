import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../products/models/product_model.dart';
import '../../products/providers/products_provider.dart';
import '../providers/create_cargo_provider.dart';
import '../widgets/cargo_bottom_bar.dart';
import '../widgets/step1_addresses_widget.dart';
import '../widgets/step2_package_widget.dart';
import '../widgets/step3_services_widget.dart';
import '../widgets/step4_offers_widget.dart';
import '../widgets/stepper_header.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsProvider.notifier).loadProducts(reset: true);
      final cargoState = ref.read(createCargoProvider);
      final cargoNotifier = ref.read(createCargoProvider.notifier);
      if (cargoState.cities.isEmpty) {
        cargoNotifier.loadCities();
      }
      if (cargoState.senderAddresses.isEmpty) {
        cargoNotifier.loadAllAddresses();
      }
    });
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
    super.dispose();
  }

  void _populateFromProduct(ProductModel product, CreateCargoNotifier notifier) {
    notifier.selectProduct(product);
    _widthController.text = (product.width != null && product.width! > 0) ? product.width!.toString() : '';
    _lengthController.text = (product.length != null && product.length! > 0) ? product.length!.toString() : '';
    _heightController.text = (product.height != null && product.height! > 0) ? product.height!.toString() : '';
    _weightController.text = (product.weight != null && product.weight! > 0) ? (product.weight! * 1000).toStringAsFixed(0) : '';

    final rawDesi = product.desi > 0
        ? product.desi
        : ((product.width ?? 0) > 0 && (product.length ?? 0) > 0 && (product.height ?? 0) > 0
            ? ((product.width! * product.length! * product.height!) / 3000)
            : 0.0);
    _desiController.text = rawDesi > 0 ? rawDesi.toStringAsFixed(2) : '';
    _descriptionController.text = product.name;
    if (product.price > 0) {
      _podAmountController.text = product.price.toStringAsFixed(2);
    } else {
      _podAmountController.clear();
    }
  }

  void _clearSelectedProduct(CreateCargoNotifier notifier) {
    notifier.selectProduct(null);
    _widthController.clear();
    _lengthController.clear();
    _heightController.clear();
    _weightController.clear();
    _desiController.clear();
    _descriptionController.clear();
    _podAmountController.clear();
  }

  void _clearAllFormFields() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _addressController.clear();
    _postalCodeController.clear();
    _desiController.clear();
    _widthController.clear();
    _lengthController.clear();
    _heightController.clear();
    _weightController.clear();
    _descriptionController.clear();
    _orderNumberController.clear();
    _podAmountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createCargoProvider);
    final notifier = ref.read(createCargoProvider.notifier);
    final productsState = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Kargo Oluştur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Formu Temizle',
            onPressed: () {
              _clearAllFormFields();
              notifier.reset();
            },
          ),
        ],
      ),
      body: (state.isLoadingCities && state.cities.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque,
              child: Column(
                children: [
                  StepperHeader(currentStep: state.currentStep),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildCurrentStep(state, notifier, productsState.products),
                    ),
                  ),
                  CargoBottomBar(
                    state: state,
                    notifier: notifier,
                    onClearForm: _clearAllFormFields,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentStep(
    CreateCargoState state,
    CreateCargoNotifier notifier,
    List<ProductModel> products,
  ) {
    switch (state.currentStep) {
      case 0:
        return Step1AddressesWidget(
          state: state,
          notifier: notifier,
          cities: state.cities,
          districts: state.districts,
          nameController: _nameController,
          phoneController: _phoneController,
          emailController: _emailController,
          addressController: _addressController,
          postalCodeController: _postalCodeController,
        );
      case 1:
        return Step2PackageWidget(
          state: state,
          notifier: notifier,
          products: products,
          orderNumberController: _orderNumberController,
          descriptionController: _descriptionController,
          widthController: _widthController,
          lengthController: _lengthController,
          heightController: _heightController,
          weightController: _weightController,
          desiController: _desiController,
          onProductSelected: (prod) => _populateFromProduct(prod, notifier),
          onClearProduct: () => _clearSelectedProduct(notifier),
        );
      case 2:
        return Step3ServicesWidget(
          state: state,
          notifier: notifier,
          podAmountController: _podAmountController,
        );
      case 3:
        return Step4OffersWidget(
          state: state,
          notifier: notifier,
        );
      default:
        return const SizedBox();
    }
  }
}