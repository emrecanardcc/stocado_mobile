import 'package:flutter/foundation.dart';
import '../../../core/models/pagination_meta.dart';
import '../../../core/network/api_client.dart';
import '../models/product_model.dart';

class PaginatedProductsResponse {
  final List<ProductModel> data;
  final PaginationMeta? meta;
  final String? errorMessage;

  PaginatedProductsResponse({
    required this.data,
    this.meta,
    this.errorMessage,
  });
}

class ProductActionResult {
  final bool isSuccess;
  final String? message;
  final Map<String, dynamic>? errors;

  const ProductActionResult({
    required this.isSuccess,
    this.message,
    this.errors,
  });
}

class ProductsService {
  final ApiClient _apiClient;
  String? _cachedAccountId;

  ProductsService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Account ID'yi çözer: parametre olarak gelmemişse auth/me üzerinden dinamik alır
  Future<String?> _resolveAccountId({String? accountId}) async {
    if (accountId != null && accountId.isNotEmpty) {
      _cachedAccountId = accountId;
      return accountId;
    }
    if (_cachedAccountId != null && _cachedAccountId!.isNotEmpty) {
      return _cachedAccountId;
    }
    try {
      final meRes = await _apiClient.get('/auth/me');
      if (meRes.statusCode == 200) {
        final meData = ApiClient.decodeResponse(meRes);
        if (meData is Map<String, dynamic>) {
          final userId = meData['id']?.toString();
          if (userId != null && userId.isNotEmpty) {
            final accRes = await _apiClient.get('/users/$userId/accounts');
            if (accRes.statusCode == 200) {
              final accData = ApiClient.decodeResponse(accRes);
              if (accData is List && accData.isNotEmpty) {
                _cachedAccountId = accData.first['id']?.toString();
                return _cachedAccountId;
              } else if (accData is Map<String, dynamic> &&
                  accData['data'] is List &&
                  (accData['data'] as List).isNotEmpty) {
                _cachedAccountId = (accData['data'] as List).first['id']?.toString();
                return _cachedAccountId;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('ProductsService._resolveAccountId hatası: $e');
    }
    return null;
  }

  /// POST /accounts/{accountId}/products/query
  Future<PaginatedProductsResponse> getProducts({
    String? accountId,
    int page = 1,
    int perPage = 15,
    String? search,
  }) async {
    try {
      final targetAccountId = await _resolveAccountId(accountId: accountId);

      if (targetAccountId != null && targetAccountId.isNotEmpty) {
        final body = <String, dynamic>{
          "fields": [
            {"name": "id"},
            {"name": "name"},
            {"name": "code"},
            {"name": "barcode"},
            {"name": "price"},
            {"name": "desi"},
            {"name": "width"},
            {"name": "height"},
            {"name": "length"},
            {"name": "weight"},
            {"name": "created_at"},
            {"name": "updated_at"},
          ],
          "sort": [
            {"name": "id", "direction": "desc"}
          ],
          "paginate": {"page": page, "count": perPage}
        };

        if (search != null && search.isNotEmpty) {
          body["search"] = {
            "fields": ["name", "code", "barcode"],
            "text": search,
          };
        }

        final response = await _apiClient.post(
          '/accounts/$targetAccountId/products/query',
          body: body,
        );

        if (response.statusCode == 200) {
          final decoded = ApiClient.decodeResponse(response);
          if (decoded is Map<String, dynamic> && decoded['items'] is List) {
            var list = (decoded['items'] as List)
                .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
                .where((p) => p.isActive)
                .toList();

            if (search != null && search.isNotEmpty) {
              final queryStr = search.toLowerCase();
              list = list.where((p) =>
                p.name.toLowerCase().contains(queryStr) ||
                (p.code?.toLowerCase().contains(queryStr) ?? false) ||
                (p.barcode?.toLowerCase().contains(queryStr) ?? false)
              ).toList();
            }

            final rawTotal = decoded['total'];
            int total = list.length;
            if (rawTotal is num && rawTotal > 0) {
              total = rawTotal.toInt();
            } else if (rawTotal != null && rawTotal != -1) {
              total = int.tryParse(rawTotal.toString()) ?? list.length;
            }

            final lastPage = (total <= 0 || perPage <= 0) ? 1 : (total / perPage).ceil();
            final meta = PaginationMeta(
              currentPage: page,
              perPage: perPage,
              total: total,
              lastPage: lastPage > 0 ? lastPage : 1,
            );
            return PaginatedProductsResponse(data: list, meta: meta);
          }
        } else {
          final errorMsg = ApiClient.parseError(response, defaultMessage: 'Ürünler yüklenemedi.');
          return PaginatedProductsResponse(data: [], errorMessage: errorMsg);
        }
      }

      return PaginatedProductsResponse(data: [], errorMessage: 'Hesap bilgisi doğrulanamadı.');
    } catch (e) {
      debugPrint('ProductsService.getProducts hatası: $e');
      final errorMsg = ApiClient.parseError(e, defaultMessage: 'Ağ bağlantısı kurulamadı.');
      return PaginatedProductsResponse(data: [], errorMessage: errorMsg);
    }
  }

  /// POST /accounts/{accountId}/products
  Future<ProductActionResult> createProduct(ProductModel product, {String? accountId}) async {
    try {
      final targetAccountId = await _resolveAccountId(accountId: accountId);
      final path = (targetAccountId != null && targetAccountId.isNotEmpty)
          ? '/accounts/$targetAccountId/products'
          : '/products';
      final response = await _apiClient.post(path, body: product.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return const ProductActionResult(isSuccess: true, message: 'Ürün başarıyla eklendi.');
      } else {
        final errorMsg = ApiClient.parseError(response, defaultMessage: 'Ürün kaydedilemedi.');
        return ProductActionResult(isSuccess: false, message: errorMsg);
      }
    } catch (e) {
      debugPrint('ProductsService.createProduct hatası: $e');
      return ProductActionResult(
        isSuccess: false,
        message: ApiClient.parseError(e, defaultMessage: 'Ağ hatası: Ürün kaydedilemedi.'),
      );
    }
  }

  /// PUT /accounts/{accountId}/products/{id}
  Future<ProductActionResult> updateProduct(String id, ProductModel product, {String? accountId}) async {
    try {
      final targetAccountId = await _resolveAccountId(accountId: accountId);
      final path = (targetAccountId != null && targetAccountId.isNotEmpty)
          ? '/accounts/$targetAccountId/products/$id'
          : '/products/$id';
      final response = await _apiClient.put(path, body: product.toJson());
      if (response.statusCode == 200) {
        return const ProductActionResult(isSuccess: true, message: 'Ürün başarıyla güncellendi.');
      } else {
        final errorMsg = ApiClient.parseError(response, defaultMessage: 'Ürün güncellenemedi.');
        return ProductActionResult(isSuccess: false, message: errorMsg);
      }
    } catch (e) {
      debugPrint('ProductsService.updateProduct hatası: $e');
      return ProductActionResult(
        isSuccess: false,
        message: ApiClient.parseError(e, defaultMessage: 'Ağ hatası: Ürün güncellenemedi.'),
      );
    }
  }

  /// DELETE /accounts/{accountId}/products/{id}
  Future<ProductActionResult> deleteProduct(String id, {String? accountId}) async {
    try {
      final targetAccountId = await _resolveAccountId(accountId: accountId);
      final path = (targetAccountId != null && targetAccountId.isNotEmpty)
          ? '/accounts/$targetAccountId/products/$id'
          : '/products/$id';
      final response = await _apiClient.delete(path);
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const ProductActionResult(isSuccess: true, message: 'Ürün başarıyla silindi.');
      } else {
        final errorMsg = ApiClient.parseError(
          response,
          defaultMessage: 'Ürün silinemedi. Aktif bir kargoda kullanılıyor olabilir.',
        );
        return ProductActionResult(isSuccess: false, message: errorMsg);
      }
    } catch (e) {
      debugPrint('ProductsService.deleteProduct hatası: $e');
      return ProductActionResult(
        isSuccess: false,
        message: ApiClient.parseError(e, defaultMessage: 'Ağ hatası: Ürün silinemedi.'),
      );
    }
  }
}
