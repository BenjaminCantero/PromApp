import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/token_storage.dart';
import 'api_config.dart';

/// Cliente HTTP central (Dio) con la URL base y el interceptor de auth.
///
/// El interceptor adjunta automáticamente el header
/// `Authorization: Bearer <token>` en cada petición si hay sesión activa,
/// leyendo el token desde [TokenStorage]. Así ni los repositorios ni las
/// pantallas tienen que preocuparse por el token.
final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(tokenStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.timeout,
      receiveTimeout: ApiConfig.timeout,
      contentType: 'application/json',
      // No lanzamos excepción por 4xx para poder mapear mensajes propios.
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );

  return dio;
});
