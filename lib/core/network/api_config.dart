import 'package:flutter/foundation.dart';

/// Configuración de la conexión con la API de PromApp (backend NestJS).
///
/// La URL base se resuelve así (en orden de prioridad):
/// 1. **`--dart-define=API_URL=...`** o **`--dart-define=PROMAPP_API_URL=...`**
///    → ganan siempre. Úsalo para apuntar al backend desplegado en Railway o a
///    una IP local.
/// 2. **Web / Desktop** → `http://localhost:3000` (backend en la misma máquina).
/// 3. **Emulador Android** → `http://10.0.2.2:3000` (alias del localhost del host).
///
/// ⚠️ En un teléfono real, `localhost`/`10.0.2.2` apuntan al propio teléfono,
/// no a tu PC: por eso hay que pasar la URL real con `API_URL`.
class ApiConfig {
  ApiConfig._();

  /// URL por defecto del backend desplegado en Railway.
  static const String _defaultBaseUrl =
      'https://promapp-production.up.railway.app';

  /// Override por compilación: `--dart-define=API_URL=https://...`.
  static const String _override = String.fromEnvironment('API_URL');

  /// Override alternativo por compilación: `--dart-define=PROMAPP_API_URL=https://...`.
  static const String _alternativeOverride = String.fromEnvironment(
    'PROMAPP_API_URL',
  );

  static String resolveBaseUrl({
    String? override,
    bool? isWeb,
    TargetPlatform? platform,
  }) {
    final effectiveOverride = override ?? _override;
    if (effectiveOverride.isNotEmpty) return effectiveOverride;

    final effectiveAlternativeOverride = override ?? _alternativeOverride;
    if (effectiveAlternativeOverride.isNotEmpty) {
      return effectiveAlternativeOverride;
    }

    return _defaultBaseUrl;
  }

  static String get baseUrl => resolveBaseUrl();

  static const Duration timeout = Duration(seconds: 10);
}
