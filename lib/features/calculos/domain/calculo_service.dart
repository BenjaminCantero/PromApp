import '../../asignaturas/domain/asignatura.dart';
import '../../asignaturas/domain/evaluacion.dart';
import 'estado_nota.dart';

/// Fotografía calculada del estado de una asignatura.
class ResultadoAsignatura {
  const ResultadoAsignatura({
    required this.promedioPresentacion,
    required this.pesoEvaluado,
    required this.pesoPendiente,
    required this.eximido,
    required this.promedioFinal,
    required this.estado,
  });

  /// Promedio ponderado de lo ya rendido (`null` si no hay notas).
  final double? promedioPresentacion;

  /// % del ramo ya evaluado (0–100).
  final double pesoEvaluado;

  /// % del ramo aún por evaluar (0–100).
  final double pesoPendiente;

  /// `true` si la nota de presentación alcanza para eximirse del examen.
  final bool eximido;

  /// Promedio final proyectado (`null` si faltan datos, ej: examen sin rendir).
  final double? promedioFinal;

  /// Estado del promedio final (`null` si aún no se puede calcular).
  final EstadoNota? estado;
}

/// Servicio de cálculos de PromApp.
///
/// Todas las funciones son **puras y estáticas** (sin estado, sin efectos):
/// misma entrada → misma salida. Esto las hace triviales de testear.
class CalculoService {
  CalculoService._();

  /// Promedio simple: suma(notas) / cantidad.
  ///
  /// Devuelve `null` si la lista está vacía.
  static double? promedioSimple(List<double> notas) {
    if (notas.isEmpty) return null;
    final suma = notas.fold<double>(0, (acc, n) => acc + n);
    return suma / notas.length;
  }

  /// Promedio ponderado de las evaluaciones **ya rendidas**,
  /// normalizado sobre sus pesos: suma(nota·pct) / suma(pct).
  ///
  /// Representa "cómo voy hasta ahora". Devuelve `null` si no hay notas.
  static double? promedioPonderado(List<Evaluacion> evaluaciones) {
    final rendidas = evaluaciones.where((e) => e.rendida);
    final sumaPesos = rendidas.fold<double>(0, (acc, e) => acc + e.porcentaje);
    if (sumaPesos == 0) return null;
    final sumaPonderada =
        rendidas.fold<double>(0, (acc, e) => acc + e.nota! * e.porcentaje);
    return sumaPonderada / sumaPesos;
  }

  /// % del ramo ya evaluado (suma de porcentajes de evaluaciones rendidas).
  static double pesoEvaluado(List<Evaluacion> evaluaciones) {
    return evaluaciones
        .where((e) => e.rendida)
        .fold<double>(0, (acc, e) => acc + e.porcentaje);
  }

  /// Nota promedio necesaria en lo que falta para alcanzar [objetivo].
  ///
  /// Fórmula: (objetivo − contribuciónActual) / pesoPendiente
  /// donde contribuciónActual = suma(nota·pct)/100 de lo ya rendido.
  ///
  /// Devuelve `null` si no queda peso pendiente (nada por rendir).
  static double? notaNecesariaRestante({
    required double objetivo,
    required List<Evaluacion> evaluaciones,
  }) {
    final contribucionActual = evaluaciones
            .where((e) => e.rendida)
            .fold<double>(0, (acc, e) => acc + e.nota! * e.porcentaje) /
        100.0;
    final pesoPendiente = (100.0 - pesoEvaluado(evaluaciones)) / 100.0;
    if (pesoPendiente <= 0) return null; // no queda nada por evaluar
    return (objetivo - contribucionActual) / pesoPendiente;
  }

  /// Nota necesaria **en el examen** para alcanzar [objetivo] como nota final.
  ///
  /// Fórmula: (objetivo − presentación·pesoPres) / pesoExamen.
  static double notaNecesariaExamen({
    required double objetivo,
    required double presentacion,
    required double pesoPresentacion,
    required double pesoExamen,
  }) {
    return (objetivo - presentacion * pesoPresentacion) / pesoExamen;
  }

  /// Calcula el estado completo de una asignatura considerando su
  /// configuración de examen (por ramo).
  static ResultadoAsignatura calcularAsignatura(Asignatura a) {
    final presentacion = promedioPonderado(a.evaluaciones);
    final evaluado = pesoEvaluado(a.evaluaciones);
    final pendiente = 100.0 - evaluado;

    final eximido = a.notaEximir != null &&
        presentacion != null &&
        presentacion >= a.notaEximir!;

    double? finalProm;
    if (presentacion == null) {
      finalProm = null;
    } else if (!a.tieneExamen || eximido) {
      // Sin examen o eximido → la nota final es la presentación.
      finalProm = presentacion;
    } else if (a.notaExamen != null) {
      // Examen ya rendido → ponderación presentación/examen.
      finalProm = presentacion * a.pesoPresentacion +
          a.notaExamen! * a.pesoExamen;
    } else {
      // Tiene examen pero aún no se rinde → no se puede proyectar el final.
      finalProm = null;
    }

    return ResultadoAsignatura(
      promedioPresentacion: presentacion,
      pesoEvaluado: evaluado,
      pesoPendiente: pendiente,
      eximido: eximido,
      promedioFinal: finalProm,
      estado: finalProm == null ? null : EstadoNota.clasificar(finalProm),
    );
  }
}
