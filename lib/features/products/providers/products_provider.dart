import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/pagination_meta.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/product_model.dart';
import '../services/products_service.dart';

class ProductsState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<ProductModel> products;
  final PaginationMeta? meta;
  final String searchQuery;
  final String? errorMessage;

  const ProductsState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.products = const [],
    this.meta,
    this.searchQuery = '',
    this.errorMessage,
  });

  bool get hasMore => meta?.hasMore ?? false;
  int get currentPage => meta?.currentPage ?? 1;

  ProductsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<ProductModel>? products,
    PaginationMeta? meta,
    String? searchQuery,
    String? errorMessage,
  }) {
    return ProductsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      products: products ?? this.products,
      meta: meta ?? this.meta,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

class ProductsNotifier extends Notifier<ProductsState> {
  final ProductsService _productsService = ProductsService();

  @override
  ProductsState build() {
    ref.listen(authProvider, (previous, next) {
      if (!next.isAuthenticated) {
        state = const ProductsState();
      } else if (next.accountId != null && next.accountId != previous?.accountId) {
        loadProducts(reset: true);
      }
    });
    Future.microtask(() => loadProducts(reset: true));
    return const ProductsState(isLoading: true);
  }

  Future<void> loadProducts({bool reset = false}) async {
    final page = reset ? 1 : state.currentPage;

    if (reset) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    final auth = ref.read(authProvider);
    final accountId = auth.accountId ?? (auth.user?.accounts.isNotEmpty == true ? auth.user!.accounts.first.id : null);
    final response = await _productsService.getProducts(
      accountId: accountId,
      page: page,
      perPage: 15,
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
    );

    state = state.copyWith(
      isLoading: false,
      products: response.data,
      meta: response.meta,
      errorMessage: response.errorMessage,
    );
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    final auth = ref.read(authProvider);
    final accountId = auth.accountId ?? (auth.user?.accounts.isNotEmpty == true ? auth.user!.accounts.first.id : null);
    final nextPage = state.currentPage + 1;
    final response = await _productsService.getProducts(
      accountId: accountId,
      page: nextPage,
      perPage: 15,
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
    );

    state = state.copyWith(
      isLoadingMore: false,
      products: [...state.products, ...response.data],
      meta: response.meta ?? state.meta,
      errorMessage: response.errorMessage,
    );
  }

  void setSearch(String query) {
    if (state.searchQuery != query) {
      state = state.copyWith(searchQuery: query);
      loadProducts(reset: true);
    }
  }

  Future<ProductActionResult> createProduct(ProductModel product) async {
    final auth = ref.read(authProvider);
    final accountId = auth.accountId ?? (auth.user?.accounts.isNotEmpty == true ? auth.user!.accounts.first.id : null);
    final result = await _productsService.createProduct(product, accountId: accountId);
    if (result.isSuccess) {
      await loadProducts(reset: true);
    }
    return result;
  }

  Future<ProductActionResult> updateProduct(String id, ProductModel product) async {
    final auth = ref.read(authProvider);
    final accountId = auth.accountId ?? (auth.user?.accounts.isNotEmpty == true ? auth.user!.accounts.first.id : null);
    final result = await _productsService.updateProduct(id, product, accountId: accountId);
    if (result.isSuccess) {
      await loadProducts(reset: true);
    }
    return result;
  }

  Future<ProductActionResult> deleteProduct(String id) async {
    final auth = ref.read(authProvider);
    final accountId = auth.accountId ?? (auth.user?.accounts.isNotEmpty == true ? auth.user!.accounts.first.id : null);
    final result = await _productsService.deleteProduct(id, accountId: accountId);
    if (result.isSuccess) {
      state = state.copyWith(
        products: state.products.where((p) => p.id != id).toList(),
      );
    }
    return result;
  }

  Future<void> refresh() async {
    await loadProducts(reset: true);
  }
}

final productsProvider = NotifierProvider<ProductsNotifier, ProductsState>(() {
  return ProductsNotifier();
});
