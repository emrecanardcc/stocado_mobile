import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
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
  final VoidCallback? onAddNewProduct;

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
    this.onAddNewProduct,
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
        // "Ürün Seçin" Başlık & Hızlı Ekleme Butonu
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Kayıtlı Ürün Seçimi (Opsiyonel)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onAddNewProduct != null)
              TextButton.icon(
                onPressed: onAddNewProduct,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.primary),
                label: const Text(
                  'Yeni Ürün',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.softShadow,
          ),
          child: Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButton<ProductModel?>(
                  isExpanded: true,
                  menuMaxHeight: 220,
                  underline: const SizedBox(),
                  hint: Text(
                    products.isEmpty
                        ? 'Kayıtlı ürün bulunamadı veya yükleniyor...'
                        : 'Ürünlerim sayfasından bir ürün seçin...',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  value: matchedProduct,
                  items: products.map((prod) {
                    return DropdownMenuItem<ProductModel?>(
                      value: prod,
                      child: Text(
                        '${prod.name} (${AppFormatters.formatDesi(prod.desi)} - ${AppFormatters.formatCurrency(prod.price)})',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                  tooltip: 'Ürün Seçimini Temizle',
                  onPressed: onClearProduct,
                ),
            ],
          ),
        ),
        if (matchedProduct != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.secondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Seçili Ürün: ${matchedProduct.name} (Boyutlar, desi ve tutar otomatik dolduruldu)',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF065F46)),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),

        // Paket ve Sipariş Detayları Kartı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paket ve Sipariş Detayları',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: orderNumberController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Sipariş Numarası (Opsiyonel)',
                  prefixIcon: Icon(Icons.confirmation_number_outlined, size: 20),
                ),
                onChanged: (val) => notifier.updatePackageNotes(orderNumber: val),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama (Örn: Ayakkabı kutusu)',
                  prefixIcon: Icon(Icons.description_outlined, size: 20),
                ),
                onChanged: (val) => notifier.updatePackageNotes(description: val),
              ),
              const SizedBox(height: 20),

              // Desi ve Boyut Girişi
              const Text(
                'Boyutlar ve Desi Bilgisi',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widthController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'En (cm)',
                      ),
                      onChanged: (val) => notifier.updatePackageDimensions(width: AppFormatters.parseDouble(val)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: lengthController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Boy (cm)',
                      ),
                      onChanged: (val) => notifier.updatePackageDimensions(length: AppFormatters.parseDouble(val)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: heightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Yükseklik',
                      ),
                      onChanged: (val) => notifier.updatePackageDimensions(height: AppFormatters.parseDouble(val)),
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
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Ağırlık (Gram)',
                        hintText: 'Örn: 1500',
                        prefixIcon: Icon(Icons.scale_outlined, size: 20),
                      ),
                      onChanged: (val) => notifier.updatePackageDimensions(weight: AppFormatters.parseDouble(val)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: desiController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Doğrudan Desi',
                        prefixIcon: Icon(Icons.straighten_rounded, size: 20),
                      ),
                      onChanged: (val) {
                        final d = AppFormatters.tryParseDouble(val);
                        if (d != null) {
                          notifier.updatePackageDimensions(directDesi: d);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Canlı Desi Gösterge Kartı
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hesaplanan Desi Değeri',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Standart Kargo Formülü: (E x B x Y) / 3000',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Text(
                      state.desi.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
