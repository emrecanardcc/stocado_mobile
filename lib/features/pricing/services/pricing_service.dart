import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../models/pricing_plan_model.dart';

class PricingService {
  final ApiClient _apiClient;

  PricingService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Hesaba tanımlı aktif fiyat tarifelerini ve detay desi fiyatlarını veritabanından çeker:
  /// 1. POST /accounts/{accountId}/pricing-plans/query
  /// 2. GET /accounts/{accountId}/pricing-plans/{planId} (her tarife için kademeler)
  Future<List<PricingPlan>> getPricingPlans(String accountId) async {
    try {
      final response = await _apiClient.post(
        '/accounts/$accountId/pricing-plans/query',
        body: {
          "fields": [
            {"name": "id"},
            {"name": "name"},
            {"name": "cargo_company"},
            {"name": "cargo_company_id"},
            {
              "name": "status",
              "filters": [
                {"operator": "equals", "value": 1}
              ]
            }
          ]
        },
      );

      if (response.statusCode == 200) {
        final decoded = ApiClient.decodeResponse(response);
        if (decoded is Map<String, dynamic> && decoded['items'] is List) {
          final items = decoded['items'] as List<dynamic>;

          // Tüm tarifelerin detaylarını paralel olarak çekiyoruz
          final planFutures = items.map((item) async {
            if (item is! Map<String, dynamic>) return null;
            final planId = item['id']?.toString();
            Map<String, dynamic>? detail;

            if (planId != null && planId.isNotEmpty) {
              try {
                final detailResponse = await _apiClient.get('/accounts/$accountId/pricing-plans/$planId');
                if (detailResponse.statusCode == 200) {
                  final decodedDetail = ApiClient.decodeResponse(detailResponse);
                  if (decodedDetail is Map<String, dynamic>) {
                    detail = decodedDetail;
                  }
                }
              } catch (e) {
                debugPrint('Tarife detayı çekilirken hata ($planId): $e');
              }
            }

            return PricingPlan.fromBackend(item, detail);
          }).toList();

          final results = await Future.wait(planFutures);
          return results.whereType<PricingPlan>().toList();
        }
      } else {
        debugPrint('PricingService.getPricingPlans başarısız: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      debugPrint('PricingService.getPricingPlans hatası: $e');
      return [];
    }
  }
}
