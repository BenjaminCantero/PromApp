import '../../../core/storage/local_db_interface.dart';
import '../domain/asignatura.dart';
import '../domain/evaluacion.dart';
import 'asignatura_repository.dart';

/// Implementación local de [AsignaturaRepository] utilizando [LocalDb]
/// (IndexedDB en web / SharedPreferences en nativo).
/// 
/// Gestiona la persistencia de las asignaturas y sus evaluaciones incrustadas.
class LocalAsignaturaRepository implements AsignaturaRepository {
  LocalAsignaturaRepository(this._db);

  final LocalDb _db;
  static const _storeName = 'asignaturas';

  Future<void> _asegurarDb() async {
    await _db.init();
  }

  @override
  Future<List<Asignatura>> getAsignaturas() async {
    await _asegurarDb();
    final list = await _db.getAll(_storeName);
    
    return list.map((item) {
      final evalsList = (item['evaluaciones'] as List<dynamic>? ?? [])
          .map((e) => Evaluacion.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      return Asignatura.fromMap(item, evaluaciones: evalsList);
    }).toList();
  }

  @override
  Future<Asignatura?> getAsignatura(String id) async {
    await _asegurarDb();
    final item = await _db.get(_storeName, id);
    if (item == null) return null;

    final evalsList = (item['evaluaciones'] as List<dynamic>? ?? [])
        .map((e) => Evaluacion.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    return Asignatura.fromMap(item, evaluaciones: evalsList);
  }

  @override
  Future<void> saveAsignatura(Asignatura asignatura) async {
    await _asegurarDb();

    // Serializamos la asignatura incluyendo sus evaluaciones embebidas
    final map = asignatura.toMap();
    map['evaluaciones'] = asignatura.evaluaciones.map((e) => e.toMap()).toList();

    // En Asignatura.toMap() el campo 'tieneExamen' se guarda como entero (1 o 0).
    // Nos aseguramos de mantener ese formato o boolean según lo esperado por fromMap.
    await _db.save(_storeName, asignatura.id, map);
  }

  @override
  Future<void> deleteAsignatura(String id) async {
    await _asegurarDb();
    await _db.delete(_storeName, id);
  }
}
