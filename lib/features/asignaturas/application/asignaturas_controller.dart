import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/asignatura_repository.dart';
import '../domain/asignatura.dart';
import 'asignatura_providers.dart';

/// Controla las mutaciones de asignaturas (crear/editar/eliminar/notas).
///
/// Tras cada cambio invalida los providers de lectura para que la UI
/// (dashboard, lista, detalle) se refresque automáticamente.
class AsignaturasController extends Notifier<void> {
  @override
  void build() {}

  AsignaturaRepository get _repo => ref.read(asignaturaRepositoryProvider);

  void _refrescar(String id) {
    ref.invalidate(asignaturasProvider);
    ref.invalidate(asignaturaProvider(id));
  }

  /// Crea o actualiza una asignatura.
  Future<void> guardar(Asignatura asignatura) async {
    await _repo.saveAsignatura(asignatura);
    _refrescar(asignatura.id);
  }

  Future<void> eliminar(String id) async {
    await _repo.deleteAsignatura(id);
    ref.invalidate(asignaturasProvider);
  }

  /// Registra (o borra) la nota de una evaluación puntual.
  Future<void> setNotaEvaluacion(
    Asignatura asignatura,
    String evaluacionId,
    double? nota,
  ) async {
    final evaluaciones = asignatura.evaluaciones.map((e) {
      if (e.id != evaluacionId) return e;
      return e.copyWith(nota: nota, clearNota: nota == null);
    }).toList();
    await guardar(asignatura.copyWith(evaluaciones: evaluaciones));
  }

  /// Registra la nota del examen final.
  Future<void> setNotaExamen(Asignatura asignatura, double? nota) async {
    await guardar(
      asignatura.copyWith(notaExamen: nota, clearNotaExamen: nota == null),
    );
  }
}

final asignaturasControllerProvider =
    NotifierProvider<AsignaturasController, void>(AsignaturasController.new);
