import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../models/product_model.dart';
import '../providers/products_provider.dart';

class AddEditProductModal {
  static void show(
    BuildContext context,
    WidgetRef ref, {
    ProductModel? product,
  }) {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final codeController = TextEditingController(text: product?.code ?? '');
    final barcodeController = TextEditingController(text: product?.barcode ?? '');
    final priceController = TextEditingController(text: product != null ? product.price.toString() : '');
    final widthController = TextEditingController(text: product?.width != null ? product!.width.toString() : '');
    final lengthController = TextEditingController(text: product?.length != null ? product!.length.toString() : '');
    final heightController = TextEditingController(text: product?.height != null ? product!.height.toString() : '');
    final weightController = TextEditingController(text: product?.weight != null ? product!.weight.toString() : '');
    final desiController = TextEditingController(text: product != null && product.desi > 0 ? product.desi.toString() : '');
    double calculatedDesi = product?.desi ?? 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            void updateDesi() {
              final w = double.tryParse(widthController.text) ?? 0;
              final l = double.tryParse(lengthController.text) ?? 0;
              final h = double.tryParse(heightController.text) ?? 0;
              setModalState(() {
                if (w > 0 && l > 0 && h > 0) {
                  calculatedDesi = (w * l * h) / 3000;
                  desiController.text = calculatedDesi.toStringAsFixed(2);
                }
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
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
                          isEditing ? 'Ürünü Düzenle' : 'Yeni Ürün Ekle',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Ürün Adı *'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: codeController,
                            decoration: const InputDecoration(labelText: 'Stok Kodu (SKU)'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: barcodeController,
                            decoration: const InputDecoration(labelText: 'Barkod'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Fiyat (₺) *', prefixIcon: Icon(Icons.currency_lira)),
                    ),
                    const SizedBox(height: 16),
                    const Text('Paket ve Desi Ölçüleri', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: widthController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'En (cm)'),
                            onChanged: (_) => updateDesi(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: lengthController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Boy (cm)'),
                            onChanged: (_) => updateDesi(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: heightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Yükseklik (cm)'),
                            onChanged: (_) => updateDesi(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Ağırlık (kg)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: desiController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Desi *',
                              suffixText: 'desi',
                              helperText: calculatedDesi > 0 ? 'Ölçü Desisi: ${calculatedDesi.toStringAsFixed(2)}' : null,
                            ),
                            onChanged: (val) {
                              final d = double.tryParse(val);
                              if (d != null) {
                                setModalState(() {
                                  calculatedDesi = d;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final price = double.tryParse(priceController.text.trim()) ?? 0.0;
                        final manualDesi = double.tryParse(desiController.text.trim());
                        final finalDesi = (manualDesi != null && manualDesi > 0)
                            ? manualDesi
                            : (calculatedDesi > 0 ? calculatedDesi : (product?.desi ?? 0.0));

                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lütfen ürün adını giriniz.'), backgroundColor: AppColors.warning),
                          );
                          return;
                        }

                        final newProduct = ProductModel(
                          id: product?.id ?? '',
                          name: name,
                          code: codeController.text.trim().isNotEmpty ? codeController.text.trim() : null,
                          barcode: barcodeController.text.trim().isNotEmpty ? barcodeController.text.trim() : null,
                          price: price,
                          desi: finalDesi,
                          width: double.tryParse(widthController.text.trim()),
                          length: double.tryParse(lengthController.text.trim()),
                          height: double.tryParse(heightController.text.trim()),
                          weight: double.tryParse(weightController.text.trim()),
                        );

                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(ctx);

                        bool success;
                        if (isEditing) {
                          success = await ref.read(productsProvider.notifier).updateProduct(product.id, newProduct);
                        } else {
                          success = await ref.read(productsProvider.notifier).createProduct(newProduct);
                        }

                        if (context.mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(success ? (isEditing ? 'Ürün güncellendi!' : 'Ürün eklendi!') : 'İşlem başarısız.'),
                              backgroundColor: success ? AppColors.secondary : AppColors.error,
                            ),
                          );
                        }
                      },
                      child: Text(isEditing ? 'Güncelle' : 'Kaydet'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
