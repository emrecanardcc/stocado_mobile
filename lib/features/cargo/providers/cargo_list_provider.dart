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
  final String? selectedCargoCompany; // 'ptt', 'surat', 'yurtici', 'hepsijet', 'ups' or null
  final String? selectedStatus; // 'all', 'drafts', 'in_transit', 'delivered', 'problematic', 'returned'

  const CargoListState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.cargos = const [],
    this.meta,
    this.activeTab = 'all',
    this.searchQuery = '',
    this.errorMessage,
    this.selectedCargoCompany,
    this.selectedStatus,
  });

  bool get hasMore => meta?.hasMore ?? false;
  int get currentPage => meta?.currentPage ?? 1;
  bool get hasActiveFilters =>
      (selectedCargoCompany != null && selectedCargoCompany!.isNotEmpty) ||
      (selectedStatus != null && selectedStatus!.isNotEmpty && selectedStatus != 'all');

  CargoListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<CargoModel>? cargos,
    PaginationMeta? meta,
    String? activeTab,
    String? searchQuery,
    String? errorMessage,
    String? selectedCargoCompany,
    String? selectedStatus,
    bool clearCompany = false,
    bool clearStatus = false,
  }) {
    return CargoListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      cargos: cargos ?? this.cargos,
      meta: meta ?? this.meta,
      activeTab: activeTab ?? this.activeTab,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      selectedCargoCompany: clearCompany ? null : (selectedCargoCompany ?? this.selectedCargoCompany),
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
    );
  }
}

class CargoListNotifier extends Notifier<CargoListState> {
  final CargoService _cargoService = CargoService();
  final Map<String, AddressModel> _addressMap = {};

  @override
  CargoListState build() {
    ref.listen(authProvider, (previous, next) {
      if (!next.isAuthenticated) {
        _addressMap.clear();
        state = const CargoListState();
      } else if (next.accountId != null && next.accountId != previous?.accountId) {
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
      perPage: 15,
      filter: filter,
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      cargoCompanyId: state.selectedCargoCompany,
      statusFilter: state.selectedStatus,
    );

    final resolved = await _resolveCargoParties(accountId, response.data);

    state = state.copyWith(
      isLoading: false,
      cargos: resolved,
      meta: response.meta,
      errorMessage: response.errorMessage,
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
      perPage: 15,
      filter: filter,
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      cargoCompanyId: state.selectedCargoCompany,
      statusFilter: state.selectedStatus,
    );

    final resolved = await _resolveCargoParties(accountId, response.data);

    state = state.copyWith(
      isLoadingMore: false,
      cargos: [...state.cargos, ...resolved],
      meta: response.meta ?? state.meta,
      errorMessage: response.errorMessage,
    );
  }

  /// Sekme Değiştirme ('all', 'pod', 'drafts')
  void setTab(String tab) {
    if (state.activeTab != tab) {
      state = state.copyWith(activeTab: tab);
      loadCargos(reset: true);
    }
  }

  /// Kargo Şirketi ve Durum Filtrelerini Birlikte Güncelle
  void applyFilters({String? company, String? status}) {
    final companyChanged = state.selectedCargoCompany != company;
    final statusChanged = state.selectedStatus != status;
    if (companyChanged || statusChanged) {
      state = state.copyWith(
        selectedCargoCompany: company,
        clearCompany: company == null,
        selectedStatus: status,
        clearStatus: status == null,
      );
      loadCargos(reset: true);
    }
  }

  /// Kargo Şirketi Filtresi
  void setCargoCompany(String? company) {
    if (state.selectedCargoCompany != company) {
      state = state.copyWith(
        selectedCargoCompany: company,
        clearCompany: company == null,
      );
      loadCargos(reset: true);
    }
  }

  /// Kargo Durumu Filtresi
  void setStatusFilter(String? status) {
    if (state.selectedStatus != status) {
      state = state.copyWith(
        selectedStatus: status,
        clearStatus: status == null,
      );
      loadCargos(reset: true);
    }
  }

  /// Tüm filtreleri sıfırla
  void clearFilters() {
    if (state.hasActiveFilters) {
      state = state.copyWith(
        clearCompany: true,
        clearStatus: true,
      );
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
    _addressMap.clear();
    await loadCargos(reset: true);
  }
}

final cargoListProvider = NotifierProvider<CargoListNotifier, CargoListState>(() {
  return CargoListNotifier();
});
