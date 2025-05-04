import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      followRedirects: true,
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ),
  );

  // API Key for Spoonacular
  static const String apiKey = '75fdfd1a86a74dda81f72b3e4f117fb9';

  static Dio get dio {
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    return _dio;
  }
}
