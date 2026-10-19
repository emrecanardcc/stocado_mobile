import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../products/models/product_model.dart';
import '../providers/create_cargo_provider.dart';

class Step2PackageWidget extends StatelessWidget {
  final CreateCargoState state;
  final CreateCargoNotifier notifier;
  final List<ProductModel> products;
  final TextEditingController orderNumberController;
  final TextEditingController descriptionController;
  final TextEditingController widthController;
  final TextEditingController lengthController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final TextEditingController desiController;
  final void Function(ProductModel product) onProductSelected;
  final VoidCallback onClearProduct;

  const Step2PackageWidget({
    super.key,
    required this.state,
    required this.notifier,
    required this.products,
    required this.orderNumberController,
    required this.descriptionController,
    required this.widthController,
    required this.lengthController,
    required this.heightController,
    required this.weightController,
    required this.desiController,
    required this.onProductSelected,
    required this.onClearProduct,
  });

  @override
  Widget build(BuildContext context) {
    ProductModel? matchedProduct;
    if (state.selectedProduct != null) {
      matchedProduct = products.cast<ProductModel?>().firstWhere(
        (p) => p?.id == state.selectedProduct?.id,
        orElse: () => null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Ürün Seçin" Dropdown
        const Text(
          'Ürün Seçimi (Opsiyonel)',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<ProductModel?>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: Text(products.isEmpty ? 'Kayıtlı ürün bulunamadı veya yükleniyor...' : 'Ürünlerim sayfasından bir ürün seçin...'),
                  value: matchedProduct,
                  items: products.map((prod) {
                    return DropdownMenuItem<ProductModel?>(
                      value: prod,
                      child: Text(
                        '${prod.name} (${prod.desi.toStringAsFixed(1)} Desi - ₺${prod.price.toStringAsFixed(2)})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (prod) {
                    if (prod != null) {
                      onProductSelected(prod);
                    } else {
                      onClearProduct();
                    }
                  },
                ),
              ),
              if (matchedProduct != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  tooltip: 'Ürün Seçimini Temizle',
                  onPressed: onClearProduct,
                ),
            ],
          ),
        ),
        if (matchedProduct != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 14, color: AppColors.secondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Seçili Ürün: ${matchedProduct.name} - Boyutlar, desi ve tutar otomatik aktarıldı.',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),

        const Text(
          'Paket ve Sipariş Detayları',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: orderNumberController,
          decoration: InputDecoration(
            labelText: 'Sipariş Numarası (Opsiyonel)',
            prefixIcon: const Icon(Icons.confirmation_number_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: (val) => notifier.updatePackageNotes(orderNumber: val),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: 'Açıklama (Örn: Ayakkabı kutusu)',
            prefixIcon: const Icon(Icons.description_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: (val) => notifier.updatePackageNotes(description: val),
        ),
        const SizedBox(height: 24),

        // Desi ve Boyut Girişi
        const Text(
          'Boyutlar ve Desi Bilgisi',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widthController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'En (cm)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (val) => notifier.updatePackageDimensions(width: double.tryParse(val) ?? 0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: lengthController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Boy (cm)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (val) => notifier.updatePackageDimensions(length: double.tryParse(val) ?? 0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Yükseklik (cm)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (val) => notifier.updatePackageDimensions(height: double.tryParse(val) ?? 0),
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
                decoration: InputDecoration(
                  labelText: 'Ağırlık (Gram)',
                  hintText: 'Örn: 1500',
                  prefixIcon: const Icon(Icons.scale_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (val) => notifier.updatePackageDimensions(weight: double.tryParse(val) ?? 0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: desiController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Doğrudan Desi (Opsiyonel)',
                  prefixIcon: const Icon(Icons.straighten),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (val) {
                  final d = double.tryParse(val);
                  if (d != null) {
                    notifier.updatePackageDimensions(directDesi: d);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Canlı Desi Gösterge Kartı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hesaplanan Desi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  Text('(En x Boy x Yükseklik) / 3000', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              Text(
                state.desi.toStringAsFixed(2),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
