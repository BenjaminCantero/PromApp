/// Reglas de negocio y constantes de la escala chilena.
///
/// Centralizadas para que las fórmulas (FASE 1 - cálculos) y las
/// validaciones usen los mismos límites.
class AppConstants {
  AppConstants._();

  static const String appName = 'PromApp';

  // --- Escala de notas (Chile) ---
  static const double notaMin = 1.0;
  static const double notaMax = 7.0;
  static const double notaAprobacion = 4.0;

  // Rango en que la asignatura "va a examen" (configurable por ramo,
  // este es el default típico).
  static const double examenMin = 3.5;
  static const double examenMax = 3.9;

  // --- Porcentajes / ponderaciones ---
  static const double pctMin = 0.0;
  static const double pctMax = 100.0;
  static const double pctTotal = 100.0;
  static const double pctTolerancia = 0.1; // suma debe dar 100% ±0.1

  // --- Config default de examen por asignatura ---
  static const double defaultPesoPresentacion = 0.6; // 60%
  static const double defaultPesoExamen = 0.4; // 40%
}
