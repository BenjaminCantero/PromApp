import '../../../core/constants/app_constants.dart';
import '../../asignaturas/domain/evaluacion.dart';

/// Resultado de una validación: válido o con un mensaje de error legible.
class ValidacionResult {
  const ValidacionResult.ok()
      : esValido = true,
        error = null;
  const ValidacionResult.error(this.error) : esValido = false;

  final bool esValido;
  final String? error;
}

/// Validaciones de dominio de PromApp (escala chilena).
///
/// Funciones puras y estáticas → fáciles de testear y reutilizar en la UI
/// (ej: `validator` de un `TextFormField`).
class Validators {
  Validators._();

  /// Nota entre 1.0 y 7.0.
  static ValidacionResult nota(double? valor) {
    if (valor == null) return const ValidacionResult.error('Ingresa una nota');
    if (valor < AppConstants.notaMin || valor > AppConstants.notaMax) {
      return ValidacionResult.error(
        'La nota debe estar entre ${AppConstants.notaMin} y ${AppConstants.notaMax}',
      );
    }
    return const ValidacionResult.ok();
  }

  /// Porcentaje entre 0 y 100.
  static ValidacionResult porcentaje(double? valor) {
    if (valor == null) {
      return const ValidacionResult.error('Ingresa un porcentaje');
    }
    if (valor < AppConstants.pctMin || valor > AppConstants.pctMax) {
      return const ValidacionResult.error('El porcentaje debe estar entre 0 y 100');
    }
    return const ValidacionResult.ok();
  }

  /// La suma de porcentajes de las evaluaciones debe dar 100% (±0.1).
  static ValidacionResult sumaPorcentajes(List<Evaluacion> evaluaciones) {
    final suma = evaluaciones.fold<double>(0, (acc, e) => acc + e.porcentaje);
    final diff = (suma - AppConstants.pctTotal).abs();
    if (diff > AppConstants.pctTolerancia) {
      return ValidacionResult.error(
        'Los porcentajes suman ${suma.toStringAsFixed(1)}%, deben sumar 100%',
      );
    }
    return const ValidacionResult.ok();
  }

  /// Los pesos presentación + examen deben sumar 1.0 (100%).
  static ValidacionResult pesosExamen(double pesoPres, double pesoExam) {
    final suma = pesoPres + pesoExam;
    if ((suma - 1.0).abs() > 0.001) {
      return const ValidacionResult.error(
        'Los pesos de presentación y examen deben sumar 100%',
      );
    }
    if (pesoExam <= 0) {
      return const ValidacionResult.error('El peso del examen no puede ser 0');
    }
    return const ValidacionResult.ok();
  }
}
