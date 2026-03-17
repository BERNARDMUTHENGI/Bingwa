import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/schedule.dart';

class ScheduleRepository {
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

  // POST /api/v1/schedules
  Future<Schedule> createSchedule({
    required int offerId,
    required String customerPhone,
    required DateTime scheduledTime,
    required bool autoRenew,
    String? renewalPeriod,
    int? renewalLimit,
    DateTime? renewUntil,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/schedules',
        data: {
          'offer_id': offerId,
          'customer_phone': customerPhone,
          'scheduled_time': scheduledTime.toUtc().toIso8601String(),
          'auto_renew': autoRenew,
          if (renewalPeriod != null) 'renewal_period': renewalPeriod,
          if (renewalLimit != null) 'renewal_limit': renewalLimit,
          if (renewUntil != null) 'renew_until': renewUntil.toUtc().toIso8601String(),
          if (metadata != null) 'metadata': metadata,
        },
      );
      final data = _extractData(response.data);
      return Schedule.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/schedules?page=1&page_size=20
  Future<List<Schedule>> getSchedules({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/schedules',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => Schedule.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/schedules/:id
  Future<Schedule> getScheduleById(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/schedules/$id');
      final data = _extractData(response.data);
      return Schedule.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/schedules/:id
  Future<Schedule> updateSchedule(int id, Map<String, dynamic> updateData) async {
    try {
      final response = await _apiClient.dio.put('/api/v1/schedules/$id', data: updateData);
      final data = _extractData(response.data);
      return Schedule.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/schedules/:id/pause
  Future<void> pauseSchedule(int id) async {
    try {
      await _apiClient.dio.put('/api/v1/schedules/$id/pause');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/schedules/:id/resume
  Future<void> resumeSchedule(int id) async {
    try {
      await _apiClient.dio.put('/api/v1/schedules/$id/resume');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/schedules/:id/cancel
  Future<void> cancelSchedule(int id) async {
    try {
      await _apiClient.dio.put('/api/v1/schedules/$id/cancel');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST /api/v1/schedules/:id/execute
  Future<void> executeSchedule(int id, {
    required String ussdResponse,
    required String ussdSessionId,
    required int ussdProcessingTime,
    required String status,
    String? failureReason,
  }) async {
    try {
      await _apiClient.dio.post(
        '/api/v1/schedules/$id/execute',
        data: {
          'ussd_response': ussdResponse,
          'ussd_session_id': ussdSessionId,
          'ussd_processing_time': ussdProcessingTime,
          'status': status,
          if (failureReason != null) 'failure_reason': failureReason,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/schedules/due
  Future<List<Schedule>> getDueSchedules() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/schedules/due');
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => Schedule.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/schedules/:id/history?page=1&page_size=20
  Future<List<dynamic>> getScheduleHistory(int id, {int page = 1, int pageSize = 20}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/schedules/$id/history',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      return _extractData(response.data) ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/schedules/stats/overview
  Future<Map<String, dynamic>> getScheduleStats() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/schedules/stats/overview');
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/schedules/stats/by-status?status=active
  Future<List<Schedule>> getSchedulesByStatus(String status) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/schedules/stats/by-status',
        queryParameters: {'status': status},
      );
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => Schedule.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/schedules/batch/due?device_id=device1&limit=50
  Future<List<Schedule>> getBatchDueSchedules({required String deviceId, int limit = 50}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/schedules/batch/due',
        queryParameters: {'device_id': deviceId, 'limit': limit},
      );
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => Schedule.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST /api/v1/schedules/batch/execute
  Future<void> batchExecute(List<Map<String, dynamic>> executions) async {
    try {
      await _apiClient.dio.post(
        '/api/v1/schedules/batch/execute',
        data: {'schedules': executions},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}