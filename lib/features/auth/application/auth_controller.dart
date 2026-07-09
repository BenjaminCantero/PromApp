import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/error_messages.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_repository.dart';
import '../domain/auth_user.dart';

/// Estado de la sesión: `AsyncValue<AuthUser?>`.
///
/// - `loading`        → arrancando, validando el token guardado.
/// - `data(null)`     → sin sesión (mostrar login).
/// - `data(AuthUser)` → sesión activa (mostrar la app).
///
/// `login` / `register` **no** ponen el estado en error si fallan: relanzan
/// una [AuthException] para que la pantalla la muestre inline, dejando la
/// sesión intacta (sigue en `data(null)`).
class AuthController extends AsyncNotifier<AuthUser?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<AuthUser?> build() async {
    final token = await ref.read(tokenStorageProvider).read();
    if (token == null || token.isEmpty) return null;
    try {
      return await _repo.me();
    } catch (_) {
      // Token inválido/expirado → limpiar y arrancar sin sesión.
      await _repo.logout();
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    final user = await _run(
      () => _repo.login(email: email.trim(), password: password),
    );
    state = AsyncData(user);
  }

  Future<void> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final user = await _run(
      () => _repo.register(
        nombre: nombre.trim(),
        email: email.trim(),
        password: password,
      ),
    );
    state = AsyncData(user);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncData(null);
  }

  /// Ejecuta una acción de auth traduciendo errores de red a [AuthException].
  Future<AuthUser> _run(Future<AuthUser> Function() action) async {
    try {
      return await action();
    } on AuthException {
      rethrow;
    } on DioException catch (e) {
      throw AuthException(mensajeDeRed(e));
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthUser?>(AuthController.new);
