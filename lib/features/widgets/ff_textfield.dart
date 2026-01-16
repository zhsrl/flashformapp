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
    this.validator,
    this.formatters,
  });

  final String? hintText;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final void Function(String?)? onChanged;
  final TextInputType? keyboardType;
  final bool? isPassword;
  final double? bottomPadding;
  final List<TextInputFormatter>? formatters;

  final bool? enabled;
  final String? Function(String? value)? validator;

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
    return Container(
      // height: 55,
      padding: EdgeInsets.only(bottom: widget.bottomPadding ?? 0),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        obscureText: widget.isPassword == false ? false : _obscured,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        onChanged: widget.onChanged,
        enabled: widget.enabled,
        validator: widget.validator,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        maxLines: widget.isPassword == true ? 1 : null,

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

          fillColor: AppTheme.fourty,
          hintStyle: TextStyle(
            color: AppTheme.tertiary,
            fontWeight: FontWeight.w500,
          ),

          hintText: widget.hintText,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
    );
  }
}
