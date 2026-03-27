import 'package:easy_localization/easy_localization.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/app_validator.dart';
import 'package:flashform_app/core/utils/auth_error_localizer.dart';
import 'package:flashform_app/data/controller/auth_controller.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final errorCode = Uri.base.queryParameters['error_code'];
      if (errorCode == null || errorCode.isEmpty) return;
      if (!mounted) return;

      final message = localizeAuthError(Exception(errorCode));
      showSnackbar(context, type: SnackbarType.error, message: message);
      context.go('/signin');
    });
  }

  Future<void> _setNewPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final password = _passwordController.text.trim();

    await ref.read(authControllerProvider.notifier).setNewPassword(password);

    final authState = ref.read(authControllerProvider);
    if (authState.hasError) {
      final message = localizeAuthError(authState.error!);
      if (!mounted) return;
      showSnackbar(context, type: SnackbarType.error, message: message);
      return;
    }

    if (!mounted) return;
    showSnackbar(
      context,
      type: SnackbarType.info,
      message: 'reset-password.success'.tr(),
    );
    context.go('/signin');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Container(
          width: 420,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/images/logo-short.svg',
                width: 50,
              ),
              const SizedBox(height: 12),
              Text(
                'reset-password.title'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'reset-password.subtitle'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.tertiary,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    FFTextField(
                      hintText: 'field.password'.tr(),
                      prefixIcon: HeroIcon(HeroIcons.lockClosed),
                      controller: _passwordController,
                      validator: AppValidators.password,
                      isPassword: true,
                    ),
                    FFTextField(
                      hintText: 'reset-password.confirm-password'.tr(),
                      prefixIcon: HeroIcon(HeroIcons.lockClosed),
                      controller: _confirmPasswordController,
                      validator: (value) => AppValidators.confirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      isPassword: true,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FFButton(
                  onPressed: _setNewPassword,
                  isLoading: authState.isLoading,
                  text: 'reset-password.save'.tr(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
