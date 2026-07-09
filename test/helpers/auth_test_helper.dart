import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Overrides para montar `PromApp` con un usuario ya autenticado, de modo
/// que las pruebas de UI lleguen directo a la app (dashboard/tabs).
final loggedInOverrides = [
  authControllerProvider.overrideWith(_FakeAuthController.new),
];
