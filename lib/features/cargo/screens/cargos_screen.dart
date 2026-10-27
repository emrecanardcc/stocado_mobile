import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_error_state.dart';
import '../providers/cargo_list_provider.dart';
import '../widgets/cargo_card.dart';
import '../widgets/cargo_company_logo.dart';
import '../widgets/cargo_empty_state.dart';

class CargosScreen extends ConsumerStatefulWidget {
  const CargosScreen({super.key});

  @override
  ConsumerState<CargosScreen> createState() => _CargosScreenState();
}

class _CargosScreenState extends ConsumerState<CargosScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);

    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    final tabs = ['all', 'pod', 'drafts'];
    ref.read(cargoListProvider.notifier).setTab(tabs[_tabController.index]);
    setState(() {});
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(cargoListProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _companyLabel(String? id) {
    switch (id) {
      case 'ptt':
        return 'PTT Kargo';
      case 'surat':
        return 'Sürat Kargo';
      case 'yurtici':
        return 'Yurtiçi Kargo';
      case 'hepsijet':
        return 'HepsiJET';
      case 'ups':
        return 'UPS Kargo';
      case 'kolay-gelsin':
        return 'Kolay Gelsin';
      default:
        return 'Tümü';
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case '0':
      case 'drafts':
        return 'Taslak';
      case '1':
      case 'active':
        return 'Aktif';
      case '2':
      case 'delivered':
      case 'completed':
        return 'Tamamlandı';
      case '3':
      case 'cancelled':
        return 'İptal Edildi';
      case '4':
      case 'failed':
      case 'problematic':
        return 'Başarısız';
      default:
        return 'Tümü';
    }
  }

  Widget _buildFilterChip(int index, String title, IconData icon) {
    final isSelected = _tabController.index == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
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
                size: 15,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChipItem({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    Widget? leading,
  }) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading,
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterTag({required String label, required VoidCallback onDeleted}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDeleted,
            child: const Icon(
              Icons.cancel_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final state = ref.read(cargoListProvider);
    String? tempCompany = state.selectedCargoCompany;
    String? tempStatus = state.selectedStatus;
    String tempSort = state.sortDirection;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.tune_rounded, size: 20, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Kargoları Filtrele',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (tempCompany != null || tempStatus != null || tempSort != 'desc')
                          TextButton(
                            onPressed: () {
                              setSheetState(() {
                                tempCompany = null;
                                tempStatus = null;
                                tempSort = 'desc';
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Sıfırla',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 16),
                    const Text(
                      'Kargo Firması',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChipItem(
                          label: 'Tüm Firmalar',
                          isSelected: tempCompany == null,
                          onSelected: () => setSheetState(() => tempCompany = null),
                        ),
                        _buildFilterChipItem(
                          label: 'PTT Kargo',
                          isSelected: tempCompany == 'ptt',
                          leading: const CargoCompanyLogo(companyId: 'ptt', size: 18, borderRadius: 4, showBorder: false),
                          onSelected: () => setSheetState(() => tempCompany = 'ptt'),
                        ),
                        _buildFilterChipItem(
                          label: 'Sürat Kargo',
                          isSelected: tempCompany == 'surat',
                          leading: const CargoCompanyLogo(companyId: 'surat', size: 18, borderRadius: 4, showBorder: false),
                          onSelected: () => setSheetState(() => tempCompany = 'surat'),
                        ),
                        _buildFilterChipItem(
                          label: 'Yurtiçi Kargo',
                          isSelected: tempCompany == 'yurtici',
                          leading: const CargoCompanyLogo(companyId: 'yurtici', size: 18, borderRadius: 4, showBorder: false),
                          onSelected: () => setSheetState(() => tempCompany = 'yurtici'),
                        ),
                        _buildFilterChipItem(
                          label: 'HepsiJET',
                          isSelected: tempCompany == 'hepsijet',
                          leading: const CargoCompanyLogo(companyId: 'hepsijet', size: 18, borderRadius: 4, showBorder: false),
                          onSelected: () => setSheetState(() => tempCompany = 'hepsijet'),
                        ),
                        _buildFilterChipItem(
                          label: 'UPS Kargo',
                          isSelected: tempCompany == 'ups',
                          leading: const CargoCompanyLogo(companyId: 'ups', size: 18, borderRadius: 4, showBorder: false),
                          onSelected: () => setSheetState(() => tempCompany = 'ups'),
                        ),
                        _buildFilterChipItem(
                          label: 'Kolay Gelsin',
                          isSelected: tempCompany == 'kolay-gelsin',
                          leading: const CargoCompanyLogo(companyId: 'kolay-gelsin', size: 18, borderRadius: 4, showBorder: false),
                          onSelected: () => setSheetState(() => tempCompany = 'kolay-gelsin'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Kargo Durumu',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChipItem(
                          label: 'Tüm Durumlar',
                          isSelected: tempStatus == null || tempStatus == 'all',
                          onSelected: () => setSheetState(() => tempStatus = null),
                        ),
                        _buildFilterChipItem(
                          label: 'Taslak',
                          isSelected: tempStatus == '0' || tempStatus == 'drafts',
                          onSelected: () => setSheetState(() => tempStatus = '0'),
                        ),
                        _buildFilterChipItem(
                          label: 'Aktif',
                          isSelected: tempStatus == '1' || tempStatus == 'active',
                          onSelected: () => setSheetState(() => tempStatus = '1'),
                        ),
                        _buildFilterChipItem(
                          label: 'Tamamlandı',
                          isSelected: tempStatus == '2' || tempStatus == 'delivered' || tempStatus == 'completed',
                          onSelected: () => setSheetState(() => tempStatus = '2'),
                        ),
                        _buildFilterChipItem(
                          label: 'İptal Edildi',
                          isSelected: tempStatus == '3' || tempStatus == 'cancelled',
                          onSelected: () => setSheetState(() => tempStatus = '3'),
                        ),
                        _buildFilterChipItem(
                          label: 'Başarısız',
                          isSelected: tempStatus == '4' || tempStatus == 'failed' || tempStatus == 'problematic',
                          onSelected: () => setSheetState(() => tempStatus = '4'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Sıralama Şekli',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFilterChipItem(
                            label: 'Yeniden Eskiye',
                            isSelected: tempSort == 'desc',
                            leading: Icon(
                              Icons.arrow_downward_rounded,
                              size: 15,
                              color: tempSort == 'desc' ? Colors.white : AppColors.primary,
                            ),
                            onSelected: () => setSheetState(() => tempSort = 'desc'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFilterChipItem(
                            label: 'Eskiden Yeniye',
                            isSelected: tempSort == 'asc',
                            leading: Icon(
                              Icons.arrow_upward_rounded,
                              size: 15,
                              color: tempSort == 'asc' ? Colors.white : AppColors.primary,
                            ),
                            onSelected: () => setSheetState(() => tempSort = 'asc'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(cargoListProvider.notifier).applyFilters(
                              company: tempCompany,
                              status: tempStatus,
                              sortDirection: tempSort,
                            );
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Filtreleri Uygula',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cargoListProvider);
    final notifier = ref.read(cargoListProvider.notifier);

    return PopScope(
      canPop: !_isSearching,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSearching) {
          setState(() {
            _debounceTimer?.cancel();
            _searchController.clear();
            notifier.setSearch('');
            _isSearching = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Barkod, alıcı adı veya takip no...',
                  hintStyle: TextStyle(color: Colors.white60, fontSize: 14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  filled: false,
                ),
                onChanged: (val) {
                  _debounceTimer?.cancel();
                  _debounceTimer = Timer(const Duration(milliseconds: 350), () {
                    notifier.setSearch(val.trim());
                  });
                },
                onSubmitted: (val) {
                  _debounceTimer?.cancel();
                  notifier.setSearch(val.trim());
                },
              )
            : const Row(
                children: [
                  Icon(Icons.local_shipping_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('Kargolarım'),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            tooltip: _isSearching ? 'Aramayı Kapat' : 'Ara',
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _debounceTimer?.cancel();
                  _searchController.clear();
                  notifier.setSearch('');
                  _isSearching = false;
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: state.hasActiveFilters,
              smallSize: 8,
              backgroundColor: AppColors.accent,
              child: const Icon(Icons.tune_rounded),
            ),
            tooltip: 'Filtrele',
            onPressed: () => _showFilterSheet(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Filtre Sekmeleri (Pill Selector)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _buildFilterChip(0, 'Tümü', Icons.list_alt_rounded),
                  _buildFilterChip(1, 'Kapıda Ödemeli', Icons.payments_outlined),
                  _buildFilterChip(2, 'Taslaklar', Icons.drafts_outlined),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Aktif Filtre Etiketleri (Varsa)
          if (state.hasActiveFilters)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (state.selectedCargoCompany != null) ...[
                      _buildActiveFilterTag(
                        label: 'Firma: ${_companyLabel(state.selectedCargoCompany)}',
                        onDeleted: () => notifier.setCargoCompany(null),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (state.selectedStatus != null && state.selectedStatus != 'all') ...[
                      _buildActiveFilterTag(
                        label: 'Durum: ${_statusLabel(state.selectedStatus)}',
                        onDeleted: () => notifier.setStatusFilter(null),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (state.sortDirection != 'desc') ...[
                      _buildActiveFilterTag(
                        label: 'Sıralama: Eskiden Yeniye',
                        onDeleted: () => notifier.setSortDirection('desc'),
                      ),
                      const SizedBox(width: 8),
                    ],
                    TextButton.icon(
                      onPressed: () => notifier.clearFilters(),
                      icon: const Icon(Icons.close_rounded, size: 14, color: AppColors.textSecondary),
                      label: const Text(
                        'Temizle',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (state.errorMessage != null && state.cargos.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

          // Liste Görünümü
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => notifier.refresh(),
              color: AppColors.primary,
              child: state.isLoading && state.cargos.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : state.errorMessage != null && state.cargos.isEmpty
                      ? AppErrorState(
                          title: 'Kargolar Yüklenemedi',
                          message: state.errorMessage!,
                          onRetry: () => notifier.refresh(),
                        )
                      : state.cargos.isEmpty
                          ? const CargoEmptyState()
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: state.cargos.length + (state.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == state.cargos.length) {
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

                                final cargo = state.cargos[index];
                                return CargoCard(cargo: cargo);
                              },
                            ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
