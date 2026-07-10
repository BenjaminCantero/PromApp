import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'backup_helper_interface.dart';

/// Implementación web de [BackupHelper] que interactúa con las APIs del navegador
/// para descargar archivos y subir archivos localmente.
class BackupHelperImpl implements BackupHelper {
  @override
  Future<void> exportar(String jsonContent, String fileName) async {
    final bytes = utf8.encode(jsonContent);
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = fileName;

    html.document.body!.children.add(anchor);
    anchor.click();

    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  @override
  Future<String?> importar() async {
    final completer = Completer<String?>();
    final uploadInput = html.FileUploadInputElement()..accept = '.json';
    
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }

      final file = files[0];
      final reader = html.FileReader();
      reader.readAsText(file);
      
      reader.onLoadEnd.listen((e) {
        completer.complete(reader.result as String?);
      });
      
      reader.onError.listen((e) {
        completer.completeError('No se pudo leer el archivo JSON seleccionado');
      });
    });

    return completer.future;
  }
}
