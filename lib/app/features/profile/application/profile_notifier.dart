import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arenda/app/features/authentication/application/auth_notifier.dart';
import 'package:arenda/app/features/authentication/application/auth_state.dart';
import 'package:arenda/app/features/authentication/domain/entities/user_entity.dart';
part 'profile_notifier.g.dart';

sealed class ProfileState {
  const ProfileState();
}

final class ProfileIdle extends ProfileState {
  const ProfileIdle();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.user);
  final UserEntity user;
}

final class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;
}

@Riverpod(keepAlive: true)
class ProfileNotifier extends _$ProfileNotifier {
  @override
  ProfileState build() {
    final authState = ref.watch(authProvider);
    if (authState is AuthAuthenticated) return ProfileLoaded(authState.user);
    return const ProfileIdle();
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? location,
    String? avatarUrl,
  }) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    state = const ProfileLoading();
    final updated = current.user.copyWith(
      name: name,
      phone: phone,
      bio: bio,
      location: location,
      avatarUrl: avatarUrl,
    );
    await ref.read(authProvider.notifier).updateProfile(updated);
    state = ProfileLoaded(updated);
  }
}
