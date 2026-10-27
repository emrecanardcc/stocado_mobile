import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../models/product_model.dart';
import '../providers/products_provider.dart';

class AddEditProductModal {
  static void show(
    BuildContext context,
    WidgetRef ref, {
    ProductModel? product,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddEditProductSheetContent(product: product, ref: ref),
    );
  }
}

class _AddEditProductSheetContent extends StatefulWidget {
  final ProductModel? product;
  final WidgetRef ref;

  const _AddEditProductSheetContent({
    required this.product,
    required this.ref,
  });

  @override
  State<_AddEditProductSheetContent> createState() => _AddEditProductSheetContentState();
}

class _AddEditProductSheetContentState extends State<_AddEditProductSheetContent> {
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _priceController;
  late final TextEditingController _widthController;
  late final TextEditingController _lengthController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _desiController;
  late double _calculatedDesi;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _codeController = TextEditingController(text: p?.code ?? '');
    _barcodeController = TextEditingController(text: p?.barcode ?? '');
    _priceController = TextEditingController(text: p != null ? p.price.toString() : '');
    _widthController = TextEditingController(text: p?.width != null ? p!.width.toString() : '');
    _lengthController = TextEditingController(text: p?.length != null ? p!.length.toString() : '');
    _heightController = TextEditingController(text: p?.height != null ? p!.height.toString() : '');
    _weightController = TextEditingController(text: p?.weight != null ? p!.weight.toString() : '');
    _desiController = TextEditingController(text: p != null && p.desi > 0 ? p.desi.toString() : '');
    _calculatedDesi = p?.desi ?? 0.0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _widthController.dispose();
    _lengthController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _desiController.dispose();
    super.dispose();
  }

  void _updateDesi() {
    final w = AppFormatters.parseDouble(_widthController.text);
    final l = AppFormatters.parseDouble(_lengthController.text);
    final h = AppFormatters.parseDouble(_heightController.text);
    setState(() {
      if (w > 0 && l > 0 && h > 0) {
        _calculatedDesi = (w * l * h) / 3000;
        _desiController.text = _calculatedDesi.toStringAsFixed(2);
      }
    });
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final price = AppFormatters.parseDouble(_priceController.text);
    final manualDesi = AppFormatters.tryParseDouble(_desiController.text);
    final finalDesi = (manualDesi != null && manualDesi > 0)
        ? manualDesi
        : (_calculatedDesi > 0 ? _calculatedDesi : (widget.product?.desi ?? 0.0));

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen ürün adını giriniz.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (finalDesi <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir ürün desisi veya boyutlarını (en, boy, yükseklik) giriniz.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newProduct = ProductModel(
      id: widget.product?.id ?? '',
      name: name,
      code: _codeController.text.trim().isNotEmpty ? _codeController.text.trim() : null,
      barcode: _barcodeController.text.trim().isNotEmpty ? _barcodeController.text.trim() : null,
      price: price,
      desi: finalDesi,
      width: AppFormatters.tryParseDouble(_widthController.text),
      length: AppFormatters.tryParseDouble(_lengthController.text),
      height: AppFormatters.tryParseDouble(_heightController.text),
      weight: AppFormatters.tryParseDouble(_weightController.text),
    );

    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);

    final result = _isEditing
        ? await widget.ref.read(productsProvider.notifier).updateProduct(widget.product!.id, newProduct)
        : await widget.ref.read(productsProvider.notifier).createProduct(newProduct);

    if (mounted) {
      final defaultMsg = result.isSuccess
          ? (_isEditing ? 'Ürün başarıyla güncellendi.' : 'Ürün başarıyla eklendi.')
          : 'İşlem gerçekleştirilemedi.';
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.message ?? defaultMsg),
          backgroundColor: result.isSuccess ? AppColors.secondary : AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing ? 'Ürünü Düzenle' : 'Yeni Ürün Ekle',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Ürün Adı *'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(labelText: 'Ürün Kodu'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _barcodeController,
                    decoration: const InputDecoration(labelText: 'Barkod'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Fiyat (₺)', prefixText: '₺ '),
            ),
            const SizedBox(height: 16),
            const Text(
              'Paket ve Desi Ölçüleri',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _widthController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'En (cm)'),
                    onChanged: (_) => _updateDesi(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _lengthController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Boy (cm)'),
                    onChanged: (_) => _updateDesi(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Yükseklik (cm)'),
                    onChanged: (_) => _updateDesi(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Ağırlık (kg)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _desiController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Desi *',
                      suffixText: 'desi',
                      helperText: _calculatedDesi > 0 ? 'Ölçü Desisi: ${_calculatedDesi.toStringAsFixed(2)}' : null,
                    ),
                    onChanged: (val) {
                      final d = double.tryParse(val);
                      if (d != null) {
                        setState(() {
                          _calculatedDesi = d;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleSave,
              child: Text(_isEditing ? 'Güncelle' : 'Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
