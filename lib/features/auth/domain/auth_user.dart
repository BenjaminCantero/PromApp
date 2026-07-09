import 'package:flutter/foundation.dart';

/// Usuario autenticado, tal como lo devuelve la API (sin password).
///
/// Corresponde al `SafeUser` del backend: register / login / me devuelven
/// este objeto dentro del campo `user`.
@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.nombre,
    this.carrera,
    this.universidad,
  });

  final String id;
  final String email;
  final String nombre;
  final String? carrera;
  final String? universidad;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        email: json['email'] as String,
        nombre: json['nombre'] as String,
        carrera: json['carrera'] as String?,
        universidad: json['universidad'] as String?,
      );
}
