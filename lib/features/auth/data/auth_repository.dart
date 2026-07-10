import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/storage/local_db.dart';

import '../../../core/storage/local_db_interface.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/auth_user.dart';

/// Error de autenticación con mensaje listo para mostrar al usuario.
class AuthException implements Exception {
  const AuthException(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}

/// Implementación local de [AuthRepository] que utiliza [LocalDb] (IndexedDB/SharedPreferences)
/// en lugar de hacer peticiones HTTP al backend NestJS.
/// 
/// Reemplaza las llamadas remotas por operaciones locales rápidas.
class AuthRepository {
  AuthRepository(this._db, this._tokens);

  final LocalDb _db;
  final TokenStorage _tokens;

  /// Clave del Object Store para usuarios en la base de datos local.
  static const _storeName = 'usuarios';

  Future<void> _asegurarDb() async {
    await _db.init();
  }

  Future<AuthUser> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    await _asegurarDb();

    // Validar si ya existe una cuenta local con ese correo
    final usuarios = await _db.getAll(_storeName);
    final existe = usuarios.any(
      (u) => (u['email'] as String).toLowerCase() == email.trim().toLowerCase(),
    );

    if (existe) {
      throw const AuthException('Ya existe una cuenta con ese correo');
    }

    final id = const Uuid().v4();
    final nuevoUsuario = {
      'id': id,
      'email': email.trim(),
      'nombre': nombre.trim(),
      'password': password, // Contraseña local para simulación
      'carrera': '',
      'universidad': '',
      'createdAt': DateTime.now().toIso8601String(),
    };

    await _db.save(_storeName, id, nuevoUsuario);
    await _tokens.save(id); // Guardamos el ID del usuario activo como token

    return AuthUser.fromJson(nuevoUsuario);
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    await _asegurarDb();

    final usuarios = await _db.getAll(_storeName);
    final usuario = usuarios.firstWhere(
      (u) => (u['email'] as String).toLowerCase() == email.trim().toLowerCase(),
      orElse: () => throw const AuthException('Correo o contraseña incorrectos'),
    );

    if (usuario['password'] != password) {
      throw const AuthException('Correo o contraseña incorrectos');
    }

    final id = usuario['id'] as String;
    await _tokens.save(id);

    return AuthUser.fromJson(usuario);
  }

  /// Devuelve el usuario activo local si el token (ID de usuario) está guardado.
  Future<AuthUser> me() async {
    await _asegurarDb();
    final activeId = await _tokens.read();
    if (activeId == null || activeId.isEmpty) {
      throw const AuthException('Sin sesión local activa');
    }

    final datos = await _db.get(_storeName, activeId);
    if (datos != null) {
      return AuthUser.fromJson(datos);
    }

    await _tokens.clear();
    throw const AuthException('Usuario local no encontrado');
  }

  Future<void> logout() async {
    await _tokens.clear();
  }

  Future<void> cambiarPassword({
    required String passwordActual,
    required String passwordNueva,
  }) async {
    await _asegurarDb();
    final activeId = await _tokens.read();
    if (activeId == null || activeId.isEmpty) {
      throw const AuthException('No hay sesión activa');
    }

    final datos = await _db.get(_storeName, activeId);
    if (datos == null) {
      throw const AuthException('Usuario no encontrado');
    }

    if (datos['password'] != passwordActual) {
      throw const AuthException('La contraseña actual es incorrecta');
    }

    final clone = Map<String, dynamic>.from(datos);
    clone['password'] = passwordNueva;
    await _db.save(_storeName, activeId, clone);
  }
}

final localDbProvider = Provider<LocalDb>((ref) => LocalDbImpl());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(localDbProvider),
    ref.watch(tokenStorageProvider),
  );
});

