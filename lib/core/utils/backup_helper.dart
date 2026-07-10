/// Exportación condicional de BackupHelper para descargas en la web y
/// fallback de portapapeles en plataformas nativas.
export 'backup_helper_non_web.dart'
    if (dart.library.html) 'backup_helper_web.dart';
