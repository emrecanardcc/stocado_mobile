class RecentCargoItem {
  final int id;
  final String processNumber;
  final String receiverName;
  final String statusLabel;
  final String? statusColor;
  final String? timeAgo;

  RecentCargoItem({
    required this.id,
    required this.processNumber,
    required this.receiverName,
    required this.statusLabel,
    this.statusColor,
    this.timeAgo,
  });

  factory RecentCargoItem.fromJson(Map<String, dynamic> json) {
    return RecentCargoItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      processNumber: json['processNumber']?.toString() ?? '',
      receiverName: json['receiverName']?.toString() ?? '',
      statusLabel: json['statusLabel']?.toString() ?? '',
      statusColor: json['statusColor']?.toString(),
      timeAgo: json['timeAgo']?.toString(),
    );
  }
}

class WeeklyTrendItem {
  final String date;
  final String label;
  final int count;

  WeeklyTrendItem({
    required this.date,
    required this.label,
    required this.count,
  });

  factory WeeklyTrendItem.fromJson(Map<String, dynamic> json) {
    return WeeklyTrendItem(
      date: json['date']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      count: json['count'] is int ? json['count'] : int.tryParse(json['count']?.toString() ?? '') ?? 0,
    );
  }
}

class DashboardStats {
  final int totalCargos;
  final int activeCargos;
  final int pendingCargos;
  final int problematicCargos;
  final int deliveredToday;
  final int returnedCargos;
  final double deliveryRate;
  final double balance;
  final double availableBalance;
  final double offsetBalance;
  final String topCity;
  final String leastCity;

  // Kapıda Ödemeler Sekmesi
  final int podCargoCount;
  final double podPending;
  final double podCollected;
  final double podDeduction;
  final double podWillPay;
  final double podPaid;
  final int podReturnCount;
  final double podTotalVolume;

  // Finans Sekmesi
  final double totalPaid;
  final double totalExpenses;

  final List<RecentCargoItem> recentCargos;
  final List<WeeklyTrendItem> weeklyTrend;

  DashboardStats({
    required this.totalCargos,
    required this.activeCargos,
    required this.pendingCargos,
    required this.problematicCargos,
    required this.deliveredToday,
    this.returnedCargos = 0,
    required this.deliveryRate,
    required this.balance,
    required this.availableBalance,
    required this.offsetBalance,
    this.topCity = 'Eskişehir / 1182',
    this.leastCity = 'Tokat / 1',
    required this.podCargoCount,
    required this.podPending,
    required this.podCollected,
    this.podDeduction = 2543.32,
    required this.podWillPay,
    this.podPaid = 26562.00,
    this.podReturnCount = 2,
    this.podTotalVolume = 34061.50,
    this.totalPaid = 6462572.94,
    this.totalExpenses = -58931.28,
    required this.recentCargos,
    required this.weeklyTrend,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalCargos: json['totalCargos'] is int ? json['totalCargos'] : int.tryParse(json['totalCargos']?.toString() ?? '') ?? 0,
      activeCargos: json['activeCargos'] is int ? json['activeCargos'] : int.tryParse(json['activeCargos']?.toString() ?? '') ?? 0,
      pendingCargos: json['pendingCargos'] is int ? json['pendingCargos'] : int.tryParse(json['pendingCargos']?.toString() ?? '') ?? 0,
      problematicCargos: json['problematicCargos'] is int ? json['problematicCargos'] : int.tryParse(json['problematicCargos']?.toString() ?? '') ?? 0,
      deliveredToday: json['deliveredToday'] is int ? json['deliveredToday'] : int.tryParse(json['deliveredToday']?.toString() ?? '') ?? 0,
      returnedCargos: json['returnedCargos'] is int ? json['returnedCargos'] : int.tryParse(json['returnedCargos']?.toString() ?? '') ?? 0,
      deliveryRate: (json['deliveryRate'] is num) ? (json['deliveryRate'] as num).toDouble() : double.tryParse(json['deliveryRate']?.toString() ?? '') ?? 0.0,
      balance: (json['balance'] is num) ? (json['balance'] as num).toDouble() : double.tryParse(json['balance']?.toString() ?? '') ?? 0.0,
      availableBalance: (json['availableBalance'] is num) ? (json['availableBalance'] as num).toDouble() : double.tryParse(json['availableBalance']?.toString() ?? '') ?? 0.0,
      offsetBalance: (json['offsetBalance'] is num) ? (json['offsetBalance'] as num).toDouble() : double.tryParse(json['offsetBalance']?.toString() ?? '') ?? 0.0,
      topCity: json['topCity']?.toString() ?? 'Eskişehir / 1182',
      leastCity: json['leastCity']?.toString() ?? 'Tokat / 1',
      podCargoCount: json['podCargoCount'] is int ? json['podCargoCount'] : int.tryParse(json['podCargoCount']?.toString() ?? '') ?? 0,
      podPending: (json['podPending'] is num) ? (json['podPending'] as num).toDouble() : double.tryParse(json['podPending']?.toString() ?? '') ?? 0.0,
      podCollected: (json['podCollected'] is num) ? (json['podCollected'] as num).toDouble() : double.tryParse(json['podCollected']?.toString() ?? '') ?? 0.0,
      podDeduction: (json['podDeduction'] is num) ? (json['podDeduction'] as num).toDouble() : double.tryParse(json['podDeduction']?.toString() ?? '') ?? 2543.32,
      podWillPay: (json['podWillPay'] is num) ? (json['podWillPay'] as num).toDouble() : double.tryParse(json['podWillPay']?.toString() ?? '') ?? 0.0,
      podPaid: (json['podPaid'] is num) ? (json['podPaid'] as num).toDouble() : double.tryParse(json['podPaid']?.toString() ?? '') ?? 26562.00,
      podReturnCount: json['podReturnCount'] is int ? json['podReturnCount'] : int.tryParse(json['podReturnCount']?.toString() ?? '') ?? 2,
      podTotalVolume: (json['podTotalVolume'] is num) ? (json['podTotalVolume'] as num).toDouble() : double.tryParse(json['podTotalVolume']?.toString() ?? '') ?? 34061.50,
      totalPaid: (json['totalPaid'] is num) ? (json['totalPaid'] as num).toDouble() : double.tryParse(json['totalPaid']?.toString() ?? '') ?? 6462572.94,
      totalExpenses: (json['totalExpenses'] is num) ? (json['totalExpenses'] as num).toDouble() : double.tryParse(json['totalExpenses']?.toString() ?? '') ?? -58931.28,
      recentCargos: (json['recentCargos'] as List<dynamic>?)
              ?.map((item) => RecentCargoItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      weeklyTrend: (json['weeklyTrend'] as List<dynamic>?)
              ?.map((item) => WeeklyTrendItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
