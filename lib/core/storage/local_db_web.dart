// TODO(promapp): migrar de dart:html a package:web.
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'local_db_interface.dart';

/// Implementación web de [LocalDb] que interactúa directamente con IndexedDB.
class LocalDbImpl implements LocalDb {
  dynamic _db;

  @override
  Future<void> init() async {
    if (_db != null) return;

    final completer = Completer<void>();
    final openRequest = html.window.indexedDB!.open('promapp_db', version: 1);

    openRequest.onUpgradeNeeded.listen((event) {
      final db = openRequest.result;
      if (!db.objectStoreNames!.contains('usuarios')) {
        db.createObjectStore('usuarios', keyPath: 'id');
      }
      if (!db.objectStoreNames!.contains('asignaturas')) {
        db.createObjectStore('asignaturas', keyPath: 'id');
      }
      if (!db.objectStoreNames!.contains('configuracion')) {
        db.createObjectStore('configuracion', keyPath: 'key');
      }
    });

    openRequest.onSuccess.listen((event) {
      _db = openRequest.result;
      completer.complete();
    });

    openRequest.onError.listen((event) {
      completer.completeError(
        'No se pudo inicializar IndexedDB en el navegador',
      );
    });

    await completer.future;

    // Ejecutar migración inicial si existen datos en localStorage
    await _migrarDesdeLocalStorage();
  }

  Future<void> _migrarDesdeLocalStorage() async {
    try {
      final localUser = html.window.localStorage['promapp_user'];
      if (localUser != null) {
        final userData = jsonDecode(localUser) as Map<String, dynamic>;
        if (userData.containsKey('id')) {
          await save('usuarios', userData['id'] as String, userData);
        }
        html.window.localStorage.remove('promapp_user');
      }

      final localRamos = html.window.localStorage['promapp_ramos'];
      if (localRamos != null) {
        final List<dynamic> list = jsonDecode(localRamos) as List<dynamic>;
        for (final item in list) {
          if (item is Map<String, dynamic> && item.containsKey('id')) {
            await save('asignaturas', item['id'] as String, item);
          }
        }
        html.window.localStorage.remove('promapp_ramos');
      }
    } catch (e) {
      // Ignoramos errores de migración para evitar romper el inicio
      html.window.console.warn('Error al migrar datos desde localStorage: $e');
    }
  }

  @override
  Future<void> save(
    String storeName,
    String id,
    Map<String, dynamic> data,
  ) async {
    final db = _db;
    if (db == null) throw Exception('Base de datos no inicializada');

    final txn = db.transaction(storeName, 'readwrite');
    final store = txn.objectStore(storeName);

    final clone = Map<String, dynamic>.from(data);
    clone['id'] = id;

    store.put(clone);
    await txn.completed;
  }

  @override
  Future<Map<String, dynamic>?> get(String storeName, String id) async {
    final db = _db;
    if (db == null) throw Exception('Base de datos no inicializada');

    final txn = db.transaction(storeName, 'readonly');
    final store = txn.objectStore(storeName);
    final request = store.getObject(id);
    await txn.completed;

    final result = request.result;
    if (result == null) return null;

    return Map<String, dynamic>.from(result as Map);
  }

  @override
  Future<List<Map<String, dynamic>>> getAll(String storeName) async {
    final db = _db;
    if (db == null) throw Exception('Base de datos no inicializada');

    final txn = db.transaction(storeName, 'readonly');
    final store = txn.objectStore(storeName);
    final request = store.getAll();
    await txn.completed;

    final List<dynamic> list = request.result as List<dynamic>? ?? [];
    return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  @override
  Future<void> delete(String storeName, String id) async {
    final db = _db;
    if (db == null) throw Exception('Base de datos no inicializada');

    final txn = db.transaction(storeName, 'readwrite');
    final store = txn.objectStore(storeName);
    store.delete(id);
    await txn.completed;
  }

  @override
  Future<void> clearStore(String storeName) async {
    final db = _db;
    if (db == null) throw Exception('Base de datos no inicializada');

    final txn = db.transaction(storeName, 'readwrite');
    final store = txn.objectStore(storeName);
    store.clear();
    await txn.completed;
  }

  @override
  Future<void> clearAll() async {
    await clearStore('usuarios');
    await clearStore('asignaturas');
    await clearStore('configuracion');
  }
}
