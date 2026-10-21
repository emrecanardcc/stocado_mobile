import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../home/providers/navigation_provider.dart';
import '../../products/models/product_model.dart';
import '../../products/providers/products_provider.dart';
import '../../products/widgets/add_edit_product_modal.dart';
import '../../products/widgets/product_card.dart';
import '../../products/widgets/product_empty_state.dart';
import '../providers/pricing_provider.dart';
import '../widgets/pricing_empty_state.dart';
import '../widgets/pricing_plan_card.dart';

class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({super.key});

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  late final ScrollController _productsScrollController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final initialSubIndex = ref.read(mainNavigationProvider).hubSubIndex;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialSubIndex);
    _tabController.addListener(_handleTabChange);

    _productsScrollController = ScrollController();
    _productsScrollController.addListener(_handleProductsScroll);
  }

  void _handleTabChange() {
    if (mounted) {
      setState(() {});
      ref.read(mainNavigationProvider.notifier).selectHubSubIndex(_tabController.index);
    }
  }

  void _handleProductsScroll() {
    if (_productsScrollController.position.pixels >= _productsScrollController.position.maxScrollExtent - 200) {
      ref.read(productsProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
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
              final success = await ref.read(productsProvider.notifier).deleteProduct(product.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Ürün başarıyla silindi.' : 'Silme işlemi başarısız oldu.'),
                    backgroundColor: success ? AppColors.secondary : AppColors.error,
                    behavior: SnackBarBehavior.floating,
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

  Widget _buildSegmentItem({required int index, required String title, required IconData icon}) {
    final isSelected = _tabController.index == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
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
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingTab() {
    final pricingState = ref.watch(pricingProvider);
    final pricingNotifier = ref.read(pricingProvider.notifier);

    if (pricingState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
            SizedBox(height: 16),
            Text(
              'Anlaşmalı kargo tarifeleri yükleniyor...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (pricingState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.errorLight,
                ),
                child: const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error),
              ),
              const SizedBox(height: 16),
              Text(
                pricingState.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => pricingNotifier.refresh(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Tekrar Dene'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(160, 44)),
              ),
            ],
          ),
        ),
      );
    }

    if (pricingState.plans.isEmpty) {
      return PricingEmptyState(onRefresh: () => pricingNotifier.refresh());
    }

    return RefreshIndicator(
      onRefresh: () => pricingNotifier.refresh(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: pricingState.plans.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Desi Hesaplama Rehber Kartı
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Desi = (En × Boy × Yükseklik) / 3000 • Fiyatlar KDV dahil net tutarlardır.',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            );
          }
          final plan = pricingState.plans[index - 1];
          return PricingPlanCard(plan: plan);
        },
      ),
    );
  }

  Widget _buildProductsTab() {
    final productsState = ref.watch(productsProvider);
    final productsNotifier = ref.read(productsProvider.notifier);

    return Column(
      children: [
        // Arama ve Bilgi Çubuğu
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

        // Ürün Sayısı & Listesi
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => productsNotifier.refresh(),
            color: AppColors.primary,
            child: productsState.isLoading && productsState.products.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Navigasyon durumunu dinleyerek dışarıdan gelen sekme değişimlerine tepki ver
    ref.listen(mainNavigationProvider, (prev, next) {
      if (next.tabIndex == 3 && next.hubSubIndex != _tabController.index) {
        _tabController.animateTo(next.hubSubIndex);
      }
    });

    final isProductsTab = _tabController.index == 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              isProductsTab ? Icons.inventory_2_outlined : Icons.receipt_long_outlined,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(isProductsTab ? 'Kayıtlı Ürünlerim' : 'Fiyat Tarifeleri'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yenile',
            onPressed: () {
              if (isProductsTab) {
                ref.read(productsProvider.notifier).refresh();
              } else {
                ref.read(pricingProvider.notifier).refresh();
              }
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: isProductsTab
          ? FloatingActionButton.extended(
              onPressed: () => AddEditProductModal.show(context, ref),
              backgroundColor: AppColors.primary,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Yeni Ürün', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            )
          : null,
      body: Column(
        children: [
          // Segmented Switcher Hub (Tarifeler vs Kayıtlı Ürünler)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                children: [
                  _buildSegmentItem(index: 0, title: 'Fiyat Tarifeleri', icon: Icons.receipt_long_rounded),
                  _buildSegmentItem(index: 1, title: 'Kayıtlı Ürünlerim', icon: Icons.inventory_2_rounded),
                ],
              ),
            ),
          ),

          // Hub Sekme İçerikleri
          Expanded(
            child: AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                if (_tabController.index == 0) {
                  return _buildPricingTab();
                } else {
                  return _buildProductsTab();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
