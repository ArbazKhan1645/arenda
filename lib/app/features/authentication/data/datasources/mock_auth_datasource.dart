import 'package:shared_preferences/shared_preferences.dart';

import '../../../authentication/domain/entities/user_entity.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/local/storage_service.dart';

abstract final class MockAuthDataSource {
  static const _kLoggedInEmail = 'arenda_logged_in_email';

  static UserEntity? _currentUser;

  static final _users = <String, ({String password, UserEntity user})>{
    'demo@arenda.com': (
      password: 'demo1234',
      user: UserEntity(
        id: 'u1',
        email: 'demo@arenda.com',
        name: 'Konan Yao',
        avatarUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
        phone: '+225 07 00 00 00 00',
        bio:
            'Passionné de voyage et de découverte. J\'adore explorer les trésors cachés de la Côte d\'Ivoire.',
        location: 'Abidjan, Côte d\'Ivoire',
        joinedAt: DateTime(2023, 6, 1),
        isSuperhost: false,
      ),
    ),
    // Also support phone number login for CI
    '07000000': (
      password: 'demo1234',
      user: UserEntity(
        id: 'u1',
        email: 'demo@arenda.com',
        name: 'Konan Yao',
        avatarUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
        phone: '+225 07 00 00 00 00',
        bio: 'Passionné de voyage et de découverte.',
        location: 'Abidjan, Côte d\'Ivoire',
        joinedAt: DateTime(2023, 6, 1),
        isSuperhost: false,
      ),
    ),
  };

  static Future<UserEntity> signIn(String identifier, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final key = identifier.toLowerCase().trim().replaceAll(' ', '');
    final record = _users[key];
    if (record == null || record.password != password) {
      throw const AuthException.invalidCredentials();
    }
    _currentUser = record.user;
    // Persist session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLoggedInEmail, key);
    return record.user;
  }

  static Future<UserEntity> signUp({
    required String email,
    required String name,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final normalized = email.toLowerCase().trim().replaceAll(' ', '');
    if (_users.containsKey(normalized)) {
      throw const AuthException.emailAlreadyInUse();
    }
    if (password.length < 8) throw const AuthException.weakPassword();

    final newUser = UserEntity(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      email: normalized.contains('@') ? normalized : '$normalized@arenda.app',
      name: name.trim(),
      phone: normalized.startsWith('+') ? normalized : null,
      location: 'Abidjan, Côte d\'Ivoire',
      joinedAt: DateTime.now(),
    );

    _users[normalized] = (password: password, user: newUser);
    _currentUser = newUser;
    // Persist session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLoggedInEmail, normalized);
    return newUser;
  }

  static Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLoggedInEmail);
  }

  /// Restores session from SharedPreferences on app restart.
  static Future<UserEntity?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_currentUser != null) return _currentUser;
    // Try to restore from persisted email
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString(_kLoggedInEmail);
    if (savedKey != null && _users.containsKey(savedKey)) {
      _currentUser = _users[savedKey]!.user;
      return _currentUser;
    }
    return null;
  }

  static Future<UserEntity> updateProfile(UserEntity updated) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = updated;
    return updated;
  }

  static Future<UserEntity> verifyOtpAndSignIn({
    required String identifier,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (otp.trim() != '123456') throw const AuthException.invalidCredentials();
    final key = identifier.toLowerCase().trim().replaceAll(' ', '');
    final record = _users[key];
    if (record == null) throw const AuthException.invalidCredentials();
    _currentUser = record.user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLoggedInEmail, key);
    return record.user;
  }

  static Future<UserEntity> verifyOtpAndSignUp({
    required String identifier,
    required String name,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (otp.trim() != '123456') throw const AuthException.invalidCredentials();
    final normalized = identifier.toLowerCase().trim().replaceAll(' ', '');
    if (_users.containsKey(normalized)) {
      throw const AuthException.emailAlreadyInUse();
    }
    final newUser = UserEntity(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      email: normalized.contains('@') ? normalized : '$normalized@arenda.app',
      name: name.trim(),
      phone: normalized.startsWith('+') ? normalized : null,
      location: 'Abidjan, Côte d\'Ivoire',
      joinedAt: DateTime.now(),
    );
    _users[normalized] = (password: '', user: newUser);
    _currentUser = newUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLoggedInEmail, normalized);
    return newUser;
  }

  static Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(StorageKeys.isOnboarded) ?? false;
  }

  static Future<void> markOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.isOnboarded, true);
  }
}
