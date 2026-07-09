import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promapp/features/asignaturas/application/asignatura_providers.dart';
import 'package:promapp/features/asignaturas/data/mock_asignatura_repository.dart';
import 'package:promapp/features/auth/application/auth_controller.dart';
import 'package:promapp/features/auth/domain/auth_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simula SharedPreferences con el onboarding ya visto.
///
/// Sin esto, `_AuthGate` (app.dart) se queda esperando `onboardingDone()`
/// para siempre: el canal de plataforma no existe en `flutter test`.
void mockOnboardingVisto() {
  SharedPreferences.setMockInitialValues({'onboarding_done': true});
}

/// AuthController falso que arranca con sesión iniciada, sin tocar red ni
/// almacenamiento seguro (no disponibles en `flutter test`).
class _FakeAuthController extends AuthController {
  @override
  Future<AuthUser?> build() async => const AuthUser(
        id: 'test-user',
        email: 'test@promapp.cl',
        nombre: 'Test',
      );

  // Evita tocar red / almacenamiento seguro en pruebas.
  @override
  Future<void> logout() async => state = const AsyncData(null);
}

/// Sesión ya iniciada: salta el login sin tocar red.
final sesionIniciadaOverride =
    authControllerProvider.overrideWith(_FakeAuthController.new);

/// Repositorio en memoria (mock) en vez de la API real.
final mockRepoOverride =
    asignaturaRepositoryProvider.overrideWith((ref) => MockAsignaturaRepository());

/// Overrides habituales para montar `PromApp` en pruebas de UI.
///
/// Si un test necesita otro repositorio (p. ej. uno que falla), usa
/// `[sesionIniciadaOverride, tuRepoOverride]` en vez de esta lista.
final loggedInOverrides = [sesionIniciadaOverride, mockRepoOverride];
