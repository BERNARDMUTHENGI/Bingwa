import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/token_storage.dart';

class AdminApiClient {
  late Dio dio;

  AdminApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: dotenv.env['BASE_URL']!,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    ));

    dio.interceptors.add(AdminAuthInterceptor());
    dio.interceptors.add(LogInterceptor(responseBody: true));
  }
}

class AdminAuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenStorage.getAdminToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['device'] = 'mobile-app';
    handler.next(options);
  }
}