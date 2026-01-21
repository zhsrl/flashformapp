import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/features/home/widgets/subscription_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:heroicons/heroicons.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    this.formId = '',
    this.automaticallyImplyLeading,
  });

  final String? formId;
  final bool? automaticallyImplyLeading;

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => Size(double.infinity, 60);
}

class _HomeAppBarState extends State<HomeAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.background,
      automaticallyImplyLeading: widget.automaticallyImplyLeading ?? false,
      centerTitle: false,
      title: Row(
        children: [
          SvgPicture.asset(
            'assets/images/logo-light.svg',
            width: 130,
          ),
          const SizedBox(
            width: 10,
          ),
          if (widget.formId == '')
            Container(
              height: 40,
              child: Center(
                child: Text(
                  widget.formId!,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
        ],
      ),

      actionsPadding: EdgeInsets.only(right: 10),

      actions: [
        SubscriptionWidget(
          subscriptionType: SubscriptionType.personal,
        ),
        const SizedBox(
          width: 10,
        ),

        Container(
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
      ],
    );
  }
}
