import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../data/local_asignatura_repository.dart';
import '../data/asignatura_repository.dart';
import '../domain/asignatura.dart';

/// Provee la implementación del repositorio.
///
/// Ahora usa la base de datos local (IndexedDB/SharedPreferences) [LocalAsignaturaRepository].
final asignaturaRepositoryProvider = Provider<AsignaturaRepository>((ref) {
  return LocalAsignaturaRepository(ref.watch(localDbProvider));
});

/// Id del usuario autenticado (o `null` sin sesión).
///
/// Los providers de datos lo observan para **atar su caché a la identidad**:
/// al cambiar de cuenta (o cerrar sesión) sin reiniciar la app, la lista y el
/// detalle se recargan en vez de mostrar los ramos del usuario anterior.
final _usuarioActualIdProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).value?.id;
});

/// Lista de asignaturas (asíncrona: soporta carga desde BD/API).
final asignaturasProvider = FutureProvider<List<Asignatura>>((ref) async {
  ref.watch(_usuarioActualIdProvider); // recarga al cambiar de cuenta
  final repo = ref.watch(asignaturaRepositoryProvider);
  return repo.getAsignaturas();
});

/// Una asignatura por id.
final asignaturaProvider =
    FutureProvider.family<Asignatura?, String>((ref, id) async {
  ref.watch(_usuarioActualIdProvider); // recarga al cambiar de cuenta
  final repo = ref.watch(asignaturaRepositoryProvider);
  return repo.getAsignatura(id);
});
