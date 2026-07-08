import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/asignatura_repository.dart';
import '../data/mock_asignatura_repository.dart';
import '../domain/asignatura.dart';

/// Provee la implementación del repositorio.
///
/// 👉 Único punto a cambiar cuando pasemos a sqflite / API:
/// reemplazar `MockAsignaturaRepository()` por la nueva implementación.
final asignaturaRepositoryProvider = Provider<AsignaturaRepository>((ref) {
  return MockAsignaturaRepository();
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
