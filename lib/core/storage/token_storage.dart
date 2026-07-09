import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda el JWT de forma segura (Keychain iOS / Keystore Android /
/// WebCrypto en web). Persiste entre reinicios de la app.
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _key = 'promapp_auth_token';

  Future<void> save(String token) => _storage.write(key: _key, value: token);

  Future<String?> read() => _storage.read(key: _key);

  Future<void> clear() => _storage.delete(key: _key);
}

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());
