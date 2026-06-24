import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Page adaptivePage({
  required BuildContext context,
  required Widget child,
  String? name,
  LocalKey? key,
}) {
  final isDesktop = context.isDesktop;

  if (isDesktop) {
    return NoTransitionPage(
      child: child,
      name: name,
      key: key,
    );
  }

  return CustomTransitionPage(
    child: child,
    name: name,
    key: key,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const curve = Curves.easeInOut;

      // Меняем Offset на double для прозрачности (от 0.0 - невидимый, до 1.0 - полностью видимый)
      final tween = Tween<double>(begin: 0.0, end: 1.0).chain(
        CurveTween(curve: curve),
      );

      // Используем FadeTransition вместо SlideTransition
      return FadeTransition(
        opacity: animation.drive(tween),
        child: child,
      );
    },
  );
}
