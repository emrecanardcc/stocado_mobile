import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainNavigationState {
  final int tabIndex; // 0: Özet, 1: Kargolar, 2: Yeni Kargo, 3: Tarifeler & Ürünler
  final int hubSubIndex; // 0: Tarifeler, 1: Kayıtlı Ürünlerim

  const MainNavigationState({
    this.tabIndex = 0,
    this.hubSubIndex = 0,
  });

  MainNavigationState copyWith({
    int? tabIndex,
    int? hubSubIndex,
  }) {
    return MainNavigationState(
      tabIndex: tabIndex ?? this.tabIndex,
      hubSubIndex: hubSubIndex ?? this.hubSubIndex,
    );
  }
}

class MainNavigationNotifier extends Notifier<MainNavigationState> {
  @override
  MainNavigationState build() => const MainNavigationState();

  void selectTab(int index, {int subIndex = 0}) {
    state = MainNavigationState(tabIndex: index, hubSubIndex: subIndex);
  }

  void selectHubSubIndex(int subIndex) {
    state = state.copyWith(hubSubIndex: subIndex);
  }
}

final mainNavigationProvider =
    NotifierProvider<MainNavigationNotifier, MainNavigationState>(MainNavigationNotifier.new);
