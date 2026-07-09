import 'package:promapp/features/asignaturas/application/asignatura_providers.dart';
import 'package:promapp/features/asignaturas/data/mock_asignatura_repository.dart';
import 'package:promapp/features/auth/application/auth_controller.dart';
import 'package:promapp/features/auth/domain/auth_user.dart';

/// AuthController falso que arranca con sesión iniciada, sin tocar red ni
/// almacenamiento seguro (no disponibles en `flutter test`).
class _FakeAuthController extends AuthController {
  @override
  Future<AuthUser?> build() async => const AuthUser(
        id: 'test-user',
        email: 'test@promapp.cl',
        nombre: 'Test',
      );
}

/// Overrides para montar `PromApp` en pruebas:
/// - sesión ya iniciada (salta el login),
/// - repositorio en memoria (mock), no la API real.
final loggedInOverrides = [
  authControllerProvider.overrideWith(_FakeAuthController.new),
  asignaturaRepositoryProvider.overrideWith((ref) => MockAsignaturaRepository()),
];
