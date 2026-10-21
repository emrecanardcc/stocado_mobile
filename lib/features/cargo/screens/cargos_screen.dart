import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_error_state.dart';
import '../providers/cargo_list_provider.dart';
import '../widgets/cargo_card.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cargoListProvider);
    final notifier = ref.read(cargoListProvider.notifier);

    return Scaffold(
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
            icon: state.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Yenile',
            onPressed: state.isLoading ? null : () => notifier.refresh(),
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
    );
  }
}