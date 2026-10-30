import 'package:flutter/foundation.dart';
import '../../../core/models/pagination_meta.dart';
import '../../../core/network/api_client.dart';
import '../models/address_model.dart';
import '../models/cargo_model.dart';
import '../models/cargo_offer_model.dart';

class PaginatedCargosResponse {
  final List<CargoModel> data;
  final PaginationMeta? meta;
  final String? errorMessage;

  PaginatedCargosResponse({
    required this.data,
    this.meta,
    this.errorMessage,
  });
}

class OfferCalculationResult {
  final bool isSuccess;
  final List<CargoOffer> offers;
  final String? errorMessage;

  const OfferCalculationResult({
    required this.isSuccess,
    this.offers = const [],
    this.errorMessage,
  });
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
        final errorMsg = ApiClient.parseError(response, defaultMessage: 'Adres kaydedilemedi.');
        Map<String, dynamic>? errors;
        if (decoded is Map<String, dynamic> && decoded['errors'] is Map<String, dynamic>) {
          errors = decoded['errors'] as Map<String, dynamic>;
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
        message: ApiClient.parseError(e, defaultMessage: 'Ağ hatası: Adres kaydedilemedi.'),
      );
    }
  }

  /// POST /cargos/calculate (Alias: POST /cargos/offer) - Fiyat teklifi al
  Future<OfferCalculationResult> calculateOffers(CargoCalculateRequest request) async {
    try {
      // 1. Resmi OpenAPI standardı: string enum (send/receive, cash/credit_card) ile /cargos/calculate dene
      var response = await _apiClient.post(
        '/cargos/calculate',
        body: request.toJson(useIntegerEnums: false),
      );

      // Alias uç: Eğer /cargos/calculate 404 ise /cargos/offer dene
      if (response.statusCode == 404) {
        response = await _apiClient.post(
          '/cargos/offer',
          body: request.toJson(useIntegerEnums: false),
        );
      }

      // Validasyon hatası (422/400) durumunda integer fallback ile geriye dönük uyumluluğu sağla
      if (response.statusCode == 422 || response.statusCode == 400) {
        final fallbackRes = await _apiClient.post(
          '/cargos/calculate',
          body: request.toJson(useIntegerEnums: true),
        );
        if (fallbackRes.statusCode == 200) {
          response = fallbackRes;
        } else if (fallbackRes.statusCode == 404) {
          final fallbackOfferRes = await _apiClient.post(
            '/cargos/offer',
            body: request.toJson(useIntegerEnums: true),
          );
          if (fallbackOfferRes.statusCode == 200) {
            response = fallbackOfferRes;
          }
        }
      }

      if (response.statusCode == 200) {
        final decoded = ApiClient.decodeResponse(response);
        if (decoded is List) {
          final offers = decoded.map((item) => CargoOffer.fromJson(item as Map<String, dynamic>)).toList();
          return OfferCalculationResult(isSuccess: true, offers: offers);
        }
      }
      final errorMsg = ApiClient.parseError(response, defaultMessage: 'Fiyat teklifleri hesaplanamadı.');
      return OfferCalculationResult(isSuccess: false, errorMessage: errorMsg);
    } catch (e) {
      debugPrint('CargoService.calculateOffers hatası: $e');
      return OfferCalculationResult(
        isSuccess: false,
        errorMessage: ApiClient.parseError(e, defaultMessage: 'Ağ bağlantısı kurulamadı. Teklifler alınamadı.'),
      );
    }
  }

  /// Taslak durumundaki kargo sayısını hızlıca çeker
  Future<int?> getDraftCount(String accountId) async {
    try {
      final response = await _apiClient.post(
        '/accounts/$accountId/cargos/query',
        body: {
          "fields": [
            {
              "name": "status",
              "filters": [
                {"operator": "equals", "value": 0}
              ]
            }
          ],
          "paginate": {"page": 1, "count": 1}
        },
      );
      if (response.statusCode == 200) {
        final decoded = ApiClient.decodeResponse(response);
        if (decoded is Map<String, dynamic>) {
          final rawTotal = decoded['total'] ?? (decoded['paginate'] is Map ? decoded['paginate']['total'] : null);
          if (rawTotal is num) return rawTotal.toInt();
          if (rawTotal != null) return int.tryParse(rawTotal.toString());
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Kargoları çeker:
  /// POST /accounts/{accountId}/cargos/query veya GET /cargos
  Future<PaginatedCargosResponse> getCargos({
    String? accountId,
    int page = 1,
    int perPage = 15,
    String? filter, // pod, drafts
    bool? payOnDelivery,
    int? status,
    String? search,
    String? cargoCompanyId,
    String? statusFilter,
    String sortDirection = 'desc',
  }) async {
    try {
      int? statusInt = status;
      if (statusFilter != null && statusFilter.isNotEmpty && statusFilter != 'all') {
        final parsed = int.tryParse(statusFilter);
        if (parsed != null) {
          statusInt = parsed;
        } else if (statusFilter == 'drafts') {
          statusInt = 0;
        } else if (statusFilter == 'active' || statusFilter == 'yolda' || statusFilter == 'in_transit') {
          statusInt = 1;
        } else if (statusFilter == 'delivered' || statusFilter == 'completed') {
          statusInt = 2;
        } else if (statusFilter == 'cancelled') {
          statusInt = 3;
        } else if (statusFilter == 'failed' || statusFilter == 'sorunlu' || statusFilter == 'problematic') {
          statusInt = 4;
        }
      }

      if (accountId != null && accountId.isNotEmpty) {
        String? targetCompanyId;
        if (cargoCompanyId != null && cargoCompanyId.isNotEmpty) {
          final c = cargoCompanyId.toLowerCase();
          if (c.contains('ptt')) {
            targetCompanyId = 'ptt-kargo';
          } else if (c.contains('surat') || c.contains('sürat')) {
            targetCompanyId = 'surat-kargo';
          } else if (c.contains('yurtici') || c.contains('yurtiçi')) {
            targetCompanyId = 'yurtici-kargo';
          } else if (c.contains('hepsijet')) {
            targetCompanyId = 'hepsijet';
          } else if (c.contains('ups')) {
            targetCompanyId = 'ups';
          } else if (c.contains('kolay') || c.contains('gelsin')) {
            targetCompanyId = 'kolay-gelsin';
          } else {
            targetCompanyId = cargoCompanyId;
          }
        }

        final List<Map<String, dynamic>> fields = [
          {"name": "id"},
          {"name": "process_number"},
          {"name": "out_tracking_code"},
          {"name": "order_number"},
          if (targetCompanyId != null && targetCompanyId.isNotEmpty)
            {
              "name": "cargo_company_id",
              "filters": [
                {"operator": "equals", "value": targetCompanyId}
              ]
            }
          else
            {"name": "cargo_company_id"},
          if (filter == 'drafts' || statusInt == 0)
            {
              "name": "status",
              "filters": [
                {"operator": "equals", "value": 0}
              ]
            }
          else if (statusInt != null)
            {
              "name": "status",
              "filters": [
                {"operator": "equals", "value": statusInt}
              ]
            }
          else
            {"name": "status"},
          {"name": "out_tracking_link"},
          {"name": "created_at", "sorting": sortDirection},
          {"name": "sender_id"},
          {"name": "receiver_id"},
          {"name": "receiver.id"},
          {"name": "receiver.name"},
          {"name": "receiver.phone"},
          {"name": "receiver.details"},
          {"name": "receiver.city_id"},
          {"name": "receiver.district_id"},
          {"name": "receiver.city.name"},
          {"name": "receiver.district.name"},
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
          {"name": "pay_on_delivery_cost"},
          {"name": "pod_transaction_id"},
          {"name": "collection_period"},
          {"name": "pay_on_delivery_type"},
          {"name": "pay_on_delivery_status"},
          {"name": "pay_on_delivery_offset_date"},
          {"name": "total_price"},
          {"name": "user_desi"},
          {"name": "valid_desi"},
          {"name": "description"},
          {"name": "cargo_company"},
          {"name": "latest_transaction_type"},
          {"name": "latest_transaction.id"},
          {"name": "latest_transaction.type"},
          {"name": "latest_transaction.description"},
          {"name": "latest_transaction.location"},
          {"name": "latest_transaction.created_at"},
        ];

        final Map<String, dynamic> body = {
          "fields": fields,
          "paginate": {"page": page, "count": perPage},
          "sort": [
            {"name": "created_at", "direction": sortDirection},
            {"name": "id", "direction": sortDirection}
          ],
        };

        if (search != null && search.isNotEmpty) {
          body["search"] = {
            "fields": [
              "process_number",
              "out_tracking_code",
              "order_number",
              "description",
              "receiver.name",
              "receiver.phone"
            ],
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
            var list = (decoded['items'] as List)
                .map((item) => CargoModel.fromJson(item as Map<String, dynamic>))
                .toList();

            // Kargo Firması Filtresi (istemci kontrolü)
            if (cargoCompanyId != null && cargoCompanyId.isNotEmpty) {
              final q = cargoCompanyId.toLowerCase();
              list = list.where((c) {
                final idStr = c.cargoCompanyId?.toLowerCase() ?? '';
                final titleStr = c.cargoCompany?.title.toLowerCase() ?? '';
                return idStr.contains(q) || titleStr.contains(q);
              }).toList();
            }

            // Kargo Durumu Filtresi (istemci kontrolü / güvencesi)
            if (statusInt != null) {
              list = list.where((c) => c.status == statusInt).toList();
            }

            // Yeniden Eskiye / Eskiden Yeniye Sıralama
            list.sort((a, b) => CargoModel.compareCargos(a, b, sortDirection: sortDirection));

            final rawTotal = decoded['total'];
            int total = list.length;
            if (rawTotal is num) {
              total = rawTotal.toInt();
            } else if (rawTotal != null) {
              total = int.tryParse(rawTotal.toString()) ?? list.length;
            }
            final lastPage = (total <= 0)
                ? (list.length >= perPage ? page + 1 : page)
                : (total / perPage).ceil();

            final meta = PaginationMeta(
              currentPage: page,
              lastPage: lastPage > 0 ? lastPage : 1,
              perPage: perPage,
              total: total > 0 ? total : list.length,
            );

            return PaginatedCargosResponse(data: list, meta: meta);
          }
        } else {
          final errorMsg = ApiClient.parseError(response, defaultMessage: 'Kargolar yüklenemedi.');
          return PaginatedCargosResponse(data: [], errorMessage: errorMsg);
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
        if (cargoCompanyId != null && cargoCompanyId.isNotEmpty) 'cargo_company_id': cargoCompanyId,
        'sort_direction': sortDirection,
        'order_by': 'created_at',
      };

      final response = await _apiClient.get('/cargos', queryParameters: query);

      if (response.statusCode == 200) {
        final decoded = ApiClient.decodeResponse(response);
        if (decoded is Map<String, dynamic>) {
          var list = (decoded['data'] as List<dynamic>?)
                  ?.map((item) => CargoModel.fromJson(item as Map<String, dynamic>))
                  .toList() ??
              [];

          // Kargo Firması Filtresi (istemci kontrolü)
          if (cargoCompanyId != null && cargoCompanyId.isNotEmpty) {
            final q = cargoCompanyId.toLowerCase();
            list = list.where((c) {
              final idStr = c.cargoCompanyId?.toLowerCase() ?? '';
              final titleStr = c.cargoCompany?.title.toLowerCase() ?? '';
              return idStr.contains(q) || titleStr.contains(q);
            }).toList();
          }

          // Kargo Durumu Filtresi (istemci kontrolü / güvencesi)
          if (statusInt != null) {
            list = list.where((c) => c.status == statusInt).toList();
          }

          // Yeniden Eskiye / Eskiden Yeniye Sıralama
          list.sort((a, b) => CargoModel.compareCargos(a, b, sortDirection: sortDirection));

          final meta = decoded['meta'] is Map<String, dynamic>
              ? PaginationMeta.fromJson(decoded['meta'] as Map<String, dynamic>)
              : null;
          return PaginatedCargosResponse(data: list, meta: meta);
        }
      }
      final errorMsg = ApiClient.parseError(response, defaultMessage: 'Kargolar yüklenemedi.');
      return PaginatedCargosResponse(data: [], errorMessage: errorMsg);
    } catch (e) {
      debugPrint('CargoService.getCargos hatası: $e');
      final errorMsg = ApiClient.parseError(e, defaultMessage: 'Ağ bağlantısı kurulamadı.');
      return PaginatedCargosResponse(data: [], errorMessage: errorMsg);
    }
  }

  /// Tekil Kargo Detayı ve Canlı Takip Hareketlerini Çeker:
  /// GET /accounts/{accountId}/cargos/{cargoId} veya GET /cargos/{cargoId}
  Future<CargoModel?> getCargoDetail(String cargoId, {String? accountId}) async {
    try {
      if (accountId != null && accountId.isNotEmpty) {
        final accResponse = await _apiClient.get('/accounts/$accountId/cargos/$cargoId');
        if (accResponse.statusCode == 200) {
          final decoded = ApiClient.decodeResponse(accResponse);
          if (decoded is Map<String, dynamic>) {
            final dataMap = decoded['data'] is Map<String, dynamic>
                ? decoded['data'] as Map<String, dynamic>
                : decoded;
            return CargoModel.fromJson(dataMap);
          }
        }
      }

      final response = await _apiClient.get('/cargos/$cargoId');
      if (response.statusCode == 200) {
        final decoded = ApiClient.decodeResponse(response);
        if (decoded is Map<String, dynamic>) {
          final dataMap = decoded['data'] is Map<String, dynamic>
              ? decoded['data'] as Map<String, dynamic>
              : decoded;
          return CargoModel.fromJson(dataMap);
        }
      }
      return null;
    } catch (e) {
      debugPrint('getCargoDetail error: $e');
      return null;
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
        if (decoded is Map<String, dynamic>) {
          if (decoded['message'] != null && decoded['message'].toString().trim().isNotEmpty) {
            msg = decoded['message'].toString();
          } else if (decoded['messages'] is List) {
            final msgs = decoded['messages'] as List;
            if (msgs.isNotEmpty && msgs.first is Map && msgs.first['text'] != null) {
              msg = msgs.first['text'].toString();
            }
          }
        }
        return CargoCreationResult(
          isSuccess: true,
          message: msg,
          data: decoded,
        );
      } else {
        final errorMsg = ApiClient.parseError(
          response,
          defaultMessage: 'Kargo oluşturulamadı. Lütfen bilgilerinizi kontrol ediniz.',
        );
        Map<String, dynamic>? errors;
        if (decoded is Map<String, dynamic> && decoded['errors'] is Map<String, dynamic>) {
          errors = decoded['errors'] as Map<String, dynamic>;
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
        message: ApiClient.parseError(e, defaultMessage: 'Ağ hatası: Kargo sunucuya iletilemedi.'),
      );
    }
  }
}