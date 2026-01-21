import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EditorAppBar extends StatefulWidget implements PreferredSizeWidget {
  const EditorAppBar({
    super.key,
    this.formId = '',
    this.automaticallyImplyLeading,
    required this.onPublish,
  });

  final String? formId;
  final bool? automaticallyImplyLeading;
  final VoidCallback onPublish;

  @override
  State<EditorAppBar> createState() => _EditorAppBarState();

  @override
  Size get preferredSize => Size(double.infinity, 50);
}

class _EditorAppBarState extends State<EditorAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.background,
      automaticallyImplyLeading: widget.automaticallyImplyLeading ?? false,
      centerTitle: false,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/logo-short.svg',
            width: 40,
          ),
          const SizedBox(
            width: 10,
          ),

          Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppTheme.fourty,
              border: Border.all(
                width: 1,
                color: AppTheme.border,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Center(
              child: Text(
                // widget.formId!,
                'Новая форма',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),

      actionsPadding: EdgeInsets.only(right: 10),

      actions: [
        FFButton(
          onPressed: widget.onPublish,
          text: 'Опубликовать',
          secondTheme: true,
          marginBottom: 0,
        ),
        const SizedBox(
          width: 8,
        ),
        FFButton(
          onPressed: () {},
          text: 'Сохранить',
          marginBottom: 0,
        ),
        const SizedBox(
          width: 8,
        ),
      ],
    );
  }
}
