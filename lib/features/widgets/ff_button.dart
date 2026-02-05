import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FFButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;
  final bool secondTheme;
  final double marginLeft;
  final double marginRight;
  final double marginTop;
  final double marginBottom;

  const FFButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.secondTheme = false,
    this.marginTop = 0,
    this.marginBottom = 10,
    this.marginLeft = 0,
    this.marginRight = 0,
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
        bottom: widget.marginBottom,
        top: widget.marginTop,
        left: widget.marginLeft,
        right: widget.marginRight,
      ),
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: AppTheme.secondary.withAlpha(200),

          elevation: 0,
          backgroundColor: widget.secondTheme
              ? AppTheme.primary
              : AppTheme.secondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(300),
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
                  color: widget.secondTheme
                      ? AppTheme.secondary
                      : AppTheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
