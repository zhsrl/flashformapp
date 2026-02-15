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
  final (toastType, iconColor, icon) = switch (type) {
    SnackbarType.error => (
      ToastificationType.error,
      Colors.red,
      HeroIcons.exclamationTriangle,
    ),
    SnackbarType.info => (
      ToastificationType.info,
      Colors.blueAccent,
      HeroIcons.questionMarkCircle,
    ),
    SnackbarType.success => (
      ToastificationType.success,
      AppTheme.primary,
      HeroIcons.faceSmile,
    ),
  };

  toastification.show(
    type: toastType,
    alignment: Alignment.bottomRight,
    style: ToastificationStyle.flat,
    backgroundColor: AppTheme.secondary,
    title: Text(
      message,
      style: TextStyle(
        fontWeight: FontWeight.w500,

        color: Colors.white,
      ),
    ),
    icon: HeroIcon(
      icon,
      color: iconColor,
      size: 24,
    ),
    foregroundColor: Colors.white,
    autoCloseDuration: const Duration(milliseconds: 3000),
  );
}
