/// Interfaz abstracta para la importación y exportación de archivos de respaldo.
abstract class BackupHelper {
  /// Exporta el contenido de texto a un archivo físico en el cliente.
  Future<void> exportar(String jsonContent, String fileName);

  /// Abre un selector de archivos e importa el contenido del archivo JSON seleccionado.
  /// Retorna el contenido de texto del archivo, o `null` si la operación se canceló.
  Future<String?> importar();
}
