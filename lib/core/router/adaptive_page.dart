import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Page adaptivePage({
  required BuildContext context,
  required Widget child,
  String? name,
}) {
  final isDesktop = context.isDesktop;

  if (isDesktop) {
    return NoTransitionPage(
      child: child,
      name: name,
    );
  }

  return CustomTransitionPage(
    child: child,
    name: name,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      final tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
