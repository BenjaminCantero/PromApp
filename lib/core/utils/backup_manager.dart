import 'dart:convert';
import '../storage/local_db_interface.dart';
import 'backup_helper.dart';

/// Lógica de negocio para exportar e importar datos locales con validación estricta de tipos.
class BackupManager {
  BackupManager(this._db);

  final LocalDb _db;

  /// Exporta el usuario local y todas sus asignaturas a un archivo JSON formateado.
  Future<void> exportarRespaldo() async {
    await _db.init();

    final usuarios = await _db.getAll('usuarios');
    final asignaturas = await _db.getAll('asignaturas');

    final backup = {
      'version': 1,
      'exportadoEn': DateTime.now().toIso8601String(),
      'usuarios': usuarios,
      'asignaturas': asignaturas,
    };

    final jsonContent = const JsonEncoder.withIndent('  ').convert(backup);
    final helper = BackupHelperImpl();
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await helper.exportar(jsonContent, 'promapp_respaldo_$timestamp.json');
  }

  /// Importa un respaldo en formato JSON de texto, validando estrictamente su estructura.
  /// Lanza [FormatException] si la estructura de datos no cumple con el esquema esperado.
  Future<void> importarRespaldo(String jsonString) async {
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('El archivo no contiene un formato JSON válido');
    }

    // ── Validar versión ──
    if (data['version'] == null || data['version'] is! int) {
      throw const FormatException('Falta la versión de formato del respaldo');
    }
    if (data['version'] != 1) {
      throw const FormatException('Versión de formato de respaldo no soportada');
    }

    // ── Validar claves principales ──
    if (data['usuarios'] == null || data['usuarios'] is! List) {
      throw const FormatException('Los datos de usuarios están corruptos o ausentes');
    }
    if (data['asignaturas'] == null || data['asignaturas'] is! List) {
      throw const FormatException('Los datos de asignaturas están corruptos o ausentes');
    }

    final usuarios = data['usuarios'] as List<dynamic>;
    final asignaturas = data['asignaturas'] as List<dynamic>;

    // ── Validar usuarios ──
    for (final u in usuarios) {
      if (u is! Map<String, dynamic>) {
        throw const FormatException('Formato de usuario inválido');
      }
      if (u['id'] == null || u['id'] is! String || (u['id'] as String).isEmpty) {
        throw const FormatException('El ID del usuario es inválido o está ausente');
      }
      if (u['email'] == null || u['email'] is! String) {
        throw const FormatException('El correo del usuario es inválido o está ausente');
      }
      if (u['nombre'] == null || u['nombre'] is! String) {
        throw const FormatException('El nombre del usuario es inválido o está ausente');
      }
    }

    // ── Validar asignaturas y evaluaciones embebidas ──
    for (final a in asignaturas) {
      if (a is! Map<String, dynamic>) {
        throw const FormatException('Formato de asignatura inválido');
      }
      if (a['id'] == null || a['id'] is! String || (a['id'] as String).isEmpty) {
        throw const FormatException('El ID del ramo es inválido o está ausente');
      }
      if (a['nombre'] == null || a['nombre'] is! String) {
        throw const FormatException('El nombre del ramo es inválido o está ausente');
      }

      final evals = a['evaluaciones'];
      if (evals != null) {
        if (evals is! List) {
          throw const FormatException('Las evaluaciones del ramo no tienen el formato correcto');
        }
        for (final e in evals) {
          if (e is! Map<String, dynamic>) {
            throw const FormatException('Formato de evaluación inválido');
          }
          if (e['id'] == null || e['id'] is! String || (e['id'] as String).isEmpty) {
            throw const FormatException('El ID de una evaluación es inválido o está ausente');
          }
          if (e['nombre'] == null || e['nombre'] is! String) {
            throw const FormatException('El nombre de una evaluación es inválido o está ausente');
          }
          if (e['porcentaje'] == null || e['porcentaje'] is! num) {
            throw const FormatException('El porcentaje de una evaluación es inválido o está ausente');
          }
        }
      }
    }

    // ── Escritura atómica en base de datos local ──
    await _db.init();

    // Guardar estado actual en caso de que falle la importación
    final backupUsuarios = await _db.getAll('usuarios');
    final backupAsignaturas = await _db.getAll('asignaturas');

    try {
      // Limpiar bases de datos actuales
      await _db.clearStore('usuarios');
      await _db.clearStore('asignaturas');

      // Escribir nuevos datos
      for (final u in usuarios) {
        final map = Map<String, dynamic>.from(u as Map);
        await _db.save('usuarios', map['id'] as String, map);
      }

      for (final a in asignaturas) {
        final map = Map<String, dynamic>.from(a as Map);
        await _db.save('asignaturas', map['id'] as String, map);
      }
    } catch (e) {
      // Revertir cambios en caso de error de escritura local
      await _db.clearStore('usuarios');
      await _db.clearStore('asignaturas');
      
      for (final u in backupUsuarios) {
        await _db.save('usuarios', u['id'] as String, u);
      }
      for (final a in backupAsignaturas) {
        await _db.save('asignaturas', a['id'] as String, a);
      }
      throw FormatException('Error crítico al escribir en la base de datos local: $e');
    }
  }

  /// Borra todos los datos locales (usuario y asignaturas) de IndexedDB.
  Future<void> borrarTodo() async {
    await _db.init();
    await _db.clearAll();
  }
}
