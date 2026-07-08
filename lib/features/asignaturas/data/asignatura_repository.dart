import '../domain/asignatura.dart';

/// Contrato del repositorio de asignaturas.
///
/// La UI y los providers dependen de esta abstracción, no de la
/// implementación. Para pasar a `sqflite` (FASE 1) o a la API (FASE 3)
/// basta con crear otra clase que implemente esta interfaz — sin tocar
/// providers ni pantallas.
///
/// Los métodos son `Future` desde ya para que el cambio a persistencia
/// asíncrona no rompa la firma.
abstract class AsignaturaRepository {
  Future<List<Asignatura>> getAsignaturas();

  Future<Asignatura?> getAsignatura(String id);

  /// Crea o actualiza (upsert) una asignatura.
  Future<void> saveAsignatura(Asignatura asignatura);

  Future<void> deleteAsignatura(String id);
}
