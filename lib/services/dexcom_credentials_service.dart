import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DexcomCredentialsService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const String _usernameKey = 'dexcom_username';
  static const String _passwordKey = 'dexcom_password';
  static const String _regionKey = 'dexcom_region';

  static Future<void> saveCredentials({
    required String username,
    required String password,
    required String region,
  }) async {
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _passwordKey, value: password);
    await _storage.write(key: _regionKey, value: region);
  }

  static Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  static Future<String?> getPassword() async {
    return await _storage.read(key: _passwordKey);
  }

  static Future<String?> getRegion() async {
    return await _storage.read(key: _regionKey);
  }

  static Future<DexcomCredentials?> getCredentials() async {
    final username = await _storage.read(key: _usernameKey);
    final password = await _storage.read(key: _passwordKey);
    final region = await _storage.read(key: _regionKey);

    if (username != null && password != null) {
      return DexcomCredentials(
        username: username,
        password: password,
        region: region ?? 'ous',
      );
    }
    return null;
  }

  static Future<bool> hasCredentials() async {
    final username = await _storage.read(key: _usernameKey);
    final password = await _storage.read(key: _passwordKey);
    return username != null && password != null;
  }

  static Future<void> deleteCredentials() async {
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _passwordKey);
    await _storage.delete(key: _regionKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

class DexcomCredentials {
  final String username;
  final String password;
  final String region;

  DexcomCredentials({
    required this.username,
    required this.password,
    required this.region,
  });

  Map<String, String> toMap() {
    return {
      'username': username,
      'password': password,
      'region': region,
    };
  }
}
