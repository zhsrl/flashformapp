import 'package:easy_localization/easy_localization.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/app_validator.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/forms_controller.dart';
import 'package:flashform_app/data/controller/plan_usage_controller.dart';
import 'package:flashform_app/data/controller/user_controller.dart';
import 'package:flashform_app/features/home/widgets/ff_bottom_nav_bar.dart';
import 'package:flashform_app/features/settings/utils/subscription_plans_presenter.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _formTitleController;

  bool _isCreatingForm = false;

  @override
  void initState() {
    super.initState();
    _formTitleController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userControllerProvider.notifier).loadProfile();
    });
  }

  int _getSelectedindex(String location) {
    if (location.startsWith('/forms')) return 0;
    if (location.startsWith('/tables')) return 1;
    if (location.startsWith('/settings')) return 2;

    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    final routes = <int, String>{
      0: '/forms',
      1: '/tables',
      2: '/settings',
    };

    final targetRoute = routes[index];
    if (targetRoute == null) return;

    final currentRoute = GoRouter.of(
      context,
    ).routeInformationProvider.value.uri.path;

    if (currentRoute == targetRoute) return;
    context.go(targetRoute);
  }

  Future<void> _openSubscriptionPlans() async {
    if (!mounted) return;
    await showSubscriptionPlansPresenter(context);
  }

  showFormLimitDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.secondary,
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'dialogs.form-limit.title'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'dialogs.form-limit.description'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                FFButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _openSubscriptionPlans();
                  },
                  text: 'dialogs.form-limit.button-text'.tr(),
                  secondTheme: true,
                  marginBottom: 0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showCreateFormDialog() {
    showDialog(
      context: context,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,

              title: Text(
                'home.new-form-title'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: Consumer(
                builder: (context, ref, child) {
                  return SizedBox(
                    width: 350,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Form(
                          key: _formKey,
                          child: FFTextField(
                            prefixIcon: HeroIcon(HeroIcons.listBullet),
                            hintText: 'home.new-form-text'.tr(),
                            controller: _formTitleController,
                            validator: AppValidators.validatorForEmpty,
                          ),
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: FFButton(
                            isLoading: _isCreatingForm,
                            onPressed: () async {
                              try {
                                if (_formKey.currentState!.validate()) {
                                  setDialogState(() {
                                    _isCreatingForm = true;
                                  });

                                  String name = _formTitleController.text
                                      .trim();
                                  final newFormId = await ref
                                      .read(formControllerProvider.notifier)
                                      .createNewForm(name);

                                  if (!context.mounted) return;

                                  debugPrint('Form created! ID: $newFormId');

                                  if (newFormId != null) {
                                    Navigator.pop(context);

                                    setDialogState(() {
                                      _isCreatingForm = false;
                                    });

                                    context.go('/create-form/$newFormId');
                                  }
                                }
                              } finally {
                                if (mounted) {
                                  setDialogState(() {
                                    _isCreatingForm = false;
                                  });
                                }
                              }
                            },
                            text: 'button.create'.tr(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);

    return AnimatedBuilder(
      animation: router.routerDelegate,
      builder: (context, _) {
        final location = router.routeInformationProvider.value.uri.path;

        return Scaffold(
          // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: context.isMobile
              ? FloatingActionButton(
                  onPressed: () async {
                    final usageAsync = ref.read(planUsageProvider);

                    await usageAsync.when(
                      data: (usage) {
                        if (usage.isFormsLimitReached) {
                          showFormLimitDialog();
                        } else {
                          showCreateFormDialog();
                        }
                      },
                      loading: () {},

                      error: (er, st) {
                        showSnackbar(
                          context,
                          type: SnackbarType.error,
                          message: 'Error: $er',
                        );
                      },
                    );
                  },
                  backgroundColor: AppTheme.secondary,
                  foregroundColor: AppTheme.primary,
                  child: HeroIcon(HeroIcons.plus),
                  // child: Row(
                  //   children: [
                  //     HeroIcon(HeroIcons.plus),
                  //     const SizedBox(
                  //       width: 8,
                  //     ),
                  //     Text('Создать'),
                  //   ],
                  // ),
                )
              : null,
          bottomNavigationBar: context.isMobile
              ? BottomNavigationBar(
                  onTap: (index) {
                    _onItemTapped(index, context);
                  },
                  backgroundColor: AppTheme.background,
                  selectedItemColor: AppTheme.secondary,
                  unselectedItemColor: AppTheme.secondary.withAlpha(50),
                  iconSize: 20,
                  showUnselectedLabels: false,

                  currentIndex: _getSelectedindex(location),
                  items: [
                    BottomNavigationBarItem(
                      icon: HeroIcon(HeroIcons.inbox),
                      label: 'nav-bar.forms'.tr(),
                      activeIcon: HeroIcon(
                        HeroIcons.inbox,
                        style: HeroIconStyle.solid,
                      ),
                    ),
                    BottomNavigationBarItem(
                      icon: HeroIcon(HeroIcons.squares2x2),
                      label: 'nav-bar.leads'.tr(),
                      activeIcon: HeroIcon(
                        HeroIcons.squares2x2,
                        style: HeroIconStyle.solid,
                      ),
                    ),
                    BottomNavigationBarItem(
                      icon: HeroIcon(HeroIcons.cog6Tooth),
                      label: 'nav-bar.settings'.tr(),
                      activeIcon: HeroIcon(
                        HeroIcons.cog6Tooth,
                        style: HeroIconStyle.solid,
                      ),
                    ),
                  ],
                )
              : SizedBox(),
          body: Stack(
            children: [
              widget.child,

              if (context.isDesktop || context.isTablet)
                FFBottomNavBar(
                  selectedIndex: _getSelectedindex(location),
                  onItemTapped: (index) {
                    _onItemTapped(index, context);
                  },

                  onCreateForm: () async {
                    final usageAsync = ref.read(planUsageProvider);

                    await usageAsync.when(
                      data: (usage) {
                        if (usage.isFormsLimitReached) {
                          showFormLimitDialog();
                        } else {
                          showCreateFormDialog();
                        }
                      },
                      loading: () {},

                      error: (er, st) {
                        showSnackbar(
                          context,
                          type: SnackbarType.error,
                          message: 'Error: $er',
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
