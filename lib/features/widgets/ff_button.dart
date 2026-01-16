import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FFButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;

  const FFButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
  });

  @override
  State<FFButton> createState() => _FFButtonState();
}

class _FFButtonState extends State<FFButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      // width: context.screenWidth,
      margin: EdgeInsets.only(
        bottom: 10,
      ),
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: AppTheme.secondary.withAlpha(200),

          elevation: 0,
          backgroundColor: AppTheme.secondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(15),
          ),
        ),
        child: widget.isLoading
            ? LoadingAnimationWidget.waveDots(
                color: AppTheme.primary,
                size: 24,
              )
            : Text(
                widget.text,
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
