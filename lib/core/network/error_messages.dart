/// Obtiene un mensaje de error legible a partir de una excepción.
String mensajeDeError(dynamic e) {
  if (e == null) return 'Ocurrió un error inesperado';
  if (e is String) return e;
  
  // Limpia el mensaje si contiene el nombre de la clase Exception
  final msg = e.toString();
  if (msg.startsWith('Exception: ')) {
    return msg.substring(11);
  }
  return msg;
}
