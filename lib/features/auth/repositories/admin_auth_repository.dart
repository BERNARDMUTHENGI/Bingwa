import 'package:dio/dio.dart';
import '../../../core/network/admin_api_client.dart';
import '../models/auth_response.dart';

class AdminAuthRepository {
  final AdminApiClient _apiClient = AdminApiClient();

  Future<AuthResponse> login({
    required String email,
    required String password,
    required String device,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/auth/login',
        data: {
          'email': email,
          'password': password,
          'device': device,
        },
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
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
}