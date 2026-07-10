/// Exportación condicional de la implementación de base de datos local.
/// En entornos web compilará `local_db_web.dart` (IndexedDB).
/// En entornos nativos (Linux, Android, iOS) compilará `local_db_non_web.dart` (SharedPreferences).
export 'local_db_non_web.dart'
    if (dart.library.html) 'local_db_web.dart';
