import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promapp/features/asignaturas/application/asignatura_providers.dart';
import 'package:promapp/features/asignaturas/data/asignatura_repository.dart';
import 'package:promapp/features/asignaturas/domain/asignatura.dart';
import 'package:promapp/features/auth/application/auth_controller.dart';
import 'package:promapp/features/auth/domain/auth_user.dart';

/// Repositorio con datos mutables: simula lo que devuelve la API para el
/// usuario cuyo token viaja en cada momento.
class _RepoMutable implements AsignaturaRepository {
  List<Asignatura> data = [];

  @override
  Future<List<Asignatura>> getAsignaturas() async => data;

  @override
  Future<Asignatura?> getAsignatura(String id) async =>
      data.where((a) => a.id == id).cast<Asignatura?>().firstWhere(
            (_) => true,
            orElse: () => null,
          );

  @override
  Future<void> saveAsignatura(Asignatura a) async {}

  @override
  Future<void> deleteAsignatura(String id) async {}
}

/// AuthController falso que permite cambiar de usuario en caliente.
class _FakeAuth extends AuthController {
  _FakeAuth(this._user);
  AuthUser? _user;

  @override
  Future<AuthUser?> build() async => _user;

  void cambiarA(AuthUser? u) {
    _user = u;
    state = AsyncData(u);
  }
}

AuthUser _user(String id) =>
    AuthUser(id: id, email: '$id@promapp.cl', nombre: 'Usuario $id');

Asignatura _ramo(String id, String nombre) =>
    Asignatura(id: id, nombre: nombre);

void main() {
  test(
      'Al cambiar de cuenta, la lista se recarga y NO muestra los ramos del '
      'usuario anterior', () async {
    final repo = _RepoMutable()..data = [_ramo('a1', 'Ramo de Ana')];

    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(() => _FakeAuth(_user('ana'))),
      asignaturaRepositoryProvider.overrideWith((ref) => repo),
    ]);
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);

    // Ana ve sus ramos.
    var lista = await container.read(asignaturasProvider.future);
    expect(lista.single.nombre, 'Ramo de Ana');

    // La API ahora respondería con los ramos de Bruno, pero mientras no
    // cambie la sesión la caché de Ana se mantiene (comportamiento esperado).
    repo.data = [_ramo('b1', 'Ramo de Bruno')];
    lista = await container.read(asignaturasProvider.future);
    expect(lista.single.nombre, 'Ramo de Ana');

    // Cambia la sesión a Bruno → la lista DEBE recargarse.
    (container.read(authControllerProvider.notifier) as _FakeAuth)
        .cambiarA(_user('bruno'));

    lista = await container.read(asignaturasProvider.future);
    expect(
      lista.single.nombre,
      'Ramo de Bruno',
      reason: 'Los ramos de Ana no deben filtrarse a la sesión de Bruno',
    );
  });
}
