import '../../../authentication/domain/entities/user_entity.dart';
import '../../../../core/errors/app_exception.dart';

abstract final class MockAuthDataSource {
  static UserEntity? _currentUser;

  static final _users = <String, ({String password, UserEntity user})>{
    'demo@arenda.com': (
      password: 'demo1234',
      user: UserEntity(
        id: 'u1',
        email: 'demo@arenda.com',
        name: 'Alex Johnson',
        avatarUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
        phone: '+1 (555) 012-3456',
        bio: 'Travel enthusiast and remote worker. Love discovering hidden gems around the world.',
        location: 'San Francisco, CA',
        joinedAt: DateTime(2022, 3, 15),
        isSuperhost: false,
      ),
    ),
  };

  static Future<UserEntity> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final record = _users[email.toLowerCase().trim()];
    if (record == null || record.password != password) {
      throw const AuthException.invalidCredentials();
    }
    _currentUser = record.user;
    return record.user;
  }

  static Future<UserEntity> signUp({
    required String email,
    required String name,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final normalized = email.toLowerCase().trim();
    if (_users.containsKey(normalized)) {
      throw const AuthException.emailAlreadyInUse();
    }
    if (password.length < 8) throw const AuthException.weakPassword();

    final newUser = UserEntity(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      email: normalized,
      name: name.trim(),
      joinedAt: DateTime.now(),
    );

    _users[normalized] = (password: password, user: newUser);
    _currentUser = newUser;
    return newUser;
  }

  static Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  static Future<UserEntity?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentUser;
  }

  static Future<UserEntity> updateProfile(UserEntity updated) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = updated;
    return updated;
  }
}
