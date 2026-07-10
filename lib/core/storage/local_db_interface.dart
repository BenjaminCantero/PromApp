/// Interfaz abstracta para el almacenamiento local.
/// Define las operaciones CRUD básicas y de administración.
abstract class LocalDb {
  Future<void> init();

  /// Guarda un registro en un almacén específico por su ID.
  Future<void> save(String storeName, String id, Map<String, dynamic> data);

  /// Obtiene un registro por su ID de un almacén específico.
  Future<Map<String, dynamic>?> get(String storeName, String id);

  /// Obtiene todos los registros de un almacén.
  Future<List<Map<String, dynamic>>> getAll(String storeName);

  /// Elimina un registro por su ID.
  Future<void> delete(String storeName, String id);

  /// Borra todos los registros de un almacén específico.
  Future<void> clearStore(String storeName);

  /// Borra toda la base de datos local.
  Future<void> clearAll();
}
