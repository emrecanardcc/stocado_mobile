import 'package:flutter/foundation.dart';
import '../../../core/models/pagination_meta.dart';
import '../../../core/network/api_client.dart';
import '../models/address_model.dart';
import '../models/cargo_model.dart';
import '../models/cargo_offer_model.dart';

class PaginatedCargosResponse {
  final List<CargoModel> data;
  final PaginationMeta? meta;

  PaginatedCargosResponse({required this.data, this.meta});
}

class CargoCreationResult {
  final bool isSuccess;
  final String? message;
  final dynamic data;
  final Map<String, dynamic>? errors;

  CargoCreationResult({
    required this.isSuccess,
    this.message,
    this.data,
    this.errors,
  });
}

class AddressCreationResult {
  final bool isSuccess;
  final String? message;
  final AddressModel? address;
  final Map<String, dynamic>? errors;

  AddressCreationResult({
    required this.isSuccess,
    this.message,
    this.address,
    this.errors,
  });
}

class CargoService {
  final ApiClient _apiClient;

  CargoService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Kayıtlı adresleri çeker:
  /// POST /accounts/{accountId}/addresses/query
  /// veya GET /addresses
  Future<List<AddressModel>> getAddresses({String? accountId, int? type}) async {
    try {
      if (accountId != null && accountId.isNotEmpty) {
        final response = await _apiClient.post(
          '/accounts/$accountId/addresses/query',
          body: {
            "fields": [
              {"name": "id"},
              {"name": "title"},
              {"name": "name"},
              {"name": "phone"},
              {"name": "email"},
              {"name": "details"},
              {"name": "type"},
              {"name": "status", "filters": [{"operator": "equals", "value": 1}]},
              {"name": "is_default"},
              {"name": "city_id"},
              {"name": "district_id"},
              {"name": "country_id"},
              {"name": "postal_code"},
              {"name": "corporate_name"},
              {"name": "vkn"},
              {"name": "responsible_person_name"},
              {"name": "responsible_person_lastname"},
              {"name": "responsible_person_tckn"}
            ],
            "paginate": {"page": 1, "count": 200}
          },
        );

        if (response.statusCode == 200) {
          final decoded = ApiClient.decodeResponse(response);
          if (decoded is Map<String, dynamic> && decoded['items'] is List) {
            final list = (decoded['items'] as List)
                .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
                .where((a) => a.isActive)
                .toList();
            if (type != null) {
              return list.where((a) => a.type == type).toList();
            }
            return list;
          }
        }
      }

      // Fallback: GET /addresses
      final fallbackRes = await _apiClient.get(
        '/addresses',
        queryParameters: {
          'type': type == 4 ? 'sender' : (type != null ? 'customer' : null),
          'account_id': ?accountId,
        },
      );

      if (fallbackRes.statusCode == 200) {
        final decoded = ApiClient.decodeResponse(fallbackRes);
        if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          final list = (decoded['data'] as List)
              .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
              .where((a) => a.isActive)
              .toList();
          if (type != null) {
            return list.where((a) => a.type == type).toList();
          }
          return list;
        }
      }

      return [];
    } catch (e) {
      debugPrint('CargoService.getAddresses hatası: $e');
      return [];
    }
  }

  /// Tekil Adres Çek: GET /accounts/{accountId}/addresses/{addressId}
  Future<AddressModel?> getAddressById(String accountId, String addressId) async {
    try {
      final response = await _apiClient.get('/accounts/$accountId/addresses/$addressId');
      if (response.statusCode == 200) {
        final decoded = ApiClient.decodeResponse(response);
        if (decoded is Map<String, dynamic>) {
          return AddressModel.fromJson(decoded);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Yeni Adres Ekle (Gönderici: type=4 veya Alıcı: type=1)
  /// POST /accounts/{accountId}/addresses
  Future<AddressCreationResult> createAddress(
    String accountId,
    Map<String, dynamic> addressData,
  ) async {
    try {
      final response = await _apiClient.post(
        '/accounts/$accountId/addresses',
        body: addressData,
      );

      final decoded = ApiClient.decodeResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> dataMap = {};
        if (decoded is Map<String, dynamic>) {
          dataMap = decoded['data'] is Map<String, dynamic>
              ? decoded['data']
              : decoded;
        }
        final newAddress = AddressModel.fromJson(dataMap);
        return AddressCreationResult(
          isSuccess: true,
          message: 'Adres başarıyla kaydedildi.',
          address: newAddress,
        );
      } else {
        String errorMsg = 'Adres kaydedilemedi.';
        Map<String, dynamic>? errors;
        if (decoded is Map<String, dynamic>) {
          errorMsg = decoded['message'] ?? errorMsg;
          if (decoded['errors'] is Map<String, dynamic>) {
            errors = decoded['errors'] as Map<String, dynamic>;
            final firstErr = errors.values.first;
            if (firstErr is List && firstErr.isNotEmpty) {
              errorMsg = '$errorMsg (${firstErr.first})';
            }
          }
        }
        return AddressCreationResult(
          isSuccess: false,
          message: errorMsg,
          errors: errors,
        );
      }
    } catch (e) {
      debugPrint('CargoService.createAddress hatası: $e');
      return AddressCreationResult(
        isSuccess: false,
        message: 'Ağ hatası: Adres kaydedilemedi.',
      );
    }
  }

  /// POST /cargos/offer veya /cargos/calculate (Fiyat teklifi al)
  Future<List<CargoOffer>> calculateOffers(CargoCalculateRequest request) async {
    try {
      final response = await _apiClient.post(
        '/cargos/offer',
        body: request.toJson(),
      );

      if (response.statusCode == 200) {
        final decoded = ApiClient.decodeResponse(response);
        if (decoded is List) {
          return decoded.map((item) => CargoOffer.fromJson(item as Map<String, dynamic>)).toList();
        }
      } else {
        debugPrint('Teklif hesaplama hatası: ${response.statusCode} - ${response.body}');
      }
      return [];
    } catch (e) {
      debugPrint('CargoService.calculateOffers hatası: $e');
      return [];
    }
  }

  /// Kargoları çeker:
  /// POST /accounts/{accountId}/cargos/query veya GET /cargos
  Future<PaginatedCargosResponse> getCargos({
    String? accountId,
    int page = 1,
    int perPage = 6,
    String? filter, // pod, drafts
    bool? payOnDelivery,
    int? status,
    String? search,
  }) async {
    try {
      if (accountId != null && accountId.isNotEmpty) {
        final List<Map<String, dynamic>> fields = [
          {"name": "id"},
          {"name": "process_number"},
          {"name": "out_tracking_code"},
          {"name": "order_number"},
          {"name": "cargo_company_id"},
          if (status != null || filter == 'drafts')
            {
              "name": "status",
              "filters": [
                {"operator": "equals", "value": status ?? 0}
              ]
            }
          else
            {"name": "status"},
          {"name": "created_at"},
          {"name": "sender_id"},
          {"name": "receiver_id"},
          if (payOnDelivery == true || filter == 'pod')
            {
              "name": "pay_on_delivery",
              "filters": [
                {"operator": "equals", "value": 1}
              ]
            }
          else
            {"name": "pay_on_delivery"},
          {"name": "pay_on_delivery_amount"},
          {"name": "pay_on_delivery_type"},
          {"name": "pay_on_delivery_status"},
          {"name": "pay_on_delivery_offset_date"},
          {"name": "total_price"},
          {"name": "user_desi"},
          {"name": "valid_desi"},
          {"name": "description"},
          {"name": "cargo_company"},
          {"name": "latest_transaction"},
        ];

        final Map<String, dynamic> body = {
          "fields": fields,
          "paginate": {"page": page, "count": perPage},
        };

        if (search != null && search.isNotEmpty) {
          body["search"] = {
            "fields": ["process_number", "out_tracking_code", "order_number", "description"],
            "text": search,
          };
        }

        final response = await _apiClient.post(
          '/accounts/$accountId/cargos/query',
          body: body,
        );

        if (response.statusCode == 200) {
          final decoded = ApiClient.decodeResponse(response);
          if (decoded is Map<String, dynamic> && decoded['items'] is List) {
            final list = (decoded['items'] as List)
                .map((item) => CargoModel.fromJson(item as Map<String, dynamic>))
                .toList();

            final rawTotal = decoded['total'];
            int total = list.length;
            if (rawTotal is num) {
              total = rawTotal.toInt();
            } else if (rawTotal != null) {
              total = int.tryParse(rawTotal.toString()) ?? list.length;
            }
            final lastPage = (total <= 0) ? 1 : (total / perPage).ceil();

            final meta = PaginationMeta(
              currentPage: page,
              lastPage: lastPage > 0 ? lastPage : 1,
              perPage: perPage,
              total: total,
            );

            return PaginatedCargosResponse(data: list, meta: meta);
          }
        }
      }

      // Fallback: GET /cargos
      final query = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (filter != null && filter.isNotEmpty) 'filter': filter,
        'pay_on_delivery': ?payOnDelivery,
        'status': ?status,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _apiClient.get('/cargos', queryParameters: query);

      if (response.statusCode == 200) {
        final decoded = ApiClient.decodeResponse(response);
        if (decoded is Map<String, dynamic>) {
          final list = (decoded['data'] as List<dynamic>?)
                  ?.map((item) => CargoModel.fromJson(item as Map<String, dynamic>))
                  .toList() ??
              [];
          final meta = decoded['meta'] is Map<String, dynamic>
              ? PaginationMeta.fromJson(decoded['meta'] as Map<String, dynamic>)
              : null;
          return PaginatedCargosResponse(data: list, meta: meta);
        }
      }
      return PaginatedCargosResponse(data: []);
    } catch (e) {
      debugPrint('CargoService.getCargos hatası: $e');
      return PaginatedCargosResponse(data: []);
    }
  }

  /// POST /cargos (Kargo oluştur)
  Future<CargoCreationResult> createCargo(Map<String, dynamic> cargoData) async {
    try {
      debugPrint('createCargo request: $cargoData');
      final response = await _apiClient.post('/cargos', body: cargoData);
      debugPrint('createCargo response: ${response.statusCode} - ${response.body}');
      final decoded = ApiClient.decodeResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        String msg = 'Kargo başarıyla oluşturuldu.';
        if (decoded is Map<String, dynamic> && decoded['messages'] is List) {
          final msgs = decoded['messages'] as List;
          if (msgs.isNotEmpty && msgs.first['text'] != null) {
            msg = msgs.first['text'].toString();
          }
        }
        return CargoCreationResult(
          isSuccess: true,
          message: msg,
          data: decoded,
        );
      } else {
        String errorMsg = 'Kargo oluşturulamadı.';
        Map<String, dynamic>? errors;
        if (decoded is Map<String, dynamic>) {
          errorMsg = decoded['message'] ?? errorMsg;
          if (decoded['errors'] is Map<String, dynamic>) {
            errors = decoded['errors'] as Map<String, dynamic>;
            final firstEntry = errors.entries.firstOrNull;
            if (firstEntry != null && firstEntry.value is List && (firstEntry.value as List).isNotEmpty) {
              errorMsg = '$errorMsg: ${(firstEntry.value as List).first}';
            }
          }
        }
        return CargoCreationResult(
          isSuccess: false,
          message: errorMsg,
          errors: errors,
        );
      }
    } catch (e) {
      debugPrint('CargoService.createCargo hatası: $e');
      return CargoCreationResult(
        isSuccess: false,
        message: 'Ağ hatası: Kargo sunucuya iletilemedi.',
      );
    }
  }
}