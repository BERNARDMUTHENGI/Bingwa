import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/ussd_code.dart';

class UssdCodeRepository {
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

  // GET /api/v1/offers/:id/ussd-codes
  Future<List<UssdCode>> getUssdCodes(int offerId) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/offers/$offerId/ussd-codes');
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => UssdCode.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/offers/:id/ussd-codes/active
  Future<List<UssdCode>> getActiveUssdCodes(int offerId) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/offers/$offerId/ussd-codes/active');
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => UssdCode.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/offers/:id/ussd-codes/primary
  Future<UssdCode> getPrimaryUssdCode(int offerId) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/offers/$offerId/ussd-codes/primary');
      final data = _extractData(response.data);
      return UssdCode.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/offers/:id/ussd-codes/stats
  Future<Map<String, dynamic>> getUssdCodeStats(int offerId) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/offers/$offerId/ussd-codes/stats');
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST /api/v1/offers/:id/ussd-codes
  Future<UssdCode> createUssdCode(int offerId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/api/v1/offers/$offerId/ussd-codes', data: data);
      final result = _extractData(response.data);
      return UssdCode.fromJson(result);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/offers/:id/ussd-codes/:codeId
  Future<UssdCode> updateUssdCode(int offerId, int codeId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/api/v1/offers/$offerId/ussd-codes/$codeId', data: data);
      final result = _extractData(response.data);
      return UssdCode.fromJson(result);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/offers/:id/ussd-codes/:codeId/set-primary
  Future<void> setPrimaryUssdCode(int offerId, int codeId) async {
    try {
      await _apiClient.dio.put('/api/v1/offers/$offerId/ussd-codes/$codeId/set-primary');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/offers/:id/ussd-codes/reorder
  Future<void> reorderUssdCodes(int offerId, List<int> orderedIds) async {
    try {
      await _apiClient.dio.put('/api/v1/offers/$offerId/ussd-codes/reorder', data: {'order': orderedIds});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/offers/:id/ussd-codes/:codeId/toggle-status
  Future<void> toggleUssdCodeStatus(int offerId, int codeId, bool isActive) async {
    try {
      await _apiClient.dio.put('/api/v1/offers/$offerId/ussd-codes/$codeId/toggle-status', data: {'is_active': isActive});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE /api/v1/offers/:id/ussd-codes/:codeId
  Future<void> deleteUssdCode(int offerId, int codeId) async {
    try {
      await _apiClient.dio.delete('/api/v1/offers/$offerId/ussd-codes/$codeId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST /api/v1/offers/:id/ussd-codes/record-result
  Future<void> recordResult(int offerId, {required int ussdCodeId, required bool success, required String response}) async {
    try {
      await _apiClient.dio.post(
        '/api/v1/offers/$offerId/ussd-codes/record-result',
        data: {
          'ussd_code_id': ussdCodeId,
          'success': success,
          'response': response,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}