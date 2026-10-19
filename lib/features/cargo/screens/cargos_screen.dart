import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(cargoListProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cargoListProvider);
    final notifier = ref.read(cargoListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Barkod, alıcı adı veya sipariş no...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onSubmitted: (val) => notifier.setSearch(val.trim()),
              )
            : const Text('Kargolarım'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
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
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: () => notifier.refresh(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Tümü'),
            Tab(text: 'Kapıda Ödemeli'),
            Tab(text: 'Taslaklar'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: state.isLoading && state.cargos.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.cargos.isEmpty
                ? const CargoEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: state.cargos.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.cargos.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final cargo = state.cargos[index];
                      return CargoCard(cargo: cargo);
                    },
                  ),
      ),
    );
  }
}