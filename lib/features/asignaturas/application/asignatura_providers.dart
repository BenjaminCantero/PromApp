import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_db_provider.dart';
import '../data/asignatura_repository.dart';
import '../data/local_asignatura_repository.dart';
import '../domain/asignatura.dart';

/// Provee la implementación del repositorio.
///
/// Ahora usa la base de datos local (IndexedDB/SharedPreferences) [LocalAsignaturaRepository].
final asignaturaRepositoryProvider = Provider<AsignaturaRepository>((ref) {
  return LocalAsignaturaRepository(ref.watch(localDbProvider));
});



/// Lista de asignaturas (asíncrona: soporta carga desde BD/API).
final asignaturasProvider = FutureProvider<List<Asignatura>>((ref) async {
  final repo = ref.watch(asignaturaRepositoryProvider);
  return repo.getAsignaturas();
});

/// Una asignatura por id.
final asignaturaProvider =
    FutureProvider.family<Asignatura?, String>((ref, id) async {
  final repo = ref.watch(asignaturaRepositoryProvider);
  return repo.getAsignatura(id);
});
