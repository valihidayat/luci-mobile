import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveCredentials({
    required String ipAddress,
    required String username,
    required String password,
    required bool useHttps,
  }) async {
    await _storage.write(key: 'ipAddress', value: ipAddress);
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
    await _storage.write(key: 'useHttps', value: useHttps.toString());
  }

  Future<Map<String, String?>> getCredentials() async {
    final ipAddress = await _storage.read(key: 'ipAddress');
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    final useHttps = await _storage.read(key: 'useHttps');
    return {
      'ipAddress': ipAddress,
      'username': username,
      'password': password,
      'useHttps': useHttps,
    };
  }

  Future<void> clearCredentials() async {
    await _storage.deleteAll();
  }

  Future<String?> readValue(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> writeValue(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
}
