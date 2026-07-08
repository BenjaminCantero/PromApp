import '../../../core/constants/app_constants.dart';

/// Estado de una nota según la escala chilena (para color / etiqueta en UI).
enum EstadoNota {
  aprobado, // >= 4.0
  examen, // 3.5 – 3.9 (limítrofe / va a examen)
  reprobado; // < 3.5

  /// Clasifica una nota (1.0–7.0) en su estado.
  static EstadoNota clasificar(double nota) {
    if (nota >= AppConstants.notaAprobacion) return EstadoNota.aprobado;
    if (nota >= AppConstants.examenMin) return EstadoNota.examen;
    return EstadoNota.reprobado;
  }

  String get label => switch (this) {
        EstadoNota.aprobado => 'Aprobado',
        EstadoNota.examen => 'En examen',
        EstadoNota.reprobado => 'Reprobado',
      };
}
