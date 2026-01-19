import 'package:country_flags/country_flags.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart';

class SigninPage extends ConsumerStatefulWidget {
  const SigninPage({super.key});

  @override
  ConsumerState<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends ConsumerState<SigninPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  final _signInFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  Future<void> signIn(String email, String password) async {
    try {
      await ref.read(authControllerProvider.notifier).signIn(email, password);

      final currentUser = Supabase.instance.client.auth.currentUser;

      if (currentUser != null) {
        if (mounted) {
          context.replace('/');
        }
      }
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
                    'auth.signin-title'.tr(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),
                  Form(
                    key: _signInFormKey,
                    child: Column(
                      children: [
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
                        String email = _emailController.text;
                        String password = _passwordController.text;

                        if (_signInFormKey.currentState!.validate()) {
                          signIn(email, password);
                        }
                      },
                      text: 'button.signin'.tr(),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.go('/signup');
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('auth.are-you-first'.tr()),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              'auth.signup-text'.tr(),

                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('forgot-password.title'.tr()),
                                backgroundColor: AppTheme.background,
                                content: SizedBox(
                                  width: 350,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'forgot-password.subtitle'.tr(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: FFButton(
                                              onPressed: () {
                                                openMessenger(
                                                  'https://t.me/flashform',
                                                );
                                              },

                                              text: 'Telegram',
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          Expanded(
                                            child: FFButton(
                                              onPressed: () {
                                                openMessenger(
                                                  'https://api.whatsapp.com/send/?phone=77066215981&text&type=phone_number&app_absent=0',
                                                );
                                              },
                                              text: 'WhatsApp',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: SizedBox(
                          width: 150,
                          child: Text(
                            'auth.forgot-password'.tr(),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.secondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
