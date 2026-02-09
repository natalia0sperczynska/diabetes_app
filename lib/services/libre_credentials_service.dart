import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LibreCredentialsService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const String _emailKey = 'libre_email';
  static const String _passwordKey = 'libre_password';

  static Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _passwordKey, value: password);
  }

  static Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  static Future<String?> getPassword() async {
    return await _storage.read(key: _passwordKey);
  }

  static Future<LibreCredentials?> getCredentials() async {
    final email = await _storage.read(key: _emailKey);
    final password = await _storage.read(key: _passwordKey);

    if (email != null && password != null) {
      return LibreCredentials(
        email: email,
        password: password,
      );
    }
    return null;
  }

  static Future<bool> hasCredentials() async {
    final email = await _storage.read(key: _emailKey);
    final password = await _storage.read(key: _passwordKey);
    return email != null && password != null;
  }

  static Future<void> deleteCredentials() async {
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _passwordKey);
  }
}

class LibreCredentials {
  final String email;
  final String password;

  LibreCredentials({
    required this.email,
    required this.password,
  });

  Map<String, String> toMap() {
    return {
      'email': email,
      'password': password,
    };
  }
}
