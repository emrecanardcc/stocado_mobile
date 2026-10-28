import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../providers/cargo_list_provider.dart';
import '../widgets/cargo_card.dart';
import '../widgets/cargo_company_logo.dart';
import '../widgets/cargo_empty_state.dart';

class CargosScreen extends ConsumerStatefulWidget {
  const CargosScreen({super.key});

  @override
  ConsumerState<CargosScreen> createState() => _CargosScreenState();
}

class _CargosScreenState extends ConsumerState<CargosScreen> {
  late final ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(dashboardProvider).stats == null) {
        ref.read(dashboardProvider.notifier).loadDashboard();
      }
    });
  }

  void _handleScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(cargoListProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
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
          color: isSelected ? const Color(0xFF0E1E38) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF0E1E38) : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0E1E38).withValues(alpha: 0.25),
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
                color: isSelected ? Colors.white : const Color(0xFF0F172A),
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
        color: const Color(0xFF0E1E38).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0E1E38).withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0E1E38),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDeleted,
            child: const Icon(
              Icons.cancel_rounded,
              size: 16,
              color: Color(0xFF0E1E38),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTab({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    bool isHighlight = false,
  }) {
    final countStr = AppFormatters.formatNumber(count);

    Color bgColor;
    Color textColor;
    Color badgeBg;
    Color badgeText;
    Border? border;

    if (isSelected) {
      bgColor = const Color(0xFF0E1E38); // Koyu Lacivert Seçili Zemin
      textColor = Colors.white;
      badgeBg = Colors.white.withValues(alpha: 0.2);
      badgeText = Colors.white;
      border = null;
    } else if (isHighlight) {
      bgColor = const Color(0xFFFEF3C7); // Açık Turuncu/Sarı Vurgulu Zemin
      textColor = const Color(0xFFD97706);
      badgeBg = const Color(0xFFFDE68A);
      badgeText = const Color(0xFF92400E);
      border = Border.all(color: const Color(0xFFFCD34D), width: 0.8);
    } else {
      bgColor = const Color(0xFFF8FAFC);
      textColor = const Color(0xFF475569);
      badgeBg = const Color(0xFFE2E8F0);
      badgeText = const Color(0xFF475569);
      border = Border.all(color: const Color(0xFFE2E8F0), width: 0.8);
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: border,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0E1E38).withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  countStr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeText,
                  ),
                ),
              ),
            ],
          ),
        ),
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
                          color: const Color(0xFFCBD5E1),
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
                            Icon(Icons.tune_rounded, size: 20, color: Color(0xFF0E1E38)),
                            SizedBox(width: 8),
                            Text(
                              'Kargoları Filtrele',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
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
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 16),
                    const Text(
                      'Kargo Firması',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
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
                        color: Color(0xFF0F172A),
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
                          label: 'Aktif / Yolda',
                          isSelected: tempStatus == '1' || tempStatus == 'active' || tempStatus == 'yolda',
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
                          label: 'Başarısız / Sorunlu',
                          isSelected: tempStatus == '4' || tempStatus == 'failed' || tempStatus == 'problematic' || tempStatus == 'sorunlu',
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
                        color: Color(0xFF0F172A),
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
                              color: tempSort == 'desc' ? Colors.white : const Color(0xFF0E1E38),
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
                              color: tempSort == 'asc' ? Colors.white : const Color(0xFF0E1E38),
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
                        backgroundColor: const Color(0xFF0E1E38),
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
    final dashStats = ref.watch(dashboardProvider).stats;

    // Sayaç verileri (Dashboard istatistikleri veya meta verisi üzerinden)
    final allCount = dashStats?.totalCargos ?? (state.meta?.total ?? state.cargos.length);
    final inTransitCount = dashStats?.activeCargos ??
        state.cargos.where((c) {
          final t = c.effectiveTransactionType;
          if (t != null) return [2, 3, 4, 5, 9].contains(t);
          return c.status == 1;
        }).length;
    final problematicCount = dashStats?.problematicCargos ??
        state.cargos.where((c) {
          final t = c.effectiveTransactionType;
          if (t != null) return [0, 7, 8, 10, 11, 12, 13].contains(t);
          return c.status == 4 || c.status == 3;
        }).length;

    // Aktif sekme kontrolü
    final isAllSelected = state.selectedStatus == null || state.selectedStatus == 'all';
    final isInTransitSelected = state.selectedStatus == '1' || state.selectedStatus == 'active' || state.selectedStatus == 'yolda';
    final isProblematicSelected = state.selectedStatus == '4' || state.selectedStatus == 'failed' || state.selectedStatus == 'problematic' || state.selectedStatus == 'sorunlu';

    final hasCustomFilters = (state.selectedCargoCompany != null && state.selectedCargoCompany!.isNotEmpty) ||
        (state.selectedStatus != null && state.selectedStatus != 'all' && state.selectedStatus != '1' && state.selectedStatus != '4') ||
        state.sortDirection != 'desc';

    return PopScope(
      canPop: _searchController.text.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _searchController.text.isNotEmpty) {
          setState(() {
            _debounceTimer?.cancel();
            _searchController.clear();
            _searchFocusNode.unfocus();
            notifier.setSearch('');
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Üst Başlık ve İkonlar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kargolarım',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0E1E38),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.search, size: 24, color: Color(0xFF0E1E38)),
                          tooltip: 'Ara',
                          onPressed: () => _searchFocusNode.requestFocus(),
                        ),
                        IconButton(
                          icon: Badge(
                            isLabelVisible: hasCustomFilters,
                            smallSize: 8,
                            backgroundColor: AppColors.accent,
                            child: const Icon(Icons.tune_rounded, size: 24, color: Color(0xFF0E1E38)),
                          ),
                          tooltip: 'Filtrele',
                          onPressed: () => _showFilterSheet(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Arama Kutusu ("Ad, telefon veya barkod ara")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Ad, telefon veya barkod ara',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (val) {
                            _debounceTimer?.cancel();
                            _debounceTimer = Timer(const Duration(milliseconds: 350), () {
                              notifier.setSearch(val.trim());
                            });
                            setState(() {});
                          },
                          onSubmitted: (val) {
                            _debounceTimer?.cancel();
                            notifier.setSearch(val.trim());
                          },
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _debounceTimer?.cancel();
                            _searchController.clear();
                            notifier.setSearch('');
                            setState(() {});
                          },
                          child: const Icon(
                            Icons.cancel_rounded,
                            size: 18,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 3. Kompakt Filtre Çipleri (Pill Tabs)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                child: Row(
                  children: [
                    _buildPillTab(
                      label: 'Tümü',
                      count: allCount,
                      isSelected: isAllSelected,
                      onTap: () => notifier.setTab('all'),
                    ),
                    const SizedBox(width: 8),
                    _buildPillTab(
                      label: 'Yolda',
                      count: inTransitCount,
                      isSelected: isInTransitSelected,
                      onTap: () => notifier.setTab('yolda'),
                    ),
                    const SizedBox(width: 8),
                    _buildPillTab(
                      label: 'Sorunlu',
                      count: problematicCount,
                      isSelected: isProblematicSelected,
                      isHighlight: true,
                      onTap: () => notifier.setTab('sorunlu'),
                    ),
                  ],
                ),
              ),

              // 4. Özel Aktif Filtre Etiketleri (Firma, Özel Durum veya Sıralama Varsa)
              if (hasCustomFilters)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                        if (state.selectedStatus != null &&
                            state.selectedStatus != 'all' &&
                            state.selectedStatus != '1' &&
                            state.selectedStatus != '4') ...[
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
                          icon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF64748B)),
                          label: const Text(
                            'Temizle',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
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

              // Hata Mesajı Çubuğu
              if (state.errorMessage != null && state.cargos.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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

              // 5. Kargo Listesi
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => notifier.refresh(),
                  color: const Color(0xFF0E1E38),
                  child: state.isLoading && state.cargos.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF0E1E38)))
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
                                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
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
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0E1E38)),
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
      ),
    );
  }
}
