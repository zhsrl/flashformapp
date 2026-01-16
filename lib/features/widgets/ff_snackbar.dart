import 'package:flashform_app/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

enum SnackbarType {
  error,
  info,
  success,
}

void showSnackbar(
  BuildContext context, {
  required SnackbarType type,
  String message = '',
}) async {
  CustomSnackBar snackbar = switch (type) {
    SnackbarType.error => CustomSnackBar.error(
      message: message,
      backgroundColor: AppTheme.secondary,
      textStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: AppTheme.primary,
      ),
      icon: HeroIcon(
        HeroIcons.exclamationTriangle,
        color: AppTheme.primary.withAlpha(30),
        size: 120,
      ),
    ),
    SnackbarType.info => CustomSnackBar.info(
      message: message,
      backgroundColor: AppTheme.secondary,
      textStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: AppTheme.primary,
      ),
      icon: HeroIcon(
        HeroIcons.questionMarkCircle,
        color: AppTheme.primary.withAlpha(30),
        size: 120,
      ),
    ),
    SnackbarType.success => CustomSnackBar.success(
      message: message,
      backgroundColor: AppTheme.primary,
      textStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: AppTheme.secondary,
      ),
      icon: HeroIcon(
        HeroIcons.faceSmile,
        color: AppTheme.secondary.withAlpha(30),
        size: 120,
      ),
    ),
  };

  showTopSnackBar(
    Overlay.of(context),
    Align(
      alignment: Alignment.topCenter,

      child: SizedBox(width: 350, height: 60, child: snackbar),
    ),

    animationDuration: Duration(milliseconds: 600),
    reverseAnimationDuration: Duration(milliseconds: 600),
    displayDuration: Duration(milliseconds: 2500),
  );
}
