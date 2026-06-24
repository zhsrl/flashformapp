import 'package:flashform_app/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:toastification/toastification.dart';

enum SnackbarType {
  error,
  info,
  success,
}

void showSnackbar(
  BuildContext context, {
  required SnackbarType type,
  String message = '',
}) {
  final (toastType, iconColor, icon, background) = switch (type) {
    SnackbarType.error => (
      ToastificationType.error,
      Colors.white,
      HeroIcons.exclamationTriangle,
      Colors.red,
    ),
    SnackbarType.info => (
      ToastificationType.info,
      Colors.white,
      HeroIcons.questionMarkCircle,

      Colors.blueAccent,
    ),
    SnackbarType.success => (
      ToastificationType.success,
      AppTheme.secondary,
      HeroIcons.faceSmile,
      AppTheme.primary,
    ),
  };

  toastification.show(
    type: toastType,
    borderSide: BorderSide.none,
    alignment: Alignment.topCenter,
    style: ToastificationStyle.flat,
    backgroundColor: background,
    title: Text(
      message,
      style: TextStyle(fontWeight: FontWeight.w500, color: iconColor),
    ),
    icon: HeroIcon(
      icon,
      color: iconColor,
      size: 24,
    ),
    foregroundColor: Colors.white,
    animationDuration: const Duration(milliseconds: 500),
    autoCloseDuration: const Duration(milliseconds: 3000),
  );
}
