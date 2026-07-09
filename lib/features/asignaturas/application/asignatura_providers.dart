import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../data/api_asignatura_repository.dart';
import '../data/asignatura_repository.dart';
import '../domain/asignatura.dart';

/// Provee la implementación del repositorio.
///
/// 👉 FASE 3: ahora usa la API real ([ApiAsignaturaRepository]).
/// Para volver al mock en memoria (desarrollo sin backend) basta con:
///   `return MockAsignaturaRepository();`
/// (importando `../data/mock_asignatura_repository.dart`).
final asignaturaRepositoryProvider = Provider<AsignaturaRepository>((ref) {
  return ApiAsignaturaRepository(ref.watch(dioProvider));
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
