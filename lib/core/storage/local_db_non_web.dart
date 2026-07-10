import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_db_interface.dart';

/// Implementación multiplataforma (no web) de [LocalDb] que usa SharedPreferences.
/// Serializa colecciones en JSON para emular object stores de base de datos.
class LocalDbImpl implements LocalDb {
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  String _prefKey(String storeName) => 'promapp_local_store_$storeName';

  Future<List<Map<String, dynamic>>> _loadList(String storeName) async {
    final raw = _prefs?.getString(_prefKey(storeName));
    if (raw == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveList(String storeName, List<Map<String, dynamic>> list) async {
    await _prefs?.setString(_prefKey(storeName), jsonEncode(list));
  }

  @override
  Future<void> save(String storeName, String id, Map<String, dynamic> data) async {
    await init();
    final list = await _loadList(storeName);
    final clone = Map<String, dynamic>.from(data);
    clone['id'] = id;

    final index = list.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      list[index] = clone;
    } else {
      list.add(clone);
    }
    await _saveList(storeName, list);
  }

  @override
  Future<Map<String, dynamic>?> get(String storeName, String id) async {
    await init();
    final list = await _loadList(storeName);
    final index = list.indexWhere((item) => item['id'] == id);
    return index != -1 ? list[index] : null;
  }

  @override
  Future<List<Map<String, dynamic>>> getAll(String storeName) async {
    await init();
    return _loadList(storeName);
  }

  @override
  Future<void> delete(String storeName, String id) async {
    await init();
    final list = await _loadList(storeName);
    list.removeWhere((item) => item['id'] == id);
    await _saveList(storeName, list);
  }

  @override
  Future<void> clearStore(String storeName) async {
    await init();
    await _prefs?.remove(_prefKey(storeName));
  }

  @override
  Future<void> clearAll() async {
    await init();
    await clearStore('usuarios');
    await clearStore('asignaturas');
    await clearStore('configuracion');
  }
}
