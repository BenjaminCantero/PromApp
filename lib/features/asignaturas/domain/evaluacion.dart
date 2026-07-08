import 'package:flutter/foundation.dart';

/// Una evaluación dentro de una asignatura (ej: "Solemne 1", 35%).
///
/// Inmutable: para cambiar un valor se usa [copyWith].
/// La [nota] es opcional: `null` = aún no rendida / sin nota.
@immutable
class Evaluacion {
  const Evaluacion({
    required this.id,
    required this.nombre,
    required this.porcentaje,
    this.nota,
    this.tipo,
    this.fecha,
  });

  final String id;
  final String nombre;

  /// Peso de la evaluación dentro de la presentación (0–100).
  final double porcentaje;

  /// Nota obtenida (1.0–7.0) o `null` si no se ha rendido.
  final double? nota;

  /// Etiqueta opcional: "Solemne", "Control", "Tarea", "Examen"...
  final String? tipo;

  final DateTime? fecha;

  /// `true` si ya tiene nota registrada.
  bool get rendida => nota != null;

  Evaluacion copyWith({
    String? id,
    String? nombre,
    double? porcentaje,
    double? nota,
    bool clearNota = false,
    String? tipo,
    DateTime? fecha,
  }) {
    return Evaluacion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      porcentaje: porcentaje ?? this.porcentaje,
      nota: clearNota ? null : (nota ?? this.nota),
      tipo: tipo ?? this.tipo,
      fecha: fecha ?? this.fecha,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'porcentaje': porcentaje,
        'nota': nota,
        'tipo': tipo,
        'fecha': fecha?.toIso8601String(),
      };

  factory Evaluacion.fromMap(Map<String, dynamic> map) => Evaluacion(
        id: map['id'] as String,
        nombre: map['nombre'] as String,
        porcentaje: (map['porcentaje'] as num).toDouble(),
        nota: (map['nota'] as num?)?.toDouble(),
        tipo: map['tipo'] as String?,
        fecha: map['fecha'] == null
            ? null
            : DateTime.parse(map['fecha'] as String),
      );
}
