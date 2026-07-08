import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import 'evaluacion.dart';

/// Una asignatura (ramo) con sus evaluaciones y su configuración de examen.
///
/// La configuración de examen es **por ramo** (no global): el estudiante
/// decide si el ramo tiene examen, cómo se pondera y con qué nota se exime.
@immutable
class Asignatura {
  const Asignatura({
    required this.id,
    required this.nombre,
    this.codigo,
    this.semestre,
    this.evaluaciones = const [],
    this.tieneExamen = false,
    this.pesoPresentacion = AppConstants.defaultPesoPresentacion,
    this.pesoExamen = AppConstants.defaultPesoExamen,
    this.notaExamen,
    this.notaEximir,
  });

  final String id;
  final String nombre;
  final String? codigo;
  final String? semestre;
  final List<Evaluacion> evaluaciones;

  // --- Configuración de examen (por ramo) ---

  /// Si el ramo contempla examen final.
  final bool tieneExamen;

  /// Peso de la presentación en el promedio final (0.0–1.0). Ej: 0.6 = 60%.
  final double pesoPresentacion;

  /// Peso del examen en el promedio final (0.0–1.0). Ej: 0.4 = 40%.
  final double pesoExamen;

  /// Nota obtenida en el examen (1.0–7.0) o `null` si aún no se rinde.
  final double? notaExamen;

  /// Nota de presentación con la que el estudiante se exime del examen.
  /// `null` = el ramo no permite eximición.
  final double? notaEximir;

  Asignatura copyWith({
    String? id,
    String? nombre,
    String? codigo,
    String? semestre,
    List<Evaluacion>? evaluaciones,
    bool? tieneExamen,
    double? pesoPresentacion,
    double? pesoExamen,
    double? notaExamen,
    bool clearNotaExamen = false,
    double? notaEximir,
    bool clearNotaEximir = false,
  }) {
    return Asignatura(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      semestre: semestre ?? this.semestre,
      evaluaciones: evaluaciones ?? this.evaluaciones,
      tieneExamen: tieneExamen ?? this.tieneExamen,
      pesoPresentacion: pesoPresentacion ?? this.pesoPresentacion,
      pesoExamen: pesoExamen ?? this.pesoExamen,
      notaExamen: clearNotaExamen ? null : (notaExamen ?? this.notaExamen),
      notaEximir: clearNotaEximir ? null : (notaEximir ?? this.notaEximir),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'codigo': codigo,
        'semestre': semestre,
        'tieneExamen': tieneExamen ? 1 : 0,
        'pesoPresentacion': pesoPresentacion,
        'pesoExamen': pesoExamen,
        'notaExamen': notaExamen,
        'notaEximir': notaEximir,
      };

  factory Asignatura.fromMap(
    Map<String, dynamic> map, {
    List<Evaluacion> evaluaciones = const [],
  }) {
    return Asignatura(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      codigo: map['codigo'] as String?,
      semestre: map['semestre'] as String?,
      evaluaciones: evaluaciones,
      tieneExamen: (map['tieneExamen'] as int? ?? 0) == 1,
      pesoPresentacion: (map['pesoPresentacion'] as num?)?.toDouble() ??
          AppConstants.defaultPesoPresentacion,
      pesoExamen: (map['pesoExamen'] as num?)?.toDouble() ??
          AppConstants.defaultPesoExamen,
      notaExamen: (map['notaExamen'] as num?)?.toDouble(),
      notaEximir: (map['notaEximir'] as num?)?.toDouble(),
    );
  }
}
