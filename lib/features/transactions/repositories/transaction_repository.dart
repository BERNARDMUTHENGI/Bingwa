import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/transaction_request.dart';

class TransactionRepository {
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

  // POST /api/v1/transactions/requests
  Future<TransactionRequest> createRequest(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/api/v1/transactions/requests', data: data);
      final result = _extractData(response.data); // this is the 'data' object
      // The actual request is nested under 'offer_request'
      if (result is Map && result.containsKey('offer_request')) {
        return TransactionRequest.fromJson(result['offer_request']);
      }
      // Fallback: assume result is the request itself
      return TransactionRequest.fromJson(result);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/transactions/requests?page=1&page_size=20
  Future<List<TransactionRequest>> getRequests({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/transactions/requests',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => TransactionRequest.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/transactions/requests/:id
  Future<TransactionRequest> getRequestById(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/transactions/requests/$id');
      final data = _extractData(response.data);
      // Similar nesting may apply; if data has 'offer_request', extract it
      if (data is Map && data.containsKey('offer_request')) {
        return TransactionRequest.fromJson(data['offer_request']);
      }
      return TransactionRequest.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/transactions/requests/pending?limit=10
  Future<List<TransactionRequest>> getPendingRequests({int? limit}) async {
    try {
      final query = limit != null ? {'limit': limit} : null;
      final response = await _apiClient.dio.get(
        '/api/v1/transactions/requests/pending',
        queryParameters: query,
      );
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => TransactionRequest.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/transactions/requests/failed
  Future<List<TransactionRequest>> getFailedRequests() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/transactions/requests/failed');
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => TransactionRequest.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/transactions/requests/processing
  Future<List<TransactionRequest>> getProcessingRequests() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/transactions/requests/processing');
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => TransactionRequest.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/transactions/requests/by-status?status=pending
  Future<List<TransactionRequest>> getRequestsByStatus(String status) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/transactions/requests/by-status',
        queryParameters: {'status': status},
      );
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => TransactionRequest.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/transactions/requests/:id/status
  Future<void> updateRequestStatus(int id, String status) async {
    try {
      await _apiClient.dio.put('/api/v1/transactions/requests/$id/status', data: {'status': status});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/transactions/requests/:id/complete
  Future<void> completeRequest(int id, {
    required String ussdResponse,
    required String ussdSessionId,
    required int ussdProcessingTime,
    required String status, // "success" or "failed"
  }) async {
    try {
      await _apiClient.dio.put(
        '/api/v1/transactions/requests/$id/complete',
        data: {
          'ussd_response': ussdResponse,
          'ussd_session_id': ussdSessionId,
          'ussd_processing_time': ussdProcessingTime,
          'status': status,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/transactions/requests/:id/processing
  Future<void> markAsProcessing(int id) async {
    try {
      await _apiClient.dio.put('/api/v1/transactions/requests/$id/processing');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST /api/v1/transactions/requests/:id/retry
  Future<void> retryRequest(int id) async {
    try {
      await _apiClient.dio.post('/api/v1/transactions/requests/$id/retry');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/transactions/requests/batch/pending?device_id=device1&limit=50
  Future<List<TransactionRequest>> getBatchPendingRequests({required String deviceId, int limit = 50}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/transactions/requests/batch/pending',
        queryParameters: {'device_id': deviceId, 'limit': limit},
      );
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => TransactionRequest.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/transactions/requests/batch/update
  Future<void> batchUpdate(List<Map<String, dynamic>> updates) async {
    try {
      await _apiClient.dio.put('/api/v1/transactions/requests/batch/update', data: {'requests': updates});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/transactions/stats
  Future<Map<String, dynamic>> getTransactionStats() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/transactions/stats');
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/transactions/redemptions?page=1&page_size=20&offer_request_id=1
  Future<List<dynamic>> getRedemptions({int page = 1, int pageSize = 20, int? offerRequestId}) async {
    try {
      final query = {
        'page': page,
        'page_size': pageSize,
        if (offerRequestId != null) 'offer_request_id': offerRequestId,
      };
      final response = await _apiClient.dio.get('/api/v1/transactions/redemptions', queryParameters: query);
      final data = _extractData(response.data);
      if (data is List) return data;
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/transactions/redemptions/:id
  Future<Map<String, dynamic>> getRedemptionById(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/transactions/redemptions/$id');
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}