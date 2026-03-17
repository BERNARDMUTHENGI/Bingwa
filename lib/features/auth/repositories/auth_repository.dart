import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/auth_response.dart';
import '../models/user.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<AuthResponse> register({
    required String email,
    required String phone,
    required String password,
    required String fullName,
    required String device,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/auth/register',
        data: {
          'email': email,
          'phone': phone,
          'password': password,
          'full_name': fullName,
          'device': device,
        },
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

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

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/api/v1/auth/logout');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logoutAll() async {
    try {
      await _apiClient.dio.post('/api/v1/auth/logout-all');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.dio.post(
        '/api/v1/auth/forgot-password',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _apiClient.dio.post(
        '/api/v1/auth/reset-password',
        data: {
          'token': token,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> getCurrentUser() async {
  try {
    final response = await _apiClient.dio.get('/api/v1/auth/me');
    // Adjust parsing based on actual API response
    final userData = response.data['data']['user'] ?? response.data['data'];
    return User.fromJson(userData);
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

Future<void> verifyEmail(String token) async {
  try {
    await _apiClient.dio.get('/api/v1/auth/verify-email', queryParameters: {'token': token});
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

Future<void> resendVerification() async {
  try {
    await _apiClient.dio.post('/api/v1/auth/resend-verification');
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.dio.put(
        '/api/v1/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
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