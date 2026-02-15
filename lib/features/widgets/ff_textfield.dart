import 'package:flashform_app/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heroicons/heroicons.dart';

class FFTextField extends StatefulWidget {
  const FFTextField({
    super.key,
    this.hintText,
    this.controller,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.keyboardType,
    this.isPassword = false,
    this.enabled,
    this.bottomPadding,
    this.bottomMargin,
    this.validator,
    this.formatters,
    this.height,
    this.title,
    this.focusNode,
    this.maxLength,
    this.maxLines,
    this.fillColor,
  });

  final String? hintText;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool? isPassword;
  final double? bottomPadding;
  final double? bottomMargin;
  final List<TextInputFormatter>? formatters;
  final double? height;
  final bool? enabled;
  final String? title;
  final Color? fillColor;
  final String? Function(String? value)? validator;
  final int? maxLength;
  final int? maxLines;
  final FocusNode? focusNode;

  @override
  State<FFTextField> createState() => _FFTextFieldState();
}

class _FFTextFieldState extends State<FFTextField> {
  bool _obscured = true;

  _togglePassword() {
    setState(() {
      _obscured = !_obscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title ?? '',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
        ],
        Container(
          padding: EdgeInsets.only(bottom: widget.bottomPadding ?? 0),
          margin: EdgeInsets.only(bottom: widget.bottomMargin ?? 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: TextFormField(
            obscureText: widget.isPassword == false ? false : _obscured,
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            focusNode: widget.focusNode,
            onChanged: widget.onChanged,
            enabled: widget.enabled,
            validator: widget.validator,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              height: widget.height,
            ),
            maxLines: widget.isPassword == true ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.formatters,
            cursorColor: AppTheme.secondary,
            decoration: InputDecoration(
              hintMaxLines: 1,
              suffixIcon: widget.isPassword == true
                  ? GestureDetector(
                      onTap: _togglePassword,
                      child: !_obscured
                          ? HeroIcon(
                              HeroIcons.eye,
                              // color: AppColor.color79,
                            )
                          : HeroIcon(
                              HeroIcons.eyeSlash,
                              // color: AppColor.color79,
                            ),
                    )
                  : widget.suffixIcon,
              prefixIcon: widget.prefixIcon,
              prefixIconColor: AppTheme.tertiary,
              filled: true,

              fillColor: widget.fillColor ?? Colors.white,
              hintStyle: TextStyle(
                color: AppTheme.tertiary,
                fontWeight: FontWeight.w500,
              ),

              hintText: widget.hintText,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(15),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(15),
              ),

              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(15),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppTheme.border,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
