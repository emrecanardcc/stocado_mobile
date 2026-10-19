class BalanceModel {
  final double balance;
  final double availableBalance;
  final double offsetBalance;
  final String currency;

  BalanceModel({
    required this.balance,
    required this.availableBalance,
    required this.offsetBalance,
    this.currency = 'TRY',
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      balance: (json['balance'] is num) ? (json['balance'] as num).toDouble() : double.tryParse(json['balance']?.toString() ?? '') ?? 0.0,
      availableBalance: (json['available_balance'] is num) ? (json['available_balance'] as num).toDouble() : double.tryParse(json['available_balance']?.toString() ?? '') ?? 0.0,
      offsetBalance: (json['offset_balance'] is num) ? (json['offset_balance'] as num).toDouble() : double.tryParse(json['offset_balance']?.toString() ?? '') ?? 0.0,
      currency: json['currency']?.toString() ?? 'TRY',
    );
  }
}
