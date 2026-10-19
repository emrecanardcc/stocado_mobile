import 'package:flutter/foundation.dart';
import '../../../core/models/pagination_meta.dart';
import '../../../core/network/api_client.dart';
import '../models/product_model.dart';

class PaginatedProductsResponse {
  final List<ProductModel> data;
  final PaginationMeta? meta;

  PaginatedProductsResponse({required this.data, this.meta});
}

class ProductsService {
  final ApiClient _apiClient;

  ProductsService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /products veya POST /accounts/{accountId}/products/query
  Future<PaginatedProductsResponse> getProducts({
    String? accountId,
    int page = 1,
    int perPage = 6,
    String? search,
  }) async {
    try {
      if (accountId != null && accountId.isNotEmpty) {
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
          ],
          "paginate": {"page": page, "count": perPage}
        };

        final response = await _apiClient.post(
          '/accounts/$accountId/products/query',
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

            final total = decoded['total'] is int ? decoded['total'] as int : list.length;
            final meta = PaginationMeta(
              currentPage: page,
              perPage: perPage,
              total: total,
              lastPage: (total / perPage).ceil() > 0 ? (total / perPage).ceil() : 1,
            );
            return PaginatedProductsResponse(data: list, meta: meta);
          }
        }
      }

      // Fallback: GET /products
      final query = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (search != null && search.isNotEmpty) 'search': search,
        'account_id': ?accountId,
      };

      final response = await _apiClient.get('/products', queryParameters: query);

      if (response.statusCode == 200) {
        final decoded = ApiClient.decodeResponse(response);
        if (decoded is Map<String, dynamic>) {
          final list = (decoded['data'] as List<dynamic>?)
                  ?.map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
                  .where((p) => p.isActive)
                  .toList() ??
              [];
          final meta = decoded['meta'] is Map<String, dynamic>
              ? PaginationMeta.fromJson(decoded['meta'] as Map<String, dynamic>)
              : null;
          return PaginatedProductsResponse(data: list, meta: meta);
        }
      }
      return PaginatedProductsResponse(data: []);
    } catch (e) {
      debugPrint('ProductsService.getProducts hatası: $e');
      return PaginatedProductsResponse(data: []);
    }
  }

  /// POST /accounts/{accountId}/products veya POST /products
  Future<bool> createProduct(ProductModel product, {String? accountId}) async {
    try {
      final path = (accountId != null && accountId.isNotEmpty)
          ? '/accounts/$accountId/products'
          : '/products';
      final response = await _apiClient.post(path, body: product.toJson());
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('ProductsService.createProduct hatası: $e');
      return false;
    }
  }

  /// PUT /accounts/{accountId}/products/{id}
  Future<bool> updateProduct(String id, ProductModel product, {String? accountId}) async {
    try {
      final path = (accountId != null && accountId.isNotEmpty)
          ? '/accounts/$accountId/products/$id'
          : '/products/$id';
      final response = await _apiClient.put(path, body: product.toJson());
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('ProductsService.updateProduct hatası: $e');
      return false;
    }
  }

  /// DELETE /accounts/{accountId}/products/{id}
  Future<bool> deleteProduct(String id, {String? accountId}) async {
    try {
      final path = (accountId != null && accountId.isNotEmpty)
          ? '/accounts/$accountId/products/$id'
          : '/products/$id';
      final response = await _apiClient.delete(path);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('ProductsService.deleteProduct hatası: $e');
      return false;
    }
  }
}
