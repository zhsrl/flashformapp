import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/model/subscription_plan.dart';
import 'package:flashform_app/data/model/user.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

class SubscriptionWidget extends StatelessWidget {
  const SubscriptionWidget({
    super.key,
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    final effectivePlan = user.isTrialActive ? SubscriptionPlan.go : user.plan;

    Color backgroundColor = effectivePlan == SubscriptionPlan.trial
        ? Colors.grey
        : effectivePlan == SubscriptionPlan.pro
        ? AppTheme.secondary
        : AppTheme.primary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: backgroundColor,
        border: Border.all(width: 1, color: AppTheme.border),
      ),
      child: Row(
        children: [
          if (effectivePlan == SubscriptionPlan.trial)
            HeroIcon(
              HeroIcons.star,
              color: Colors.white,
              style: HeroIconStyle.solid,
            ),
          if (effectivePlan == SubscriptionPlan.go)
            HeroIcon(
              HeroIcons.fire,
              color: AppTheme.secondary,
              style: HeroIconStyle.solid,
            ),
          if (effectivePlan == SubscriptionPlan.pro)
            HeroIcon(
              HeroIcons.bolt,
              color: AppTheme.primary,
              style: HeroIconStyle.solid,
            ),

          const SizedBox(
            width: 6,
          ),
          Text(
            effectivePlan == SubscriptionPlan.trial
                ? 'Нет тарифа'
                : effectivePlan == SubscriptionPlan.go
                ? 'Go'
                : 'Pro',
            style: TextStyle(
              color: effectivePlan == SubscriptionPlan.trial
                  ? Colors.white
                  : effectivePlan == SubscriptionPlan.pro
                  ? AppTheme.primary
                  : AppTheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
