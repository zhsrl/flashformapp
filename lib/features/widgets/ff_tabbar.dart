import 'package:flashform_app/core/app_theme.dart';
import 'package:flutter/material.dart';

class FFTabBar extends StatefulWidget {
  const FFTabBar({
    super.key,
    required this.tabs,
    this.onTap,
    this.isSecondTheme,
    this.controller,
    this.width,
  });

  final List<Widget> tabs;
  final Function(int)? onTap;
  final bool? isSecondTheme;
  final TabController? controller;
  final double? width;

  @override
  State<FFTabBar> createState() => _FFTabBarState();
}

class _FFTabBarState extends State<FFTabBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: widget.width,

      decoration: BoxDecoration(
        color: AppTheme.fourty,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: widget.controller,
        tabs: widget.tabs,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w800,

          fontFamily: 'GoogleSans',
        ),

        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: widget.isSecondTheme == true
            ? AppTheme.primary
            : AppTheme.secondary,
        unselectedLabelColor: AppTheme.secondary.withAlpha(50),
        onTap: widget.onTap,
        indicator: BoxDecoration(
          color: widget.isSecondTheme == true
              ? AppTheme.secondary
              : AppTheme.primary,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
