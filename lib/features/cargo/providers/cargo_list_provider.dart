import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/pagination_meta.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/address_model.dart';
import '../models/cargo_model.dart';
import '../services/cargo_service.dart';

class CargoListState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<CargoModel> cargos;
  final PaginationMeta? meta;
  final String activeTab; // 'all', 'pod', 'drafts'
  final String searchQuery;
  final String? errorMessage;

  const CargoListState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.cargos = const [],
    this.meta,
    this.activeTab = 'all',
    this.searchQuery = '',
    this.errorMessage,
  });

  bool get hasMore => meta?.hasMore ?? false;
  int get currentPage => meta?.currentPage ?? 1;

  CargoListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<CargoModel>? cargos,
    PaginationMeta? meta,
    String? activeTab,
    String? searchQuery,
    String? errorMessage,
  }) {
    return CargoListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      cargos: cargos ?? this.cargos,
      meta: meta ?? this.meta,
      activeTab: activeTab ?? this.activeTab,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

class CargoListNotifier extends Notifier<CargoListState> {
  final CargoService _cargoService = CargoService();
  final Map<String, AddressModel> _addressMap = {};

  @override
  CargoListState build() {
    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated && next.accountId != null && next.accountId != previous?.accountId) {
        loadCargos(reset: true);
      }
    });
    Future.microtask(() => loadCargos(reset: true));
    return const CargoListState(isLoading: true);
  }

  Future<void> _ensureAddressesLoaded(String? accountId) async {
    if (_addressMap.isNotEmpty || accountId == null) return;
    try {
      final addresses = await _cargoService.getAddresses(accountId: accountId);
      for (var a in addresses) {
        _addressMap[a.id] = a;
      }
    } catch (_) {}
  }

  Future<List<CargoModel>> _resolveCargoParties(String? accountId, List<CargoModel> cargos) async {
    if (accountId != null && accountId.isNotEmpty) {
      final missingIds = <String>{};
      for (final c in cargos) {
        if (c.receiver == null && c.receiverId != null && !_addressMap.containsKey(c.receiverId)) {
          missingIds.add(c.receiverId!);
        }
        if (c.sender == null && c.senderId != null && !_addressMap.containsKey(c.senderId)) {
          missingIds.add(c.senderId!);
        }
      }

      if (missingIds.isNotEmpty) {
        try {
          final futures = missingIds.map((id) => _cargoService.getAddressById(accountId, id));
          final fetched = await Future.wait(futures);
          for (final a in fetched) {
            if (a != null) {
              _addressMap[a.id] = a;
            }
          }
        } catch (_) {}
      }
    }

    return cargos.map((c) {
      CargoParty? receiver = c.receiver;
      if (receiver == null && c.receiverId != null && _addressMap.containsKey(c.receiverId)) {
        receiver = CargoParty.fromAddress(_addressMap[c.receiverId]!);
      }

      CargoParty? sender = c.sender;
      if (sender == null && c.senderId != null && _addressMap.containsKey(c.senderId)) {
        sender = CargoParty.fromAddress(_addressMap[c.senderId]!);
      }

      return c.copyWith(receiver: receiver, sender: sender);
    }).toList();
  }

  /// Kargoları ilk sayfadan veya yenileyerek çeker
  Future<void> loadCargos({bool reset = false}) async {
    final page = reset ? 1 : state.currentPage;

    if (reset) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    final auth = ref.read(authProvider);
    final accountId = auth.accountId ?? auth.user?.accounts.firstOrNull?.id;
    await _ensureAddressesLoaded(accountId);

    String? filter;
    if (state.activeTab == 'pod') filter = 'pod';
    if (state.activeTab == 'drafts') filter = 'drafts';

    final response = await _cargoService.getCargos(
      accountId: accountId,
      page: page,
      perPage: 6,
      filter: filter,
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
    );

    final resolved = await _resolveCargoParties(accountId, response.data);

    state = state.copyWith(
      isLoading: false,
      cargos: resolved,
      meta: response.meta,
    );
  }

  /// Sonsuz Kaydırma (Infinite Scroll) için sonraki sayfayı yükler
  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.currentPage + 1;
    final auth = ref.read(authProvider);
    final accountId = auth.accountId ?? auth.user?.accounts.firstOrNull?.id;
    await _ensureAddressesLoaded(accountId);

    String? filter;
    if (state.activeTab == 'pod') filter = 'pod';
    if (state.activeTab == 'drafts') filter = 'drafts';

    final response = await _cargoService.getCargos(
      accountId: accountId,
      page: nextPage,
      perPage: 6,
      filter: filter,
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
    );

    final resolved = await _resolveCargoParties(accountId, response.data);

    state = state.copyWith(
      isLoadingMore: false,
      cargos: [...state.cargos, ...resolved],
      meta: response.meta ?? state.meta,
    );
  }

  /// Sekme Değiştirme ('all', 'pod', 'drafts')
  void setTab(String tab) {
    if (state.activeTab != tab) {
      state = state.copyWith(activeTab: tab);
      loadCargos(reset: true);
    }
  }

  /// Arama Sorgusu Güncelleme
  void setSearch(String query) {
    if (state.searchQuery != query) {
      state = state.copyWith(searchQuery: query);
      loadCargos(reset: true);
    }
  }

  Future<void> refresh() async {
    await loadCargos(reset: true);
  }
}

final cargoListProvider = NotifierProvider<CargoListNotifier, CargoListState>(() {
  return CargoListNotifier();
});
