import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/plan.dart';

class PlanRepository {
  final ApiClient _apiClient = ApiClient();

  // Helper to extract data field
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

  // GET /api/v1/plans/public
  Future<List<Plan>> getPublicPlans() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/plans/public');
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => Plan.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/plans/compare?plan1=1&plan2=2
  Future<Map<String, dynamic>> comparePlans(int planId1, int planId2) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/plans/compare',
        queryParameters: {'plan1': planId1, 'plan2': planId2},
      );
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/plans?page=1&page_size=20
  Future<List<Plan>> getPlans({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/plans',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => Plan.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/plans/:id
  Future<Plan> getPlanById(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/plans/$id');
      final data = _extractData(response.data);
      return Plan.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/plans/code/:code
  Future<Plan> getPlanByCode(String code) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/plans/code/$code');
      final data = _extractData(response.data);
      return Plan.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}