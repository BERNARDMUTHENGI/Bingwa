import 'package:dio/dio.dart';
import '../../../core/network/admin_api_client.dart';
import '../../plans/models/plan.dart';

class AdminPlanRepository {
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

  // POST /api/v1/admin/plans
  Future<Plan> createPlan(Map<String, dynamic> planData) async {
    try {
      final response = await _apiClient.dio.post('/api/v1/admin/plans', data: planData);
      final data = _extractData(response.data);
      return Plan.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/admin/plans/:id
  Future<Plan> updatePlan(int id, Map<String, dynamic> updateData) async {
    try {
      final response = await _apiClient.dio.put('/api/v1/admin/plans/$id', data: updateData);
      final data = _extractData(response.data);
      return Plan.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/admin/plans/:id/activate
  Future<void> activatePlan(int id) async {
    try {
      await _apiClient.dio.put('/api/v1/admin/plans/$id/activate');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/admin/plans/:id/deactivate
  Future<void> deactivatePlan(int id) async {
    try {
      await _apiClient.dio.put('/api/v1/admin/plans/$id/deactivate');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE /api/v1/admin/plans/:id
  Future<void> deletePlan(int id) async {
    try {
      await _apiClient.dio.delete('/api/v1/admin/plans/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/admin/plans/stats
  Future<Map<String, dynamic>> getPlanStats() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/admin/plans/stats');
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}