import 'package:dio/dio.dart';

/// Traduce cualquier error a un mensaje legible para el usuario.
///
/// - `DioException` (red) → mensaje según el tipo de fallo.
/// - Excepciones propias (`ApiException`, `AuthException`) → su `toString()`
///   ya es el mensaje limpio.
/// - Cualquier otra cosa → mensaje genérico (nunca se muestra un stack trace).
String mensajeDeError(Object? error) {
  if (error == null) return 'Ocurrió un error inesperado.';
  if (error is DioException) return mensajeDeRed(error);

  final texto = error.toString();
  if (texto.isNotEmpty && texto.length <= 140) return texto;
  return 'Ocurrió un error inesperado.';
}

/// Mensaje para fallos de red/conexión.
String mensajeDeRed(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return 'El servidor tardó demasiado en responder';
    case DioExceptionType.connectionError:
    case DioExceptionType.unknown:
      return 'No se pudo conectar con el servidor. ¿Está encendida la API?';
    default:
      return 'Error de conexión';
  }
}
