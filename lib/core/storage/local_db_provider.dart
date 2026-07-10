import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_db.dart';
import 'local_db_interface.dart';

/// Proveedor global para la base de datos local.
final localDbProvider = Provider<LocalDb>((ref) {
  return LocalDbImpl();
});
