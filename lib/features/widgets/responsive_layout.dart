import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) return desktop;
    if (context.isTablet) return tablet ?? desktop;

    return mobile;
  }
}
