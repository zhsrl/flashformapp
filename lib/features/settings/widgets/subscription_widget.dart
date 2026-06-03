import 'package:easy_localization/easy_localization.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/model/subscription_plan.dart';
import 'package:flashform_app/data/model/user.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

class ProfileSubscriptionWidget extends StatefulWidget {
  const ProfileSubscriptionWidget({
    super.key,
    required this.user,
    required this.onOpenSubscriptionPlans,
  });

  final User user;
  final VoidCallback onOpenSubscriptionPlans;

  @override
  State<ProfileSubscriptionWidget> createState() =>
      _ProfileSubscriptionWidgetState();
}

class _ProfileSubscriptionWidgetState extends State<ProfileSubscriptionWidget> {
  Widget getIcon(SubscriptionPlan plan) {
    return HeroIcon(
      plan == SubscriptionPlan.go
          ? HeroIcons.fire
          : plan == SubscriptionPlan.pro
          ? HeroIcons.bolt
          : HeroIcons.star,
      style: HeroIconStyle.solid,
      color: plan == SubscriptionPlan.trial
          ? Colors.white
          : plan == SubscriptionPlan.go
          ? AppTheme.secondary
          : AppTheme.primary,
      size: context.isMobile ? 24 : 30,
    );
  }

  Widget getPlanTitle(SubscriptionPlan plan) {
    return Text(
      plan == SubscriptionPlan.go
          ? 'Go'
          : plan == SubscriptionPlan.pro
          ? 'Pro'
          : 'Trial',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: plan == SubscriptionPlan.trial
            ? Colors.white
            : plan == SubscriptionPlan.go
            ? AppTheme.secondary
            : AppTheme.primary,
        fontSize: context.isMobile ? 24 : 32,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    if (user.isTrialAvailable) {
      return _TrialStatusCard(
        title: 'Активируй 7-дневный пробный период',
        subtitle: 'Получите доступ к тарифу Go на 7 дней бесплатно',
        buttonText: 'Активировать',
        onPressed: widget.onOpenSubscriptionPlans,
        backgroundColor: AppTheme.primary,
        textColor: Colors.white,
      );
    }

    if (user.isTrialActive) {
      final daysLeft = _daysLeft(user.trialExpiresAt!);

      return _TrialStatusCard(
        title: 'Пробный период активен',
        subtitle: 'Осталось $daysLeft ${_pluralDays(daysLeft)}',
        buttonText: 'Сменить тариф',
        onPressed: widget.onOpenSubscriptionPlans,
        backgroundColor: AppTheme.primary,
        textColor: Colors.black,
      );
    }

    if (user.isTrialUsed && !user.hasPaidAccess) {
      return _TrialStatusCard(
        title: 'Пробный период использован',
        subtitle: 'Выберите тариф, чтобы продолжить работу',
        buttonText: 'Выбрать тариф',
        onPressed: widget.onOpenSubscriptionPlans,
        backgroundColor: AppTheme.secondary,
        textColor: Colors.white,
      );
    }

    SubscriptionPlan? plan = user.plan;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: plan == SubscriptionPlan.trial
            ? Colors.deepOrange
            : plan == SubscriptionPlan.go
            ? AppTheme.primary
            : AppTheme.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                'Текущий план',
                style: TextStyle(
                  color: plan == SubscriptionPlan.trial
                      ? Colors.white
                      : plan == SubscriptionPlan.go
                      ? Colors.black
                      : Colors.white.withAlpha(50),
                ),
              ),
              if (plan != null)
                Row(
                  children: [
                    getIcon(plan),
                    const SizedBox(
                      width: 8,
                    ),
                    getPlanTitle(plan),
                  ],
                ),
              if (plan != SubscriptionPlan.trial)
                Text(
                  'Оплачено до ${DateFormat('dd.MM.yyyy').format(widget.user.planExpiresAt!)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: plan == SubscriptionPlan.trial
                        ? Colors.white
                        : plan == SubscriptionPlan.go
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
            ],
          ),
          FFButton(
            marginBottom: 0,
            onPressed: widget.onOpenSubscriptionPlans,
            text: 'Сменить тариф',
            secondTheme:
                plan == SubscriptionPlan.trial || plan == SubscriptionPlan.go
                ? false
                : true,
          ),
        ],
      ),
    );
  }

  int _daysLeft(DateTime expiresAt) {
    final diff = expiresAt.difference(DateTime.now());
    if (diff.isNegative) return 0;
    final days = (diff.inSeconds / Duration.secondsPerDay).ceil();
    return days > 0 ? days : 0;
  }

  String _pluralDays(int days) {
    final mod10 = days % 10;
    final mod100 = days % 100;
    if (mod10 == 1 && mod100 != 11) return 'день';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'дня';
    }
    return 'дней';
  }
}

class _TrialStatusCard extends StatelessWidget {
  const _TrialStatusCard({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
  });

  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: context.isMobile ? 18 : 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: FFButton(
              marginBottom: 0,
              onPressed: onPressed,
              text: buttonText,
              secondTheme: true,
            ),
          ),
        ],
      ),
    );
  }
}
