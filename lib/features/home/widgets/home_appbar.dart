import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/plan_usage_controller.dart';
import 'package:flashform_app/data/controller/user_controller.dart';
import 'package:flashform_app/data/model/subscription_plan.dart';
import 'package:flashform_app/features/home/widgets/subscription_widget.dart';
import 'package:flashform_app/features/settings/utils/subscription_plans_presenter.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    this.formId = '',
    this.automaticallyImplyLeading,
    this.isBack = false,
  });

  final String? formId;
  final bool? automaticallyImplyLeading;
  final bool? isBack;

  void _openSubscriptionPlans(
    BuildContext context,
  ) async {
    if (!context.mounted) return;
    await showSubscriptionPlansPresenter(context);
  }

  void showUsageDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,

      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final usageAsync = ref.watch(planUsageProvider);

            return AlertDialog(
              backgroundColor: AppTheme.secondary,
              title: Text(
                'Использование и лимиты',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              content: usageAsync.when(
                data: (usage) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: .spaceBetween,
                        crossAxisAlignment: .center,
                        children: [
                          Text(
                            'Формы',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          if (usage.plan != SubscriptionPlan.pro)
                            Text(
                              '${usage.formsUsed}/${usage.formsLimit}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            )
                          else
                            Text(
                              'безлимит',
                              style: TextStyle(
                                color: Colors.white.withAlpha(100),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      if (usage.plan != SubscriptionPlan.pro)
                        LinearProgressIndicator(
                          value: usage.formsProgress,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(400),
                          backgroundColor: AppTheme.tertiary,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            usage.isFormsLimitReached
                                ? Colors.red
                                : AppTheme.primary,
                          ),
                        )
                      else
                        LinearProgressIndicator(
                          value: 100,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(400),
                          backgroundColor: AppTheme.tertiary,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            usage.isFormsLimitReached
                                ? Colors.red
                                : AppTheme.primary,
                          ),
                        ),

                      if (usage.isFormsLimitReached) ...[
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: Colors.red,
                              size: 15,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            SizedBox(
                              width: 250,
                              child: Text(
                                'Достигнут лимит форм. Пожалуйста, удалите одну из форм или перейдите на другой тарифный план.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        FFButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _openSubscriptionPlans(context);
                          },
                          secondTheme: true,
                          text: 'Обновить план',
                        ),
                      ],

                      const SizedBox(
                        height: 16,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Лиды',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          if (usage.plan != SubscriptionPlan.pro)
                            Text(
                              '${usage.leadsUsed}/${usage.leadsLimit} в месяц',
                              style: TextStyle(
                                color: Colors.white.withAlpha(100),
                                fontSize: 12,
                              ),
                            )
                          else
                            Text(
                              'безлимит',
                              style: TextStyle(
                                color: Colors.white.withAlpha(100),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      if (usage.plan != SubscriptionPlan.pro)
                        LinearProgressIndicator(
                          value: usage.leadsProgress,
                          backgroundColor: AppTheme.tertiary,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(400),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            usage.isLeadsLimitReached
                                ? Colors.red
                                : AppTheme.primary,
                          ),
                        )
                      else
                        LinearProgressIndicator(
                          value: 100,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(400),
                          backgroundColor: AppTheme.tertiary,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            usage.isFormsLimitReached
                                ? Colors.red
                                : AppTheme.primary,
                          ),
                        ),

                      if (usage.isLeadsLimitReached) ...[
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: Colors.red,
                              size: 15,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            SizedBox(
                              width: 250,
                              child: Text(
                                'Лимит заявок на этот месяц исчерпан. Лимит будет автоматически продлен на следующий месяц.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  );
                },
                error: (er, st) =>
                    SizedBox(height: 100, child: Text('Ошибка: $er')),
                loading: () => SizedBox(
                  height: 100,
                  child: Center(
                    child: LoadingAnimationWidget.waveDots(
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.background,

      elevation: 0,

      centerTitle: false,
      title: Row(
        children: [
          if (isBack!)
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/tables');
                    }
                  },
                  icon: HeroIcon(HeroIcons.arrowLeft),
                ),
              ],
            ),
          if (context.isDesktop || context.isTablet)
            SvgPicture.asset(
              'assets/images/logo-light.svg',
              width: 130,
            ),
          if (context.isMobile)
            SvgPicture.asset(
              'assets/images/logo-short.svg',
              width: 40,
            ),
          const SizedBox(
            width: 10,
          ),
          if (formId == '')
            SizedBox(
              height: 40,
              child: Center(
                child: Text(
                  formId!,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
        ],
      ),

      actionsPadding: EdgeInsets.only(right: 10),

      actions: [
        Consumer(
          builder: (context, ref, _) {
            final usageAsync = ref.watch(planUsageProvider);

            return usageAsync.when(
              data: (usage) {
                if (usage.isLeadsLimitReached || usage.isFormsLimitReached) {
                  return IconButton.filledTonal(
                    onPressed: () => showUsageDialog(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    highlightColor: Colors.white.withAlpha(100),
                    color: Colors.red.shade100,
                    icon: Icon(Icons.warning_rounded),
                  );
                } else {
                  return SizedBox();
                }
              },
              error: (er, st) {
                return SizedBox();
              },
              loading: () => SizedBox(),
            );
          },
        ),
        const SizedBox(
          width: 10,
        ),
        Consumer(
          builder: (context, ref, _) {
            final userState = ref.watch(userControllerProvider);
            final user = userState.user;

            if (user == null) {
              return SizedBox();
            }

            return GestureDetector(
              onTap: () => showUsageDialog(context),
              child: SubscriptionWidget(plan: user.plan),
            );
          },
        ),
        const SizedBox(
          width: 10,
        ),

        GestureDetector(
          onTap: () {
            context.go('/settings');
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.fourty,
              border: Border.all(
                width: 1,
                color: AppTheme.border,
              ),
            ),
            child: HeroIcon(
              HeroIcons.user,
              color: AppTheme.secondary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size(double.infinity, 60);
}
