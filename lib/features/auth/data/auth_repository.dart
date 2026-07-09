import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/auth_user.dart';

/// Error de autenticación con mensaje listo para mostrar al usuario.
class AuthException implements Exception {
  const AuthException(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}

/// Habla con los endpoints `/auth/*` del backend y persiste el token.
///
/// - `register` / `login` → guardan el token y devuelven el usuario.
/// - `me`               → valida el token guardado y trae el perfil.
/// - `logout`           → borra el token local.
class AuthRepository {
  AuthRepository(this._dio, this._tokens);

  final Dio _dio;
  final TokenStorage _tokens;

  Future<AuthUser> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/auth/register', data: {
      'nombre': nombre,
      'email': email,
      'password': password,
    });
    return _procesarAuth(res);
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return _procesarAuth(res);
  }

  /// Devuelve el usuario si el token guardado sigue siendo válido; si no,
  /// lanza [AuthException] (el llamador lo trata como "sin sesión").
  Future<AuthUser> me() async {
    final res = await _dio.get('/auth/me');
    if (res.statusCode == 200 && res.data != null) {
      return AuthUser.fromJson(res.data as Map<String, dynamic>);
    }
    throw const AuthException('Sesión expirada');
  }

  Future<void> logout() => _tokens.clear();

  // --- Helpers ---

  /// Extrae `{accessToken, user}`, guarda el token y devuelve el usuario.
  Future<AuthUser> _procesarAuth(Response res) async {
    final data = res.data;
    final ok = res.statusCode == 200 || res.statusCode == 201;

    if (!ok || data is! Map<String, dynamic>) {
      throw AuthException(_mensajeError(data, res.statusCode));
    }

    final token = data['accessToken'] as String?;
    if (token == null) {
      throw const AuthException('Respuesta inválida del servidor');
    }
    await _tokens.save(token);
    return AuthUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// Traduce el cuerpo de error de NestJS a un mensaje legible.
  String _mensajeError(dynamic data, int? status) {
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String) return msg;
      if (msg is List && msg.isNotEmpty) return msg.first.toString();
    }
    return 'Error del servidor (${status ?? '?'})';
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(dioProvider),
    ref.watch(tokenStorageProvider),
  );
});
