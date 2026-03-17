import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/subscription.dart';

class SubscriptionRepository {
  final ApiClient _apiClient = ApiClient();

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

  // POST /api/v1/subscriptions
  Future<Subscription> createSubscription({
    required int subscriptionPlanId,
    String? promotionalCode,
    required bool autoRenew,
    required double amountPaid,
    required String currency,
    required String paymentReference,
    required String paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/subscriptions',
        data: {
          'subscription_plan_id': subscriptionPlanId,
          if (promotionalCode != null) 'promotional_code': promotionalCode,
          'auto_renew': autoRenew,
          'amount_paid': amountPaid,
          'currency': currency,
          'payment_reference': paymentReference,
          'payment_method': paymentMethod,
          if (metadata != null) 'metadata': metadata,
        },
      );
      final data = _extractData(response.data);
      return Subscription.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST /api/v1/subscriptions/renew
  Future<Subscription> renewSubscription({
    required double amountPaid,
    required String currency,
    required String paymentReference,
    required String paymentMethod,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/subscriptions/renew',
        data: {
          'amount_paid': amountPaid,
          'currency': currency,
          'payment_reference': paymentReference,
          'payment_method': paymentMethod,
        },
      );
      final data = _extractData(response.data);
      return Subscription.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/subscriptions?page=1&page_size=20
  Future<List<Subscription>> getSubscriptions({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/subscriptions',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => Subscription.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/subscriptions/active
  Future<List<Subscription>> getActiveSubscriptions() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/subscriptions/active');
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => Subscription.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/subscriptions/:id
  Future<Subscription> getSubscriptionById(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/subscriptions/$id');
      final data = _extractData(response.data);
      return Subscription.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/subscriptions/:id
  Future<Subscription> updateSubscription(int id, Map<String, dynamic> updateData) async {
    try {
      final response = await _apiClient.dio.put('/api/v1/subscriptions/$id', data: updateData);
      final data = _extractData(response.data);
      return Subscription.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST /api/v1/subscriptions/:id/cancel
  Future<void> cancelSubscription(int id) async {
    try {
      await _apiClient.dio.post('/api/v1/subscriptions/$id/cancel');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/subscriptions/usage/current
  Future<Map<String, dynamic>> getCurrentUsage() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/subscriptions/usage/current');
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/subscriptions/access/check
  Future<bool> checkAccess() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/subscriptions/access/check');
      final data = _extractData(response.data);
      return data['has_access'] ?? false;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/subscriptions/stats/overview
  Future<Map<String, dynamic>> getSubscriptionStats() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/subscriptions/stats/overview');
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/subscriptions/stats/by-status?status=active
  Future<List<Subscription>> getSubscriptionsByStatus(String status) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/subscriptions/stats/by-status',
        queryParameters: {'status': status},
      );
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => Subscription.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}