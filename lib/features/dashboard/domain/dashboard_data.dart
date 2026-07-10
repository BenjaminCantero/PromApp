import '../../asignaturas/domain/asignatura.dart';
import '../../asignaturas/domain/evaluacion.dart';
import '../../calculos/domain/calculo_service.dart';

/// Una evaluación próxima (con nota pendiente y fecha futura), lista para
/// mostrarse en la sección "Próximas Evaluaciones" del dashboard.
class ProximaEvaluacion {
  const ProximaEvaluacion({required this.asignatura, required this.evaluacion});

  final Asignatura asignatura;
  final Evaluacion evaluacion;

  DateTime get fecha => evaluacion.fecha!;

  /// Días desde hoy hasta la evaluación (0 = hoy, 1 = mañana...).
  int get diasRestantes {
    final hoy = DateTime.now();
    final soloFecha = DateTime(fecha.year, fecha.month, fecha.day);
    final soloHoy = DateTime(hoy.year, hoy.month, hoy.day);
    return soloFecha.difference(soloHoy).inDays;
  }

  /// Etiqueta relativa ("Hoy", "Mañana", "En 3 días"...).
  String get etiquetaTiempo {
    final d = diasRestantes;
    if (d <= 0) return 'Hoy';
    if (d == 1) return 'Mañana';
    if (d <= 6) return 'En $d días';
    if (d <= 13) return 'En 1 semana';
    return 'En ${(d / 7).floor()} semanas';
  }
}

/// Rendimiento de un ramo para la barra "Rendimiento por Asignatura".
class RendimientoAsignatura {
  const RendimientoAsignatura({required this.nombre, required this.promedio});

  final String nombre;

  /// Promedio actual del ramo (1.0–7.0), o `null` si no hay notas.
  final double? promedio;

  /// Progreso 0.0–1.0 para la barra (promedio / 7.0).
  double get progreso => promedio == null ? 0 : (promedio! / 7.0).clamp(0, 1);

  double? get promedioOficial =>
      promedio == null ? null : CalculoService.promedioOficial(promedio!);

  bool get aprobado => promedioOficial != null && promedioOficial! >= 4.0;

  bool get enRiesgo => promedioOficial != null && promedioOficial! < 4.0;
}

/// Datos agregados que consume la pantalla Dashboard.
class DashboardData {
  const DashboardData({
    required this.promedioGeneral,
    required this.proximasEvaluaciones,
    required this.rendimientos,
  });

  /// Promedio general del semestre (1.0–7.0), o `null` si no hay notas.
  final double? promedioGeneral;

  final List<ProximaEvaluacion> proximasEvaluaciones;
  final List<RendimientoAsignatura> rendimientos;

  /// Progreso del donut de promedio (0.0–1.0).
  double get progresoGeneral =>
      promedioGeneral == null ? 0 : (promedioGeneral! / 7.0).clamp(0, 1);

  /// Etiqueta cualitativa del rendimiento.
  String get rendimientoLabel {
    final p = promedioGeneral;
    if (p == null) return 'Sin notas';
    final oficial = CalculoService.promedioOficial(p);
    if (oficial >= 6.0) return 'Rendimiento Alto';
    if (oficial >= 5.0) return 'Rendimiento Medio';
    if (oficial >= 4.0) return 'Rendimiento Suficiente';
    return 'Rendimiento Bajo';
  }
}
