import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_account.dart';

/// Thrown when sign-up or sign-in fails with a message safe to show the user.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Local, on-device account management.
///
/// Accounts are saved in shared preferences. Passwords are never stored in
/// plain text: each one is hashed with its own random salt (iterated
/// HMAC-SHA256), and sign-in compares hashes.
class AuthService {
  AuthService(this._prefs);

  static const _accountsKey = 'auth.accounts';
  static const _sessionKey = 'auth.session';
  static const _lastUsernameKey = 'auth.lastUsername';
  static const _hashIterations = 10000;

  final SharedPreferences _prefs;

  static Future<AuthService> create() async =>
      AuthService(await SharedPreferences.getInstance());

  /// Username from the most recent successful sign-in, for prefilling.
  String? get lastUsername => _prefs.getString(_lastUsernameKey);

  /// Returns the remembered account, if the user chose to stay signed in.
  UserAccount? restoreSession() {
    final username = _prefs.getString(_sessionKey);
    if (username == null) return null;
    return _loadAccounts()[username];
  }

  Future<UserAccount> signUp({
    required String username,
    required String displayName,
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    final key = normalizeUsername(username);
    final usernameError = validateUsername(key);
    if (usernameError != null) throw AuthException(usernameError);
    final passwordError = validatePassword(password);
    if (passwordError != null) throw AuthException(passwordError);

    final accounts = _loadAccounts();
    if (accounts.containsKey(key)) {
      throw const AuthException('That username is already taken.');
    }

    final salt = _generateSalt();
    final account = UserAccount(
      username: key,
      displayName: displayName.trim().isEmpty
          ? username.trim()
          : displayName.trim(),
      email: email.trim(),
      passwordHash: _hashPassword(password, salt),
      salt: salt,
      createdAt: DateTime.now(),
    );
    accounts[key] = account;
    await _saveAccounts(accounts);
    await _startSession(key, rememberMe);
    return account;
  }

  Future<UserAccount> signIn({
    required String username,
    required String password,
    bool rememberMe = true,
  }) async {
    final key = normalizeUsername(username);
    final account = _loadAccounts()[key];
    // Same message for unknown user and wrong password.
    if (account == null ||
        !_constantTimeEquals(
          _hashPassword(password, account.salt),
          account.passwordHash,
        )) {
      throw const AuthException('Incorrect username or password.');
    }
    await _startSession(key, rememberMe);
    return account;
  }

  Future<void> signOut() => _prefs.remove(_sessionKey);

  static String normalizeUsername(String username) =>
      username.trim().toLowerCase();

  static String? validateUsername(String username) {
    final value = normalizeUsername(username);
    if (value.length < 3) return 'Username must be at least 3 characters.';
    if (!RegExp(r'^[a-z0-9_.]+$').hasMatch(value)) {
      return 'Use only letters, numbers, dots and underscores.';
    }
    return null;
  }

  static String? validatePassword(String password) {
    if (password.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  Future<void> _startSession(String username, bool rememberMe) async {
    await _prefs.setString(_lastUsernameKey, username);
    if (rememberMe) {
      await _prefs.setString(_sessionKey, username);
    } else {
      await _prefs.remove(_sessionKey);
    }
  }

  Map<String, UserAccount> _loadAccounts() {
    final raw = _prefs.getString(_accountsKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        key,
        UserAccount.fromJson(Map<String, dynamic>.from(value as Map)),
      ),
    );
  }

  Future<void> _saveAccounts(Map<String, UserAccount> accounts) {
    return _prefs.setString(
      _accountsKey,
      jsonEncode(accounts.map((key, value) => MapEntry(key, value.toJson()))),
    );
  }

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  static String _hashPassword(String password, String salt) {
    final hmac = Hmac(sha256, utf8.encode(password));
    var digest = hmac.convert(utf8.encode(salt)).bytes;
    for (var i = 1; i < _hashIterations; i++) {
      digest = hmac.convert(digest).bytes;
    }
    return base64Encode(digest);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
