import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

class EditorAppBar extends StatefulWidget implements PreferredSizeWidget {
  const EditorAppBar({
    super.key,
    this.formName = '',
    this.automaticallyImplyLeading,
    required this.onPublish,

    this.isPublishing,

    required this.onBack,
  });

  final String? formName;
  final bool? automaticallyImplyLeading;
  final VoidCallback onPublish;

  final VoidCallback onBack;
  final bool? isPublishing;

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
      elevation: 0,

      surfaceTintColor: AppTheme.background,
      automaticallyImplyLeading: widget.automaticallyImplyLeading ?? false,
      centerTitle: false,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // IconButton.outlined(
          //   onPressed: widget.onBack,
          //   style: IconButton.styleFrom(
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadiusGeometry.circular(10),
          //     ),
          //   ),

          //   icon: HeroIcon(
          //     HeroIcons.arrowLeft,
          //   ),
          // ),
          // const SizedBox(
          //   width: 10,
          // ),
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
                widget.formName ?? '',

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
        IconButton.outlined(
          onPressed: () {},
          icon: Icon(Icons.link),
        ),
        const SizedBox(
          width: 8,
        ),
        SizedBox(
          width: 170,
          child: FFButton(
            onPressed: widget.onPublish,
            isLoading: widget.isPublishing ?? false,
            text: 'Опубликовать',
            secondTheme: true,
            marginBottom: 0,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        FFButton(
          onPressed: widget.onBack,

          text: 'Закрыть',
          secondTheme: false,
          marginBottom: 0,
        ),
      ],
    );
  }
}
