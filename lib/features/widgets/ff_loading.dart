import 'package:flashform_app/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FFLoading extends StatelessWidget {
  const FFLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.fourRotatingDots(
      color: AppTheme.secondary,
      size: 30,
    );
  }
}
