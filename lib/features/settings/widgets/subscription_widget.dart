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
      color: plan == SubscriptionPlan.spark
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
          : 'Spark',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: plan == SubscriptionPlan.spark
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
    SubscriptionPlan plan = widget.user.plan;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: plan == SubscriptionPlan.spark
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
                  color: plan == SubscriptionPlan.spark
                      ? Colors.white
                      : plan == SubscriptionPlan.go
                      ? Colors.black
                      : Colors.white.withAlpha(50),
                ),
              ),

              Row(
                children: [
                  getIcon(plan),
                  const SizedBox(
                    width: 8,
                  ),
                  getPlanTitle(plan),
                ],
              ),
              if (plan != SubscriptionPlan.spark)
                Text(
                  'Оплачено до ${DateFormat('dd.MM.yyyy').format(widget.user.planExpiresAt!)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: plan == SubscriptionPlan.spark
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
                plan == SubscriptionPlan.spark || plan == SubscriptionPlan.go
                ? false
                : true,
          ),
        ],
      ),
    );
  }
}
