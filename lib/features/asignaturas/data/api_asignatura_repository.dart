import 'package:dio/dio.dart';

import '../domain/asignatura.dart';
import '../domain/evaluacion.dart';
import 'asignatura_repository.dart';

/// Error de la API con mensaje listo para mostrar.
class ApiException implements Exception {
  const ApiException(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}

/// Implementación de [AsignaturaRepository] contra el backend NestJS.
///
/// Habla con `/asignaturas/*` usando el [Dio] configurado (que ya adjunta
/// el token). Cada usuario ve solo sus ramos (el backend filtra por dueño).
///
/// Reemplaza a `MockAsignaturaRepository` sin que cambien providers ni
/// pantallas: implementa el mismo contrato.
class ApiAsignaturaRepository implements AsignaturaRepository {
  ApiAsignaturaRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Asignatura>> getAsignaturas() async {
    final res = await _dio.get('/asignaturas');
    _verificar(res);
    final lista = res.data as List<dynamic>;
    return lista
        .map((j) => _asignaturaFromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Asignatura?> getAsignatura(String id) async {
    final res = await _dio.get('/asignaturas/$id');
    if (res.statusCode == 404) return null;
    _verificar(res);
    return _asignaturaFromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> saveAsignatura(Asignatura asignatura) async {
    // Upsert: intenta actualizar; si el ramo no existe (404), lo crea.
    final patch = await _dio.patch(
      '/asignaturas/${asignatura.id}',
      data: _asignaturaToJson(asignatura, incluirId: false),
    );
    if (patch.statusCode == 404) {
      final post = await _dio.post(
        '/asignaturas',
        data: _asignaturaToJson(asignatura, incluirId: true),
      );
      _verificar(post);
    } else {
      _verificar(patch);
    }
  }

  @override
  Future<void> deleteAsignatura(String id) async {
    final res = await _dio.delete('/asignaturas/$id');
    if (res.statusCode == 404) return; // ya no existe: objetivo cumplido
    _verificar(res);
  }

  // --- Mapeo JSON <-> dominio ---

  Asignatura _asignaturaFromJson(Map<String, dynamic> j) => Asignatura(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        codigo: j['codigo'] as String?,
        semestre: j['semestre'] as String?,
        tieneExamen: j['tieneExamen'] as bool? ?? false,
        pesoPresentacion: (j['pesoPresentacion'] as num?)?.toDouble() ?? 0.6,
        pesoExamen: (j['pesoExamen'] as num?)?.toDouble() ?? 0.4,
        notaExamen: (j['notaExamen'] as num?)?.toDouble(),
        notaEximir: (j['notaEximir'] as num?)?.toDouble(),
        evaluaciones: ((j['evaluaciones'] as List<dynamic>?) ?? [])
            .map((e) => _evaluacionFromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Evaluacion _evaluacionFromJson(Map<String, dynamic> j) => Evaluacion(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        porcentaje: (j['porcentaje'] as num).toDouble(),
        nota: (j['nota'] as num?)?.toDouble(),
        tipo: j['tipo'] as String?,
        fecha: j['fecha'] == null
            ? null
            : DateTime.parse(j['fecha'] as String),
      );

  /// Serializa respetando el contrato del DTO (whitelist estricto del backend:
  /// no se envían llaves desconocidas).
  Map<String, dynamic> _asignaturaToJson(
    Asignatura a, {
    required bool incluirId,
  }) {
    return {
      if (incluirId) 'id': a.id,
      'nombre': a.nombre,
      'codigo': a.codigo,
      'semestre': a.semestre,
      'tieneExamen': a.tieneExamen,
      'pesoPresentacion': a.pesoPresentacion,
      'pesoExamen': a.pesoExamen,
      'notaExamen': a.notaExamen,
      'notaEximir': a.notaEximir,
      'evaluaciones': a.evaluaciones.map(_evaluacionToJson).toList(),
    };
  }

  Map<String, dynamic> _evaluacionToJson(Evaluacion e) => {
        'id': e.id, // se conserva para que el backend sincronice por id
        'nombre': e.nombre,
        'porcentaje': e.porcentaje,
        'nota': e.nota,
        'tipo': e.tipo,
        'fecha': e.fecha?.toIso8601String(),
      };

  /// Lanza [ApiException] con un mensaje legible si la respuesta no es 2xx.
  void _verificar(Response res) {
    final code = res.statusCode ?? 0;
    if (code >= 200 && code < 300) return;
    if (code == 401) {
      throw const ApiException('Tu sesión expiró. Vuelve a iniciar sesión.');
    }
    throw ApiException(_mensajeError(res.data, code));
  }

  String _mensajeError(dynamic data, int code) {
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String) return msg;
      if (msg is List && msg.isNotEmpty) return msg.first.toString();
    }
    return 'Error del servidor ($code)';
  }
}
