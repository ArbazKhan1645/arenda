import 'package:arenda/app/features/authentication/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:arenda/app/core/theme/app_colors.dart';
import 'package:arenda/app/core/theme/app_dimensions.dart';
import 'package:arenda/app/shared/widgets/app_button.dart';
import 'package:arenda/app/shared/widgets/app_text_field.dart';
import 'package:arenda/app/features/authentication/application/auth_notifier.dart';
import 'package:arenda/app/features/authentication/application/auth_state.dart';
import 'package:arenda/app/features/profile/application/profile_notifier.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authProvider);
    if (auth is AuthAuthenticated) {
      _nameCtrl.text = auth.user.name;
      _phoneCtrl.text = auth.user.phone ?? '';
      _bioCtrl.text = auth.user.bio ?? '';
      _locationCtrl.text = auth.user.location ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(authProvider.notifier)
        .updateProfile(
          UserEntity(
            email: (ref.read(authProvider) as AuthAuthenticated).user.email,
            id: (ref.read(authProvider) as AuthAuthenticated).user.id,
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            bio: _bioCtrl.text.trim(),
            location: _locationCtrl.text.trim(),
          ),
        );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(authProvider);
    final isLoading = profileState is ProfileLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingPage),
          children: [
            const SizedBox(height: AppDimensions.spaceLG),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: AppDimensions.avatarXL,
                    height: AppDimensions.avatarXL,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PhosphorIcons.user(),
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        PhosphorIcons.camera(),
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space2XL),
            AppTextField(
              controller: _nameCtrl,
              label: 'Full name',
              textInputAction: TextInputAction.next,
              prefixIcon: Icon(
                PhosphorIcons.user(),
                size: 18,
                color: AppColors.textSecondary,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name required' : null,
            ),
            const SizedBox(height: AppDimensions.spaceLG),
            AppTextField(
              controller: _phoneCtrl,
              label: 'Phone number',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              prefixIcon: Icon(
                PhosphorIcons.phone(),
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLG),
            AppTextField(
              controller: _bioCtrl,
              label: 'Bio',
              hint: 'Tell us about yourself...',
              maxLines: 3,
              textInputAction: TextInputAction.next,
              prefixIcon: Icon(
                PhosphorIcons.info(),
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLG),
            AppTextField(
              controller: _locationCtrl,
              label: 'Location',
              hint: 'City, Country',
              textInputAction: TextInputAction.done,
              prefixIcon: Icon(
                PhosphorIcons.mapPin(),
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.space2XL),
            AppButton(
              label: 'Save changes',
              onPressed: _save,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
