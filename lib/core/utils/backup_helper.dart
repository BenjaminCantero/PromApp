// Exportación condicional para descargas web y portapapeles nativo.
export 'backup_helper_non_web.dart'
    if (dart.library.html) 'backup_helper_web.dart';
