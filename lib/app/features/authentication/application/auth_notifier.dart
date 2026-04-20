import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arenda/app/features/authentication/data/datasources/mock_auth_datasource.dart';
import 'package:arenda/app/features/authentication/domain/entities/user_entity.dart';
import 'package:arenda/app/features/authentication/application/auth_state.dart';

part 'auth_notifier.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    _checkCurrentUser();
    return const AuthInitial();
  }

  Future<void> _checkCurrentUser() async {
    state = const AuthLoading();
    final user = await MockAuthDataSource.getCurrentUser();
    state = user != null
        ? AuthAuthenticated(user)
        : const AuthUnauthenticated();
  }

  Future<bool> signIn(String email, String password) async {
    state = const AuthLoading();
    try {
      final user = await MockAuthDataSource.signIn(email, password);
      state = AuthAuthenticated(user);
      return true;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String name,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final user = await MockAuthDataSource.signUp(
        email: email,
        name: name,
        password: password,
      );
      state = AuthAuthenticated(user);
      return true;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await MockAuthDataSource.signOut();
    state = const AuthUnauthenticated();
  }

  Future<void> updateProfile(UserEntity updated) async {
    final user = await MockAuthDataSource.updateProfile(updated);
    state = AuthAuthenticated(user);
  }

  void clearError() {
    state = const AuthUnauthenticated();
  }

  Future<bool> verifyOtpSignIn({
    required String identifier,
    required String otp,
  }) async {
    state = const AuthLoading();
    try {
      final user = await MockAuthDataSource.verifyOtpAndSignIn(
        identifier: identifier,
        otp: otp,
      );
      state = AuthAuthenticated(user);
      return true;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<bool> verifyOtpSignUp({
    required String identifier,
    required String name,
    required String otp,
  }) async {
    state = const AuthLoading();
    try {
      final user = await MockAuthDataSource.verifyOtpAndSignUp(
        identifier: identifier,
        name: name,
        otp: otp,
      );
      state = AuthAuthenticated(user);
      return true;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<bool> hasSeenOnboarding() => MockAuthDataSource.isOnboarded();

  Future<void> markOnboarded() => MockAuthDataSource.markOnboarded();

  UserEntity? get currentUser => switch (state) {
    AuthAuthenticated(:final user) => user,
    _ => null,
  };
}
