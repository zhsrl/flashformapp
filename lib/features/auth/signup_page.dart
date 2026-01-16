import 'package:easy_localization/easy_localization.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/app_validator.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/core/utils/utils.dart';
import 'package:flashform_app/data/controller/auth_controller.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SigninPageState();
}

class _SigninPageState extends ConsumerState<SignupPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController;

  final _signUpFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
  }

  Future<void> signUp(
    String email,
    String password,
    String name,
  ) async {
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signUpWithEmailAndPassword(email, password, name)
          .then(
            (_) {
              if (mounted) {
                context.push('/confirm-email');
              }
            },
          );
    } catch (e) {
      String message = e.toString().replaceAll('Exception: ', '');
      if (mounted) {
        showSnackbar(context, type: SnackbarType.error, message: message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'global.language'.tr(),

                  style: TextStyle(
                    color: AppTheme.tertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    showMenu(
                      color: AppTheme.background,
                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: AppTheme.border,
                        ),
                        borderRadius: BorderRadiusGeometry.circular(16),
                      ),
                      position: RelativeRect.fromLTRB(
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                      ),
                      context: context,
                      items: [
                        PopupMenuItem(
                          onTap: () {
                            context.setLocale(Locale('kk'));
                          },
                          child: Text(
                            '${countryCodeToEmoji('KZ')} ${'global.lang-kz'.tr()}',
                          ),
                        ),

                        PopupMenuItem(
                          onTap: () {
                            context.setLocale(Locale('ru'));
                          },
                          child: Text(
                            '${countryCodeToEmoji('RU')} ${'global.lang-ru'.tr()}',
                          ),
                        ),
                      ],
                    );
                  },
                  child: Text(
                    context.locale == Locale('ru')
                        ? 'global.lang-ru'.tr()
                        : 'global.lang-kz'.tr(),
                    style: TextStyle(
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              width: 350,
              padding: EdgeInsets.symmetric(
                horizontal: context.isMobile ? 12 : 0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'images/logo-short.svg',
                    width: 50,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    'auth.signup-title'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Form(
                    key: _signUpFormKey,
                    child: Column(
                      children: [
                        FFTextField(
                          hintText: 'field.name'.tr(),
                          prefixIcon: HeroIcon(HeroIcons.user),
                          controller: _nameController,
                          validator: AppValidators.name,
                        ),
                        FFTextField(
                          hintText: 'field.email'.tr(),
                          prefixIcon: HeroIcon(HeroIcons.envelope),
                          controller: _emailController,
                          validator: AppValidators.email,
                        ),
                        FFTextField(
                          hintText: 'field.password'.tr(),
                          prefixIcon: HeroIcon(HeroIcons.lockClosed),
                          controller: _passwordController,
                          validator: AppValidators.password,
                          isPassword: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FFButton(
                      isLoading: ref.watch(authControllerProvider),
                      onPressed: () {
                        String name = _nameController.text;
                        String email = _emailController.text;
                        String password = _passwordController.text;

                        if (_signUpFormKey.currentState!.validate()) {
                          signUp(email, password, name);
                        }
                      },
                      text: 'button.signup'.tr(),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  GestureDetector(
                    onTap: () => context.go('/signin'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('auth.do-you-have-account'.tr()),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          'auth.signin-text'.tr(),

                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
