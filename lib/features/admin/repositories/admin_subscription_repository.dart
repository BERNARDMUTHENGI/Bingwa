import 'package:dio/dio.dart';
import '../../../core/network/admin_api_client.dart';
import '../../subscriptions/models/subscription.dart';

class AdminSubscriptionRepository {
  final AdminApiClient _apiClient = AdminApiClient();

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

  // GET /api/v1/admin/subscriptions?page=1&page_size=20
  Future<List<Subscription>> getAllSubscriptions({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/admin/subscriptions',
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

  // GET /api/v1/admin/subscriptions/:id
  Future<Subscription> getSubscriptionById(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/admin/subscriptions/$id');
      final data = _extractData(response.data);
      return Subscription.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/admin/subscriptions/expiring?days=7
  Future<List<Subscription>> getExpiringSubscriptions({int days = 7}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/admin/subscriptions/expiring',
        queryParameters: {'days': days},
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

  // PUT /api/v1/admin/subscriptions/:id/deactivate
  Future<void> deactivateSubscription(int id) async {
    try {
      await _apiClient.dio.put('/api/v1/admin/subscriptions/$id/deactivate');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/admin/subscriptions/:id/suspend
  Future<void> suspendSubscription(int id) async {
    try {
      await _apiClient.dio.put('/api/v1/admin/subscriptions/$id/suspend');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/admin/subscriptions/:id/reactivate
  Future<void> reactivateSubscription(int id) async {
    try {
      await _apiClient.dio.put('/api/v1/admin/subscriptions/$id/reactivate');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST /api/v1/admin/subscriptions/:id/cancel
  Future<void> cancelSubscription(int id) async {
    try {
      await _apiClient.dio.post('/api/v1/admin/subscriptions/$id/cancel');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/admin/subscriptions/stats
  Future<Map<String, dynamic>> getSubscriptionStats() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/admin/subscriptions/stats');
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}