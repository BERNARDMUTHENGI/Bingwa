import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/config.dart';

class ConfigRepository {
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

  // GET /api/v1/configs?page=1&page_size=20
  Future<List<Config>> getConfigs({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/configs',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => Config.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/configs/all
  Future<List<Config>> getAllConfigs() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/configs/all');
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => Config.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/configs/global
  Future<List<Config>> getGlobalConfigs() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/configs/global');
      final data = _extractData(response.data);
      if (data is List) {
        return data.map((json) => Config.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/configs/:id
  Future<Config> getConfigById(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/configs/$id');
      final data = _extractData(response.data);
      return Config.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/configs/key/:key?device_id=device1
  Future<Config?> getConfigByKey(String key, {String? deviceId}) async {
    try {
      final query = deviceId != null ? {'device_id': deviceId} : null;
      final response = await _apiClient.dio.get(
        '/api/v1/configs/key/$key',
        queryParameters: query,
      );
      final data = _extractData(response.data);
      return data != null ? Config.fromJson(data) : null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null; // not found
      throw _handleError(e);
    }
  }

  // POST /api/v1/configs (create config)
  Future<Config> createConfig(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/api/v1/configs', data: data);
      final result = _extractData(response.data);
      return Config.fromJson(result);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/configs/:id
  Future<Config> updateConfig(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/api/v1/configs/$id', data: data);
      final result = _extractData(response.data);
      return Config.fromJson(result);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE /api/v1/configs/:id
  Future<void> deleteConfig(int id) async {
    try {
      await _apiClient.dio.delete('/api/v1/configs/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/configs/devices/:device_id
  Future<Map<String, dynamic>> getDeviceSettings(String deviceId) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/configs/devices/$deviceId');
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/configs/types/notifications
  Future<Map<String, dynamic>> getNotificationConfig() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/configs/types/notifications');
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/configs/types/notifications
  Future<Map<String, dynamic>> setNotificationConfig(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/api/v1/configs/types/notifications', data: data);
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/configs/types/ussd
  Future<Map<String, dynamic>> getUssdConfig() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/configs/types/ussd');
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/configs/types/ussd
  Future<Map<String, dynamic>> setUssdConfig(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/api/v1/configs/types/ussd', data: data);
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/configs/types/android/:device_id
  Future<Map<String, dynamic>> getAndroidDeviceConfig(String deviceId) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/configs/types/android/$deviceId');
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/configs/types/android/:device_id
  Future<Map<String, dynamic>> setAndroidDeviceConfig(String deviceId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/api/v1/configs/types/android/$deviceId', data: data);
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/configs/types/business
  Future<Map<String, dynamic>> getBusinessConfig() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/configs/types/business');
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/configs/types/business
  Future<Map<String, dynamic>> setBusinessConfig(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/api/v1/configs/types/business', data: data);
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/configs/types/display
  Future<Map<String, dynamic>> getDisplayConfig() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/configs/types/display');
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/configs/types/display
  Future<Map<String, dynamic>> setDisplayConfig(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/api/v1/configs/types/display', data: data);
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/v1/configs/types/security
  Future<Map<String, dynamic>> getSecurityConfig() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/configs/types/security');
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT /api/v1/configs/types/security
  Future<Map<String, dynamic>> setSecurityConfig(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/api/v1/configs/types/security', data: data);
      return _extractData(response.data) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}