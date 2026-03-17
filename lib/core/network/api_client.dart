import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_interceptors.dart';

class ApiClient {
  late Dio dio;

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: dotenv.env['BASE_URL']!,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(AuthInterceptor());
    dio.interceptors.add(LogInterceptor(responseBody: true)); // helpful for debugging
  }
}