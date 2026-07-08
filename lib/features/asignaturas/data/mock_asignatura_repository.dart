import '../domain/asignatura.dart';
import '../domain/evaluacion.dart';
import 'asignatura_repository.dart';

/// Implementación en memoria del [AsignaturaRepository].
///
/// Mantiene los datos en una `List` mientras la app está viva (se pierden
/// al cerrar). Sirve para desarrollar la UI de FASE 1 sin persistencia.
/// Reemplazable por `SqfliteAsignaturaRepository` o `ApiAsignaturaRepository`
/// sin cambiar nada del resto de la app.
class MockAsignaturaRepository implements AsignaturaRepository {
  MockAsignaturaRepository() {
    _asignaturas.addAll(_seed());
  }

  final List<Asignatura> _asignaturas = [];

  // Latencia simulada para que la UI muestre estados de carga realistas.
  static const _delay = Duration(milliseconds: 300);

  @override
  Future<List<Asignatura>> getAsignaturas() async {
    await Future.delayed(_delay);
    return List.unmodifiable(_asignaturas);
  }

  @override
  Future<Asignatura?> getAsignatura(String id) async {
    await Future.delayed(_delay);
    for (final a in _asignaturas) {
      if (a.id == id) return a;
    }
    return null;
  }

  @override
  Future<void> saveAsignatura(Asignatura asignatura) async {
    await Future.delayed(_delay);
    final index = _asignaturas.indexWhere((a) => a.id == asignatura.id);
    if (index >= 0) {
      _asignaturas[index] = asignatura;
    } else {
      _asignaturas.add(asignatura);
    }
  }

  @override
  Future<void> deleteAsignatura(String id) async {
    await Future.delayed(_delay);
    _asignaturas.removeWhere((a) => a.id == id);
  }

  // --- Datos de ejemplo (mock) ---
  static List<Asignatura> _seed() {
    final ahora = DateTime.now();
    DateTime enDias(int d) => ahora.add(Duration(days: d));

    return [
      Asignatura(
        id: '1',
        nombre: 'Programación Avanzada',
        codigo: 'INF-301',
        semestre: '2024 - Semestre 1',
        evaluaciones: [
          Evaluacion(id: '1a', nombre: 'Solemne 1', porcentaje: 30, nota: 6.4, tipo: 'Solemne'),
          Evaluacion(id: '1b', nombre: 'Proyecto', porcentaje: 40, nota: 6.8, tipo: 'Proyecto'),
          Evaluacion(id: '1c', nombre: 'Talleres', porcentaje: 30, nota: 6.2, tipo: 'Taller'),
        ],
      ),
      Asignatura(
        id: '2',
        nombre: 'Cálculo Diferencial',
        codigo: 'MAT-301',
        semestre: '2024 - Semestre 1',
        tieneExamen: true,
        pesoPresentacion: 0.6,
        pesoExamen: 0.4,
        notaEximir: 5.5,
        evaluaciones: [
          Evaluacion(id: '2a', nombre: 'Certamen 1', porcentaje: 35, nota: 5.2, tipo: 'Solemne'),
          Evaluacion(id: '2b', nombre: 'Certamen 2', porcentaje: 35, tipo: 'Solemne', fecha: enDias(1)),
          Evaluacion(id: '2c', nombre: 'Tareas', porcentaje: 30, nota: 5.0, tipo: 'Tarea'),
        ],
      ),
      Asignatura(
        id: '3',
        nombre: 'Física Mecánica',
        codigo: 'FIS-201',
        semestre: '2024 - Semestre 1',
        evaluaciones: [
          Evaluacion(id: '3a', nombre: 'Prueba 1', porcentaje: 40, nota: 4.5, tipo: 'Prueba'),
          Evaluacion(id: '3b', nombre: 'Laboratorio 4', porcentaje: 30, tipo: 'Laboratorio', fecha: enDias(3)),
          Evaluacion(id: '3c', nombre: 'Prueba 2', porcentaje: 30, tipo: 'Prueba', fecha: enDias(10)),
        ],
      ),
      Asignatura(
        id: '4',
        nombre: 'Ética Profesional',
        codigo: 'HUM-101',
        semestre: '2024 - Semestre 1',
        evaluaciones: [
          Evaluacion(id: '4a', nombre: 'Ensayo 1', porcentaje: 50, nota: 6.0, tipo: 'Ensayo'),
          Evaluacion(id: '4b', nombre: 'Ensayo Final', porcentaje: 50, tipo: 'Ensayo', fecha: enDias(7)),
        ],
      ),
    ];
  }
}
