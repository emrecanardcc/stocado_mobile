import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../models/balance_model.dart';
import '../models/dashboard_stats_model.dart';

class DashboardService {
  final ApiClient _apiClient;

  DashboardService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Hesaba ait canlı istatistikleri doğrudan veritabanından çeker:
  /// 1. GET /accounts/{accountId} -> Finansal bakiye ve muhasebe verileri
  /// 2. POST /accounts/{accountId}/cargos/query -> Canlı paket durum sayıları (Bekleyen, Yolda, Teslim Edilen vb.)
  Future<DashboardStats?> getDashboardStats({String? accountId, int? days}) async {
    try {
      if (accountId == null || accountId.isEmpty) {
        // Fallback: /dashboard/stats dene
        return await _getDirectDashboardStats();
      }

      // Tüm bağımsız kaynakları paralel olarak çekiyoruz (5x daha hızlı yükleme)
      final accountFuture = _apiClient.get('/accounts/$accountId').then<dynamic>((r) => r).catchError((e) => null);
      final statsFuture = _apiClient.get('/accounts/$accountId/statistics').then<dynamic>((r) => r).catchError((e) => null);
      final cardStatsFuture = _queryDashboardCargoCards(accountId, days: days);
      final podStatsFuture = _queryPodCargoAggregates(accountId);
      final accountingStatsFuture = _queryAccountingAggregates(accountId);

      final results = await Future.wait([
        accountFuture,
        statsFuture,
        cardStatsFuture,
        podStatsFuture,
        accountingStatsFuture,
      ]);

      // 1. Hesap & Muhasebe Bilgileri (GET /accounts/{accountId})
      double currentBalance = 0.0;
      double availableBalance = 0.0;
      double offsetBalance = 0.0;
      double podWillPay = 0.0;

      final accResponse = results[0];
      if (accResponse != null && accResponse.statusCode == 200) {
        final accData = ApiClient.decodeResponse(accResponse);
        if (accData is Map<String, dynamic> && accData['accounting'] is Map<String, dynamic>) {
          final accounting = accData['accounting'] as Map<String, dynamic>;
          final rawBalance = (accounting['balance'] as num?)?.toDouble() ?? 0.0;
          offsetBalance = (accounting['offset_balance'] as num?)?.toDouble() ?? 0.0;
          final calcAvailable = (accounting['available_balance'] as num?)?.toDouble() ??
              (rawBalance - offsetBalance);
          currentBalance = calcAvailable;
          availableBalance = calcAvailable;
          podWillPay = (accounting['pod_will_pay'] as num?)?.toDouble() ?? 0.0;
        }
      }

      // 2. Canlı İstatistikler (GET /accounts/{accountId}/statistics)
      String topCity = '-';
      String leastCity = '-';

      final statsRes = results[1];
      if (statsRes != null && statsRes.statusCode == 200) {
        final statsData = ApiClient.decodeResponse(statsRes);
        if (statsData is Map<String, dynamic> && statsData['cities'] is List) {
          final cities = statsData['cities'] as List;
          if (cities.isNotEmpty) {
            final first = cities.first;
            topCity = '${first['name']} / ${first['total']}';
            final last = cities.last;
            leastCity = '${last['name']} / ${last['total']}';
          }
        }
      }

      // 3. Kargo Durum Sayaçları (Canlı transaction bazlı sorgu)
      int totalCargos = 0;
      int pendingCargos = 0;
      int activeCargos = 0;
      int deliveredToday = 0;
      int problematicCargos = 0;
      int returnedCargos = 0;

      final cardStats = results[2] as Map<String, int>?;
      if (cardStats != null) {
        pendingCargos = cardStats['pending'] ?? 0;
        activeCargos = cardStats['active'] ?? 0;
        deliveredToday = cardStats['delivered'] ?? 0;
        problematicCargos = cardStats['problematic'] ?? 0;
        returnedCargos = cardStats['returned'] ?? 0;
        totalCargos = cardStats['total'] ?? 0;
      }

      final deliveryRate = totalCargos > 0 ? (deliveredToday / totalCargos) * 100 : 0.0;

      // 4. Canlı Kapıda Ödeme (POD) Kargo Agregasyonları
      final podStats = results[3] as Map<String, dynamic>?;

      // 5. Canlı Muhasebe Agregasyonları
      final accountingStats = results[4] as Map<String, double>? ?? {};

      return DashboardStats(
        totalCargos: totalCargos,
        activeCargos: activeCargos,
        pendingCargos: pendingCargos,
        problematicCargos: problematicCargos,
        deliveredToday: deliveredToday,
        returnedCargos: returnedCargos,
        deliveryRate: deliveryRate,
        balance: currentBalance,
        availableBalance: availableBalance,
        offsetBalance: offsetBalance,
        topCity: topCity,
        leastCity: leastCity,
        podCargoCount: (podStats?['podCargoCount'] as num?)?.toInt() ?? 0,
        podPending: (podStats?['podPending'] as num?)?.toDouble() ?? 0.00,
        podCollected: (podStats?['podCollected'] as num?)?.toDouble() ?? 0.00,
        podDeduction: accountingStats['podDeduction'] ?? 0.00,
        podWillPay: (podStats?['podWillPay'] as num?)?.toDouble() ?? podWillPay,
        podPaid: accountingStats['podPaid'] ?? 0.00,
        podReturnCount: (podStats?['podReturnCount'] as num?)?.toInt() ?? 0,
        podTotalVolume: (podStats?['podTotalVolume'] as num?)?.toDouble() ?? 0.00,
        totalPaid: accountingStats['totalPaid'] ?? 0.00,
        totalExpenses: accountingStats['totalExpenses'] ?? 0.00,
        recentCargos: [],
        weeklyTrend: [],
      );
    } catch (e) {
      debugPrint('DashboardService.getDashboardStats hatası: $e');
      return null;
    }
  }

  /// Web portalındaki gibi canlı kapıda ödemeli kargo metriklerini hesaplar
  Future<Map<String, dynamic>?> _queryPodCargoAggregates(String accountId) async {
    try {
      final response = await _apiClient.post(
        '/accounts/$accountId/cargos/query',
        body: {
          "fields": [
            {"name": "id", "aggregate": "count"},
            {
              "name": "pay_on_delivery",
              "filters": [
                {"operator": "equals", "value": true}
              ],
              "group": true
            },
            {"name": "cargo_company_id", "group": true},
            {"name": "pay_on_delivery_amount", "aggregate": "sum"},
            {"name": "pay_on_delivery_cost", "aggregate": "sum"},
            {"name": "pay_on_delivery_status", "group": true},
            {"name": "latest_transaction.type", "group": true},
            {
              "name": "status",
              "filters": [
                {
                  "operator": "in",
                  "value": [2, 1]
                }
              ],
              "group": true
            },
            {"name": "updated_at", "format": "day", "group": true}
          ],
          "paginate": {"count": 10000},
          "skipTotal": true
        },
      );

      if (response.statusCode == 200) {
        final decoded = ApiClient.decodeResponse(response);
        if (decoded is Map<String, dynamic> && decoded['items'] is List) {
          final items = decoded['items'] as List;

          int totalCargoCount = 0;
          double pendingCollection = 0.0;
          double collected = 0.0;
          double willPay = 0.0;
          int returnCount = 0;
          double totalVolume = 0.0;

          for (final item in items) {
            if (item is Map<String, dynamic>) {
              final count = (item['id'] is num)
                  ? (item['id'] as num).toInt()
                  : int.tryParse(item['id']?.toString() ?? '') ?? 0;
              final amount = (item['pay_on_delivery_amount'] is num)
                  ? (item['pay_on_delivery_amount'] as num).toDouble()
                  : double.tryParse(item['pay_on_delivery_amount']?.toString() ?? '') ?? 0.0;
              final podStatus = item['pay_on_delivery_status'] as int?;
              final trans = item['latest_transaction'];
              final transType = (trans is Map<String, dynamic>) ? (trans['type'] as int?) : null;

              totalCargoCount += count;

              // ALICIDAN TAHSİL EDİLECEK: podStatus == 0 && transType != 1 && transType != 11
              if (podStatus == 0 && transType != 1 && transType != 11) {
                pendingCollection += amount;
              }

              // ALICIDAN TAHSİL EDİLEN: podStatus == 1
              if (podStatus == 1) {
                collected += amount;
              }

              // BANA ÖDENECEK: podStatus == 2
              if (podStatus == 2) {
                willPay += amount;
              }

              // İADE SAYISI: transType 10 veya 11
              if (transType == 10 || transType == 11) {
                returnCount += count;
              }

              // TOPLAM: transType 10 ve 11 hariç (İade olanlar hariç kapıda ödeme hacmi)
              if (transType != 10 && transType != 11) {
                totalVolume += amount;
              }
            }
          }

          return {
            'podCargoCount': totalCargoCount,
            'podPending': pendingCollection,
            'podCollected': collected,
            'podWillPay': willPay,
            'podReturnCount': returnCount,
            'podTotalVolume': totalVolume,
          };
        }
      }
    } catch (e) {
      debugPrint('POD kargo verileri sorgulanırken hata: $e');
    }
    return null;
  }

  /// Canlı muhasebe hareketlerinden ödenen, harcanan ve kesinti toplamlarını hesaplar
  Future<Map<String, double>> _queryAccountingAggregates(String accountId) async {
    try {
      final response = await _apiClient.post(
        '/accounts/$accountId/accounting-transactions/query',
        body: {
          "fields": [
            {"name": "amount", "aggregate": "sum"},
            {"name": "type", "group": true},
          ],
          "paginate": {"count": 10000},
          "skipTotal": true
        },
      );

      if (response.statusCode == 200) {
        final decoded = ApiClient.decodeResponse(response);
        if (decoded is Map<String, dynamic> && decoded['items'] is List) {
          final items = decoded['items'] as List;
          double totalPaid = 0.0;
          double totalExpenses = 0.0;
          double podPaid = 0.0;
          double podDeduction = 0.0;

          for (final item in items) {
            final type = item['type'] as int?;
            final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
            // Type 1: Yüklenen bakiye / toplam ödenen
            if (type == 1 && amount > 0) {
              totalPaid += amount;
            } else if (amount < 0 && type != 2 && type != 19) {
              // Bakiye çekme veya banka transferi hariç masraflar (kargo masrafları vs.)
              totalExpenses += amount.abs();
            }
            // Type 19: Kapıda Ödeme Banka Transferi (Kullanıcıya ödenen)
            if (type == 19) {
              podPaid += amount.abs();
            }
            // Type 4: Kapıda Ödeme Komisyon Kesintisi
            else if (type == 4) {
              podDeduction += amount.abs();
            }
          }

          return {
            'totalPaid': totalPaid,
            'totalExpenses': totalExpenses,
            'podPaid': podPaid,
            'podDeduction': podDeduction,
          };
        }
      }
    } catch (e) {
      debugPrint('Muhasebe hareketleri sorgulanırken hata: $e');
    }
    return {
      'totalPaid': 0.0,
      'totalExpenses': 0.0,
      'podPaid': 0.0,
      'podDeduction': 0.0,
    };
  }

  /// GET /dashboard/stats (Eğer admin izni varsa)
  Future<DashboardStats?> _getDirectDashboardStats() async {
    try {
      final response = await _apiClient.get('/dashboard/stats');
      if (response.statusCode == 200) {
        final decoded = ApiClient.decodeResponse(response);
        if (decoded is Map<String, dynamic>) {
          return DashboardStats.fromJson(decoded);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Web portalındaki gibi kargoları canlı sorgular ve transaction type bazında tam hesaplar
  Future<Map<String, int>?> _queryDashboardCargoCards(String accountId, {int? days}) async {
    try {
      final now = DateTime.now();
      final DateTime? cutoff = days != null
          ? DateTime(now.year, now.month, now.day).subtract(Duration(days: days))
          : null;

      final response = await _apiClient.post(
        '/accounts/$accountId/cargos/query',
        body: {
          "fields": [
            {"name": "id", "aggregate": "count"},
            {"name": "latest_transaction.type", "group": true},
            {"name": "cargo_company.title", "group": true},
            {
              "name": "status",
              "filters": [
                {
                  "operator": "in",
                  "value": [2, 1]
                }
              ]
            },
            {
              "name": "created_at",
              if (cutoff != null)
                "filters": [
                  {
                    "operator": "greater_than",
                    "value": cutoff.toIso8601String().substring(0, 10),
                  }
                ],
              "format": "day",
              "group": true
            }
          ],
          "paginate": {"count": 10000},
          "skipTotal": true
        },
      );

      if (response.statusCode == 200) {
        final decoded = ApiClient.decodeResponse(response);
        if (decoded is Map<String, dynamic> && decoded['items'] is List) {
          final items = decoded['items'] as List;

          int pending = 0; // type == 1 (Gönderime hazır bekleyen kargolar)
          int active = 0; // type in [2, 3, 4, 5, 9] (Transferde / Yolda olan kargolar)
          int delivered = 0; // type == 6 (Teslim edilen kargolar)
          int problematic = 0; // type in [7, 13] (Teslim edilemeyen ya da yönetici iptal)
          int returned = 0; // type in [10, 11] (Geri dönen kargolar)
          int totalSum = 0; // Tümü

          for (final it in items) {
            if (it is Map<String, dynamic>) {
              if (cutoff != null && it['created_at'] != null) {
                final dt = DateTime.tryParse(it['created_at'].toString());
                if (dt != null && dt.isBefore(cutoff)) {
                  continue;
                }
              }

              final count = (it['id'] is num) ? (it['id'] as num).toInt() : int.tryParse(it['id']?.toString() ?? '') ?? 0;
              final trans = it['latest_transaction'];
              final type = (trans is Map<String, dynamic>) ? (trans['type'] as int?) : null;

              totalSum += count;

              if (type == 1 || type == null) {
                pending += count;
              } else if ([2, 3, 4, 5, 9].contains(type)) {
                active += count;
              } else if (type == 6) {
                delivered += count;
              } else if ([10, 11].contains(type)) {
                returned += count;
              } else if ([7, 13].contains(type)) {
                problematic += count;
              }
            }
          }

          return {
            'pending': pending,
            'active': active,
            'delivered': delivered,
            'problematic': problematic,
            'returned': returned,
            'total': totalSum,
          };
        }
      }
    } catch (e) {
      debugPrint('Dashboard kargo kartları sorgulanırken hata: $e');
    }
    return null;
  }


  /// GET /finance/balance veya /accounts/{accountId} muhasebe bakiyesi
  Future<BalanceModel?> getBalance({String? accountId}) async {
    try {
      if (accountId != null && accountId.isNotEmpty) {
        final accResponse = await _apiClient.get('/accounts/$accountId');
        if (accResponse.statusCode == 200) {
          final accData = ApiClient.decodeResponse(accResponse);
          if (accData is Map<String, dynamic> && accData['accounting'] is Map<String, dynamic>) {
            final accounting = accData['accounting'] as Map<String, dynamic>;
            final rawBalance = (accounting['balance'] as num?)?.toDouble() ?? 0.0;
            final offsetBal = (accounting['offset_balance'] as num?)?.toDouble() ?? 0.0;
            final calcAvailable = (accounting['available_balance'] as num?)?.toDouble() ??
                (rawBalance - offsetBal);
            return BalanceModel(
              balance: calcAvailable,
              availableBalance: calcAvailable,
              offsetBalance: offsetBal,
              currency: '₺',
            );
          }
        }
      }

      final response = await _apiClient.get('/finance/balance');
      if (response.statusCode == 200) {
        final decoded = ApiClient.decodeResponse(response);
        if (decoded is Map<String, dynamic>) {
          return BalanceModel.fromJson(decoded);
        }
      }
      return null;
    } catch (e) {
      debugPrint('DashboardService.getBalance hatası: $e');
      return null;
    }
  }
}
