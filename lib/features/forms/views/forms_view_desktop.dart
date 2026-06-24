import 'dart:ui';

import 'package:dashed_border/dashed_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/app_validator.dart';
import 'package:flashform_app/core/utils/logger.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/forms_controller.dart';
import 'package:flashform_app/data/controller/plan_usage_controller.dart';
import 'package:flashform_app/data/controller/user_controller.dart';
import 'package:flashform_app/data/model/form.dart';
import 'package:flashform_app/features/home/widgets/home_appbar.dart';
import 'package:flashform_app/features/forms/widgets/shared/form_card.dart';
import 'package:flashform_app/features/settings/utils/subscription_plans_presenter.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_loading.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FormsViewDesktop extends ConsumerStatefulWidget {
  const FormsViewDesktop({super.key});

  @override
  ConsumerState<FormsViewDesktop> createState() => _FormsViewDesktopViewState();
}

class _FormsViewDesktopViewState extends ConsumerState<FormsViewDesktop> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _formTitleController;

  bool _isCreatingForm = false;

  @override
  void initState() {
    super.initState();
    _formTitleController = TextEditingController();
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
                'Новая страница',
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
                            hintText: 'Напишите название',
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

                                  logger.i('Form created! ID: $newFormId');

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
                            text: 'Создать',
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

  Future<void> _openSubscriptionPlans() async {
    if (!mounted) return;
    await showSubscriptionPlansPresenter(context);
  }

  void _showTrialActivationIntroDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Активируйте 7-дневный пробный период',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SizedBox(
            width: 380,
            child: Text(
              'Чтобы создать форму, активируйте бесплатный пробный период на тарифе Go.',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          actions: [
            FFButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _openSubscriptionPlans();
              },
              text: 'Активировать',
              secondTheme: true,
              marginBottom: 0,
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleCreateForm() async {
    final user = ref.read(userControllerProvider).user;

    if (user != null) {
      if (user.isTrialAvailable && user.planExpiresAt == null) {
        _showTrialActivationIntroDialog();
        return;
      }

      if (!user.isPlanActive) {
        await _openSubscriptionPlans();
        return;
      }
    }

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

  @override
  Widget build(BuildContext context) {
    final formsAsync = ref.watch(formControllerProvider);

    final user = ref.watch(userControllerProvider).user;

    // if(userState.isLoading) {
    //   return
    // }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: HomeAppBar(),

      body: Column(
        children: [
          // Виджет который показывает доступен бесплатный период
          if (user != null &&
              user.isTrialAvailable &&
              !user.isTrialUsed &&
              user.planExpiresAt == null)
            if (context.isMobile)
              Container(
                width: context.screenWidth,

                margin: .all(16),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: .circular(24),
                ),
                child: Padding(
                  padding: .all(16),
                  child: Column(
                    mainAxisAlignment: .spaceBetween,
                    crossAxisAlignment: .center,
                    children: [
                      Row(
                        children: [
                          HeroIcon(
                            HeroIcons.fire,
                            style: HeroIconStyle.solid,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            'Тариф Go: 7 дней бесплатно',
                            textAlign: .center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Разблокируйте все инструменты прямо сейчас. Активируйте Spark, чтобы уже через минуту поднять эффективность ваших страниц на новый уровень.',
                        textAlign: .center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withAlpha(150),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      FFButton(
                        onPressed: () {
                          _openSubscriptionPlans();
                        },
                        text: 'Активировать',
                        secondTheme: true,
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                width: context.screenWidth,

                margin: .all(16),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: .circular(24),
                ),
                child: Padding(
                  padding: .all(16),
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    crossAxisAlignment: .center,
                    children: [
                      Column(
                        crossAxisAlignment: .start,
                        children: [
                          Row(
                            children: [
                              HeroIcon(
                                HeroIcons.fire,
                                style: HeroIconStyle.solid,
                                color: AppTheme.primary,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                'Тариф Go: 7 дней бесплатно',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Разблокируйте все инструменты прямо сейчас. Активируйте Spark,\nчтобы уже через минуту поднять эффективность ваших страниц на новый уровень.',
                            style: TextStyle(
                              color: Colors.white.withAlpha(150),
                            ),
                          ),
                        ],
                      ),
                      FFButton(
                        onPressed: () {
                          _openSubscriptionPlans();
                        },
                        text: 'Активировать',
                        secondTheme: true,
                      ),
                    ],
                  ),
                ),
              ),
          // Виджет который показывает истечение подписки
          if (user != null && !user.isPlanActive && user.isTrialUsed)
            Container(
              width: context.screenWidth,

              margin: .all(16),
              padding: .symmetric(vertical: 16),

              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 31, 6, 4),
                borderRadius: .circular(24),
              ),
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .center,
                children: [
                  HeroIcon(
                    HeroIcons.creditCard,
                    size: 50,
                    color: Colors.red,
                  ),
                  Text(
                    'Пожалуйста, оплатите подписку',
                    textAlign: .center,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Из-за окончания подписки ваши страницы сейчас недоступны для посетителей.\nПродлите тариф, чтобы мгновенно вернуть их в онлайн.',
                    textAlign: .center,
                    style: TextStyle(
                      color: Colors.white.withAlpha(150),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  FFButton(
                    onPressed: () {
                      _openSubscriptionPlans();
                    },
                    text: 'Продлить подписку',
                    secondTheme: true,
                  ),
                ],
              ),
            ),

          // Основной часть
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: formsAsync.when(
                  data: (forms) {
                    if (forms.isEmpty) {
                      return Center(
                        child: InkWell(
                          onTap: () {
                            _handleCreateForm();
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 200,
                            height: 200,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: DashedBorder(
                                color: AppTheme.secondary.withAlpha(100),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  HeroIcon(
                                    HeroIcons.plusCircle,
                                    color: AppTheme.secondary.withAlpha(100),
                                    size: 50,
                                  ),
                                  Text(
                                    'Создать вашу первую форму!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppTheme.secondary.withAlpha(100),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        mainAxisExtent: 180,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        maxCrossAxisExtent: 200,
                      ),
                      itemCount: forms.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return FormCard(
                          form: forms[index],
                        );
                      },
                    );
                  },
                  error: (er, st) {
                    return Center(
                      child: Column(
                        crossAxisAlignment: .center,
                        mainAxisSize: .min,
                        children: [
                          SelectableText('Ошибка: $er'),
                          const SizedBox(
                            height: 8,
                          ),
                          FFButton(
                            isLoading: ref
                                .read(formControllerProvider)
                                .isLoading,
                            onPressed: () async =>
                                await ref.refresh(formControllerProvider),
                            text: 'Повторить',
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => Center(
                    child: FFLoading(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _formTitleController.dispose();
    super.dispose();
  }
}
