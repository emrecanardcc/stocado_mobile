import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_error_state.dart';
import '../models/product_model.dart';
import '../providers/products_provider.dart';
import '../widgets/add_edit_product_modal.dart';
import '../widgets/product_card.dart';
import '../widgets/product_empty_state.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final ScrollController _productsScrollController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _productsScrollController = ScrollController();
    _productsScrollController.addListener(_handleProductsScroll);
  }

  void _handleProductsScroll() {
    if (_productsScrollController.position.pixels >= _productsScrollController.position.maxScrollExtent - 200) {
      ref.read(productsProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _productsScrollController.dispose();
    super.dispose();
  }

  void _confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
            SizedBox(width: 8),
            Text('Ürünü Sil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          '"${product.name}" ürününü envanterinizden silmek istediğinize emin misiniz?',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(90, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await ref.read(productsProvider.notifier).deleteProduct(product.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message ?? (result.isSuccess ? 'Ürün başarıyla silindi.' : 'Silme işlemi gerçekleştirilemedi.')),
                    backgroundColor: result.isSuccess ? AppColors.secondary : AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            child: const Text('Sil', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final productsNotifier = ref.read(productsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.inventory_2_outlined, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Kayıtlı Ürünlerim',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddEditProductModal.show(context, ref),
        backgroundColor: AppColors.primary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Yeni Ürün', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Arama ve Filtre Çubuğu
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.softShadow,
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Ürün adı, kod veya barkod ara...',
                        hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      onChanged: (val) {
                        _debounceTimer?.cancel();
                        _debounceTimer = Timer(const Duration(milliseconds: 350), () {
                          productsNotifier.setSearch(val.trim());
                        });
                        setState(() {});
                      },
                      onSubmitted: (val) {
                        _debounceTimer?.cancel();
                        productsNotifier.setSearch(val.trim());
                      },
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _debounceTimer?.cancel();
                        _searchController.clear();
                        productsNotifier.setSearch('');
                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
          ),

          // Ürün Listesi
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => productsNotifier.refresh(),
              color: AppColors.primary,
              child: productsState.isLoading && productsState.products.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : productsState.errorMessage != null && productsState.products.isEmpty
                      ? AppErrorState(
                          title: 'Ürünler Yüklenemedi',
                          message: productsState.errorMessage!,
                          onRetry: () => productsNotifier.refresh(),
                        )
                      : productsState.products.isEmpty
                          ? ProductEmptyState(onAddProduct: () => AddEditProductModal.show(context, ref))
                          : ListView.builder(
                              controller: _productsScrollController,
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: productsState.products.length + (productsState.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == productsState.products.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20.0),
                                    child: Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                      ),
                                    ),
                                  );
                                }

                                final product = productsState.products[index];
                                return ProductCard(
                                  product: product,
                                  onEdit: () => AddEditProductModal.show(context, ref, product: product),
                                  onDelete: () => _confirmDelete(product),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}
