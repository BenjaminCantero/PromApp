import 'package:flutter/foundation.dart';

/// Configuración de la conexión con la API de PromApp (backend NestJS).
///
/// La URL base se resuelve así (en orden de prioridad):
/// 1. **`--dart-define=API_URL=...`** → gana siempre. Úsalo en un
///    **teléfono físico**, apuntando a la IP de tu PC en la red local, p. ej.:
///    `flutter run --dart-define=API_URL=http://192.168.1.11:3000`
/// 2. **Web / Desktop** → `localhost` (backend en la misma máquina).
/// 3. **Emulador Android** → `10.0.2.2` (alias del `localhost` del host).
///
/// ⚠️ En un teléfono real, `localhost`/`10.0.2.2` apuntan al **propio
/// teléfono**, no a tu PC: por eso hay que pasar la IP con `API_URL`.
///
/// En producción (FASE 4) se pasa la URL del servidor desplegado (HTTPS).
class ApiConfig {
  ApiConfig._();

  /// Puerto del backend (ver `backend/.env` → PORT=3000).
  static const int _port = 3000;

  /// Override por compilación: `--dart-define=API_URL=http://host:puerto`.
  static const String _override = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (kIsWeb) return 'http://localhost:$_port';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$_port';
    }
    return 'http://localhost:$_port';
  }

  static const Duration timeout = Duration(seconds: 10);
}
