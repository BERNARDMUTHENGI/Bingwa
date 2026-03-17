import 'package:dio/dio.dart';
import '../utils/token_storage.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['device'] = 'mobile-app';
    // Bypass ngrok interstitial page
    options.headers['ngrok-skip-browser-warning'] = 'true';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Optional: handle 401 – refresh token or logout
    handler.next(err);
  }
}