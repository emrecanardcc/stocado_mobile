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
  final List<CargoModel> recentCargos;
  final PaginationMeta? meta;
  final String activeTab; // 'all', 'pod', 'drafts'
  final String searchQuery;
  final String? errorMessage;
  final String? selectedCargoCompany; // 'ptt', 'surat', 'yurtici', 'hepsijet', 'ups' or null
  final String? selectedStatus; // '0', '1', '2', '3', '4' or null
  final String sortDirection; // 'desc' | 'asc'
  final int? draftCount;

  const CargoListState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.cargos = const [],
    this.recentCargos = const [],
    this.meta,
    this.activeTab = 'all',
    this.searchQuery = '',
    this.errorMessage,
    this.selectedCargoCompany,
    this.selectedStatus,
    this.sortDirection = 'desc',
    this.draftCount,
  });

  bool get hasMore => meta?.hasMore ?? false;
  int get currentPage => meta?.currentPage ?? 1;
  bool get hasActiveFilters =>
      (selectedCargoCompany != null && selectedCargoCompany!.isNotEmpty) ||
      (selectedStatus != null && selectedStatus!.isNotEmpty && selectedStatus != 'all') ||
      sortDirection != 'desc';

  CargoListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<CargoModel>? cargos,
    List<CargoModel>? recentCargos,
    PaginationMeta? meta,
    String? activeTab,
    String? searchQuery,
    String? errorMessage,
    String? selectedCargoCompany,
    String? selectedStatus,
    String? sortDirection,
    int? draftCount,
    bool clearCompany = false,
    bool clearStatus = false,
  }) {
    return CargoListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      cargos: cargos ?? this.cargos,
      recentCargos: recentCargos ?? this.recentCargos,
      meta: meta ?? this.meta,
      activeTab: activeTab ?? this.activeTab,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      selectedCargoCompany: clearCompany ? null : (selectedCargoCompany ?? this.selectedCargoCompany),
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      sortDirection: sortDirection ?? this.sortDirection,
      draftCount: draftCount ?? this.draftCount,
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

    final currentAuth = ref.read(authProvider);
    if (currentAuth.isAuthenticated && currentAuth.accountId != null) {
      Future.microtask(() => loadCargos(reset: true));
      return const CargoListState(isLoading: true);
    }

    return const CargoListState(isLoading: false);
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
      sortDirection: state.sortDirection,
    );

    final resolved = await _resolveCargoParties(accountId, response.data);

    // Seçili sıralama kuralına göre sırala
    resolved.sort((a, b) => CargoModel.compareCargos(a, b, sortDirection: state.sortDirection));

    int? currentDraftCount = state.draftCount;
    if (state.activeTab == 'drafts') {
      currentDraftCount = response.meta?.total ?? response.data.length;
    } else {
      final inListDrafts = resolved.where((c) => c.status == 0).length;
      if (currentDraftCount == null && inListDrafts > 0) {
        currentDraftCount = inListDrafts;
      }
    }

    final bool isUnfiltered = state.activeTab == 'all' &&
        state.searchQuery.isEmpty &&
        state.selectedCargoCompany == null &&
        (state.selectedStatus == null || state.selectedStatus == 'all') &&
        state.sortDirection == 'desc';

    state = state.copyWith(
      isLoading: false,
      cargos: resolved,
      recentCargos: isUnfiltered
          ? resolved
          : (state.recentCargos.isNotEmpty ? state.recentCargos : resolved),
      meta: response.meta,
      errorMessage: response.errorMessage,
      draftCount: currentDraftCount,
    );

    // İlk yüklemede veya sekme tümüyken taslak sayısı henüz bilinmiyorsa arka planda çek
    if (reset && state.draftCount == null && accountId != null && state.activeTab != 'drafts') {
      _cargoService.getDraftCount(accountId).then((count) {
        if (count != null) {
          state = state.copyWith(draftCount: count);
        }
      }).catchError((_) {});
    }

    // Filtreleme yapıldığında mevcut sayfada eşleşen az ürün kaldıysa otomatik sonraki sayfayı çek
    if (resolved.length < 5 && state.hasMore && (state.selectedStatus != null || state.selectedCargoCompany != null)) {
      loadNextPage();
    }
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
      sortDirection: state.sortDirection,
    );

    final resolved = await _resolveCargoParties(accountId, response.data);

    final existingIds = state.cargos.map((c) => c.id.toString()).toSet();
    final newItems = resolved.where((c) => !existingIds.contains(c.id.toString())).toList();
    final combined = [...state.cargos, ...newItems];
    // Seçili sıralama kuralına göre sırala
    combined.sort((a, b) => CargoModel.compareCargos(a, b, sortDirection: state.sortDirection));

    state = state.copyWith(
      isLoadingMore: false,
      cargos: combined,
      meta: response.meta ?? state.meta,
      errorMessage: response.errorMessage,
    );

    // Eğer çekilen sayfadaki tüm kayıtlar filtrelenmişse ve arkada daha fazla sayfa varsa devam et
    if (resolved.isEmpty && state.hasMore && (state.selectedStatus != null || state.selectedCargoCompany != null)) {
      loadNextPage();
    }
  }

  /// Sekme Değiştirme ('all', 'yolda', 'sorunlu', 'pod', 'drafts')
  void setTab(String tab) {
    String? status;
    if (tab == 'yolda') {
      status = '1';
    } else if (tab == 'sorunlu') {
      status = '4';
    } else if (tab == 'drafts') {
      status = '0';
    } else if (tab == 'all') {
      status = null;
    }
    final tabChanged = state.activeTab != tab;
    final statusChanged = state.selectedStatus != status;
    if (tabChanged || statusChanged) {
      state = state.copyWith(
        activeTab: tab,
        selectedStatus: status,
        clearStatus: status == null,
      );
      loadCargos(reset: true);
    }
  }

  /// Kargo Şirketi, Durum ve Sıralama Filtrelerini Güncelle
  void applyFilters({String? company, String? status, String? sortDirection}) {
    final companyChanged = state.selectedCargoCompany != company;
    final statusChanged = state.selectedStatus != status;
    final sortChanged = sortDirection != null && state.sortDirection != sortDirection;
    if (companyChanged || statusChanged || sortChanged) {
      String newTab = 'all';
      if (status == '1' || status == 'active' || status == 'yolda') {
        newTab = 'yolda';
      } else if (status == '4' || status == 'failed' || status == 'problematic' || status == 'sorunlu') {
        newTab = 'sorunlu';
      } else if (status == '0' || status == 'drafts') {
        newTab = 'drafts';
      }
      state = state.copyWith(
        activeTab: newTab,
        selectedCargoCompany: company,
        clearCompany: company == null,
        selectedStatus: status,
        clearStatus: status == null,
        sortDirection: sortDirection ?? state.sortDirection,
      );
      loadCargos(reset: true);
    }
  }

  /// Sıralama Yönü Filtresi ('desc' = Yeniden Eskiye, 'asc' = Eskiden Yeniye)
  void setSortDirection(String direction) {
    if (state.sortDirection != direction) {
      state = state.copyWith(sortDirection: direction);
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
      String newTab = state.activeTab;
      if (status == '1' || status == 'active' || status == 'yolda') {
        newTab = 'yolda';
      } else if (status == '4' || status == 'failed' || status == 'problematic' || status == 'sorunlu') {
        newTab = 'sorunlu';
      } else if (status == null || status == 'all') {
        newTab = 'all';
      }
      state = state.copyWith(
        activeTab: newTab,
        selectedStatus: status,
        clearStatus: status == null,
      );
      loadCargos(reset: true);
    }
  }

  /// Tüm filtreleri sıfırla
  void clearFilters() {
    if (state.hasActiveFilters || state.activeTab != 'all') {
      state = state.copyWith(
        activeTab: 'all',
        clearCompany: true,
        clearStatus: true,
        sortDirection: 'desc',
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

  /// Dashboard "Son Gönderiler" için her zaman filtrelenmemiş en son kargoları çeker
  Future<void> loadRecentCargos() async {
    final auth = ref.read(authProvider);
    final accountId = auth.accountId ?? auth.user?.accounts.firstOrNull?.id;
    if (accountId == null) return;
    try {
      final response = await _cargoService.getCargos(
        accountId: accountId,
        page: 1,
        perPage: 10,
        sortDirection: 'desc',
      );
      final resolved = await _resolveCargoParties(accountId, response.data);
      resolved.sort((a, b) => CargoModel.compareCargos(a, b, sortDirection: 'desc'));
      state = state.copyWith(recentCargos: resolved);
    } catch (_) {}
  }

  Future<void> refresh() async {
    _addressMap.clear();
    await loadCargos(reset: true);
    await loadRecentCargos();
  }
}

final cargoListProvider = NotifierProvider<CargoListNotifier, CargoListState>(() {
  return CargoListNotifier();
});
