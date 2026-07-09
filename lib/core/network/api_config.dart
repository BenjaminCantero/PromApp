import 'package:flutter/foundation.dart';

/// Configuración de la conexión con la API de PromApp (backend NestJS).
///
/// La URL base cambia según dónde corra la app:
/// - **Web / Desktop** → `localhost` (el backend corre en la misma máquina).
/// - **Emulador Android** → `10.0.2.2` (alias del `localhost` del host).
///
/// En producción (FASE 4) se reemplaza por la URL del servidor desplegado.
class ApiConfig {
  ApiConfig._();

  /// Puerto del backend (ver `backend/.env` → PORT=3000).
  static const int _port = 3000;

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:$_port';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$_port';
    }
    return 'http://localhost:$_port';
  }

  static const Duration timeout = Duration(seconds: 10);
}
