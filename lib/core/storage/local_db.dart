// Exportación condicional de la implementación de base de datos local.
// En web usa IndexedDB y en plataformas nativas usa SharedPreferences.
export 'local_db_non_web.dart' if (dart.library.html) 'local_db_web.dart';
