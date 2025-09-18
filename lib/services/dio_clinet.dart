import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:my_food_my_price/services/secure_storage.dart';
import 'package:my_food_my_price/util/app_contant.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.read(AppConstants.token);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print("📡 [REQUEST] \${options.method} \${options.uri}");
            print("📦 Payload: \${options.data}");
            print("🧾 Headers: \${options.headers}");
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print("✅ [RESPONSE] \${response.statusCode} => \${response.data}");
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          if (kDebugMode) {
            print("❌ [ERROR] \${error.response?.statusCode} => \${error.message}");
          }
          return handler.next(error);
        },
      ),
    );

  static Dio get instance => _dio;
}
