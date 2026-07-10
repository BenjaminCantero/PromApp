import 'package:flutter/services.dart';
import 'backup_helper_interface.dart';

/// Implementación multiplataforma (no web) de [BackupHelper].
/// Copia el JSON al portapapeles para exportar y lee del portapapeles para importar,
/// evitando dependencias externas complejas de almacenamiento nativo.
class BackupHelperImpl implements BackupHelper {
  @override
  Future<void> exportar(String jsonContent, String fileName) async {
    await Clipboard.setData(ClipboardData(text: jsonContent));
  }

  @override
  Future<String?> importar() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }
}
