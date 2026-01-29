import 'package:flashform_app/core/app_theme.dart';
import 'package:flutter/material.dart';

class FFTabBar extends StatefulWidget {
  const FFTabBar({
    super.key,
    required this.tabs,
    this.onTap,
  });

  final List<Widget> tabs;
  final Function(int)? onTap;

  @override
  State<FFTabBar> createState() => _FFTabBarState();
}

class _FFTabBarState extends State<FFTabBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,

      decoration: BoxDecoration(
        color: AppTheme.fourty,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        tabs: widget.tabs,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w800,

          fontFamily: 'GoogleSans',
        ),

        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppTheme.secondary,
        unselectedLabelColor: AppTheme.secondary.withAlpha(50),
        onTap: widget.onTap,
        indicator: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
