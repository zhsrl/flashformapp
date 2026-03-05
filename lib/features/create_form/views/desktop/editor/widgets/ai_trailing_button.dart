import 'package:flashform_app/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

class AiTrailingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const AiTrailingButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<AiTrailingButton> createState() => _AiTrailingButtonState();
}

class _AiTrailingButtonState extends State<AiTrailingButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'AI помощник',
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              child: AnimatedScale(
                scale: _isHovered && !widget.isLoading ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      : Text(
                          '✨',
                          style: TextStyle(
                            fontSize: 18,
                            color: _isHovered
                                ? Theme.of(context).primaryColor
                                : Colors.grey[600],
                          ),
                        ),
                  // : HeroIcon(
                  //     HeroIcons.sparkles,
                  //     style: HeroIconStyle.solid,
                  //     color: Colors.deepOrange,
                  //   ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
