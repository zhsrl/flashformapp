import 'package:flashform_app/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

enum SubscriptionType {
  free,
  personal,
}

class SubscriptionWidget extends StatelessWidget {
  const SubscriptionWidget({
    super.key,
    required this.subscriptionType,
  });

  final SubscriptionType subscriptionType;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = subscriptionType == SubscriptionType.free
        ? AppTheme.fourty
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
          if (subscriptionType == SubscriptionType.personal)
            HeroIcon(
              HeroIcons.fire,
              color: AppTheme.secondary,
              style: HeroIconStyle.solid,
            ),
          if (subscriptionType == SubscriptionType.personal)
            const SizedBox(
              width: 6,
            ),
          Text(
            subscriptionType == SubscriptionType.free ? 'Free' : 'Personal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
