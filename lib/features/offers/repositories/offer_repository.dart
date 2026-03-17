import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../../../core/network/api_client.dart';
import '../models/offer.dart';

class OfferRepository {
  static const String _boxName = 'offers';
  late Box<Offer> _box;
  final ApiClient _apiClient = ApiClient();

  OfferRepository() {
    _box = Hive.box<Offer>(_boxName);
  }

  List<Offer> getLocalOffers() {
    return _box.values.toList();
  }

  Future<void> saveOffers(List<Offer> offers) async {
    await _box.clear();
    for (var offer in offers) {
      await _box.put(offer.id, offer);
    }
  }

  dynamic _extractData(dynamic response) {
    if (response is Map && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
      return 'Server error: ${e.response!.statusCode}';
    } else {
      return 'Network error: ${e.message}';
    }
  }

  // ==================== GET /offers (paginated) ====================
  Future<List<Offer>> getOffers({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/offers',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      final data = _extractData(response.data);
      if (data is Map && data.containsKey('offers')) {
        final List offersJson = data['offers'];
        return offersJson.map((json) => Offer.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== GET /offers/search ====================
  Future<List<Offer>> searchOffers(String query, {String? type}) async {
    try {
      final params = {'q': query};
      if (type != null) params['type'] = type;
      final response = await _apiClient.dio.get(
        '/api/v1/offers/search',
        queryParameters: params,
      );
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => Offer.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== GET /offers/stats ====================
  Future<Map<String, dynamic>> getOfferStats() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/offers/stats');
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== GET /offers/:id ====================
  Future<Offer> getOfferById(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/offers/$id');
      final data = _extractData(response.data);
      return Offer.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== GET /offers/code/:code ====================
  Future<Offer> getOfferByCode(String code) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/offers/code/$code');
      final data = _extractData(response.data);
      return Offer.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== PUT /offers/:id (update) ====================
  Future<Offer> updateOffer(int id, Map<String, dynamic> updateData) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/v1/offers/$id',
        data: updateData,
      );
      final data = _extractData(response.data);
      return Offer.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== DELETE /offers/:id ====================
  Future<void> deleteOffer(int id) async {
    try {
      await _apiClient.dio.delete('/api/v1/offers/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== PUT /offers/:id/activate ====================
  Future<void> activateOffer(int id) async {
    try {
      await _apiClient.dio.put('/api/v1/offers/$id/activate');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== PUT /offers/:id/deactivate ====================
  Future<void> deactivateOffer(int id) async {
    try {
      await _apiClient.dio.put('/api/v1/offers/$id/deactivate');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== PUT /offers/:id/pause ====================
  Future<void> pauseOffer(int id) async {
    try {
      await _apiClient.dio.put('/api/v1/offers/$id/pause');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== POST /offers/:id/clone ====================
  Future<Offer> cloneOffer(int id, String newName) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/offers/$id/clone',
        data: {'new_name': newName},
      );
      final data = _extractData(response.data);
      return Offer.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== GET /offers/by-amount ====================
  Future<List<Offer>> getOffersByAmount(double amount) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/offers/by-amount',
        queryParameters: {'amount': amount},
      );
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => Offer.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== GET /offers/by-amount-range ====================
  Future<List<Offer>> getOffersByAmountRange(double min, double max) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/offers/by-amount-range',
        queryParameters: {'min_amount': min, 'max_amount': max},
      );
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => Offer.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== GET /offers/by-price ====================
  Future<List<Offer>> getOffersByPrice(double price) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/offers/by-price',
        queryParameters: {'price': price},
      );
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => Offer.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== GET /offers/by-type-and-amount ====================
  Future<List<Offer>> getOffersByTypeAndAmount(String type, double amount) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/offers/by-type-and-amount',
        queryParameters: {'type': type, 'amount': amount},
      );
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => Offer.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== GET /offers/:id/price ====================
  Future<Map<String, dynamic>> calculateOfferPrice(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/offers/$id/price');
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== GET /offers/:id/ussd-code ====================
  Future<String> generateUssdCode(int id, String phone) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/offers/$id/ussd-code',
        queryParameters: {'phone': phone},
      );
      final data = _extractData(response.data);
      return data['ussd_code'] ?? '';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== GET /offers/:id/ussd-code/execute ====================
  Future<String> getUssdCodeForExecution(int id, String phone) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/offers/$id/ussd-code/execute',
        queryParameters: {'phone': phone},
      );
      final data = _extractData(response.data);
      return data['ussd_code'] ?? '';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Create offer ====================
  Future<Offer> createOffer({
    required String name,
    String? description,
    required String type,
    required double bundleAmount,
    required String units,
    required double price,
    required String currency,
    double? discountPercentage,
    required int validityDays,
    String? validityLabel,
    required String ussdCodeTemplate,
    required String ussdProcessingType,
    String? ussdExpectedResponse,
    String? ussdErrorPattern,
    bool? isFeatured,
    bool? isRecurring,
    int? maxPurchasesPerCustomer,
    DateTime? availableFrom,
    DateTime? availableUntil,
    List<String>? tags,
    List<String>? menuPath,                // <-- store this inside metadata
    Map<String, dynamic>? metadata,
  }) async {
    try {
      String? formatDate(DateTime? date) {
        if (date == null) return null;
        return date.toUtc().toIso8601String();
      }

      // Build metadata including menuPath if provided
      Map<String, dynamic>? finalMetadata;
      if (metadata != null || menuPath != null) {
        finalMetadata = Map<String, dynamic>.from(metadata ?? {});
        if (menuPath != null) {
          finalMetadata['menu_path'] = menuPath;   // embed path in metadata
        }
      }

      final payload = {
        'name': name,
        if (description != null) 'description': description,
        'type': type,
        'amount': bundleAmount,
        'units': units,
        'price': price,
        'currency': currency,
        if (discountPercentage != null) 'discount_percentage': discountPercentage,
        'validity_days': validityDays,
        if (validityLabel != null) 'validity_label': validityLabel,
        'ussd_code_template': ussdCodeTemplate,
        'ussd_processing_type': ussdProcessingType,
        if (ussdExpectedResponse != null) 'ussd_expected_response': ussdExpectedResponse,
        if (ussdErrorPattern != null) 'ussd_error_pattern': ussdErrorPattern,
        if (isFeatured != null) 'is_featured': isFeatured,
        if (isRecurring != null) 'is_recurring': isRecurring,
        if (maxPurchasesPerCustomer != null) 'max_purchases_per_customer': maxPurchasesPerCustomer,
        if (availableFrom != null) 'available_from': formatDate(availableFrom),
        if (availableUntil != null) 'available_until': formatDate(availableUntil),
        if (tags != null) 'tags': tags,
        if (finalMetadata != null) 'metadata': finalMetadata,   // send enriched metadata
      };

      debugPrint('📤 Sending create offer payload: $payload');
      final response = await _apiClient.dio.post('/api/v1/offers', data: payload);
      final data = _extractData(response.data);
      debugPrint('📥 Create offer response: $data');
      return Offer.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Sync ====================
  Future<void> syncOffers() async {
    final apiOffers = await getOffers(page: 1, pageSize: 100);
    await saveOffers(apiOffers);
  }
}