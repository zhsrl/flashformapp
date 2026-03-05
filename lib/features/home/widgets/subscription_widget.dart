import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/model/subscription_plan.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

class SubscriptionWidget extends StatelessWidget {
  const SubscriptionWidget({
    super.key,
    required this.plan,
  });

  final SubscriptionPlan plan;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = plan == SubscriptionPlan.spark
        ? Colors.deepOrange
        : plan == SubscriptionPlan.pro
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
          if (plan == SubscriptionPlan.spark)
            HeroIcon(
              HeroIcons.star,
              color: Colors.white,
              style: HeroIconStyle.solid,
            ),
          if (plan == SubscriptionPlan.go)
            HeroIcon(
              HeroIcons.fire,
              color: AppTheme.secondary,
              style: HeroIconStyle.solid,
            ),
          if (plan == SubscriptionPlan.pro)
            HeroIcon(
              HeroIcons.bolt,
              color: AppTheme.primary,
              style: HeroIconStyle.solid,
            ),

          const SizedBox(
            width: 6,
          ),
          Text(
            plan == SubscriptionPlan.spark
                ? 'Spark'
                : plan == SubscriptionPlan.go
                ? 'Go'
                : 'Pro',
            style: TextStyle(
              color: plan == SubscriptionPlan.spark
                  ? Colors.white
                  : plan == SubscriptionPlan.pro
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
