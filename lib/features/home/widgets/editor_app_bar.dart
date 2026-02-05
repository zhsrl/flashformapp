import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/app_validator.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:heroicons/heroicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EditorAppBar extends StatefulWidget implements PreferredSizeWidget {
  const EditorAppBar({
    super.key,
    this.formName = '',
    this.automaticallyImplyLeading,
    required this.onPublish,
    required this.onToggleEditMode,
    required this.onSaveFormName,
    this.isPublishing,
    this.onTapLink,

    required this.onBack,
    this.isFormNameChange,
  });

  final String? formName;
  final bool? automaticallyImplyLeading;
  final VoidCallback onPublish;
  final ValueChanged<bool> onToggleEditMode;
  final ValueChanged<String> onSaveFormName;
  final VoidCallback? onTapLink;
  final VoidCallback onBack;
  final bool? isPublishing;
  final bool? isFormNameChange;

  @override
  State<EditorAppBar> createState() => _EditorAppBarState();

  @override
  Size get preferredSize => Size(double.infinity, 50);
}

class _EditorAppBarState extends State<EditorAppBar> {
  bool _isHover = false;

  final _formNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _formNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,

      surfaceTintColor: AppTheme.background,
      automaticallyImplyLeading: widget.automaticallyImplyLeading ?? false,
      centerTitle: false,
      title: MouseRegion(
        onEnter: (event) => setState(() {
          _isHover = true;
        }),
        onExit: (event) => setState(() {
          _isHover = false;
        }),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/logo-short.svg',
              width: 40,
            ),
            const SizedBox(
              width: 10,
            ),
            if (widget.isFormNameChange == true)
              SizedBox(
                width: 300,
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    validator: AppValidators.validatorForEmpty,

                    controller: _formNameController,
                    decoration: InputDecoration(
                      hintText: 'Введите новое название',

                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          IconButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                widget.onSaveFormName.call(
                                  _formNameController.text,
                                );
                              }
                            },
                            icon: Icon(Icons.done),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                widget.onToggleEditMode(false);
                              });
                            },
                            icon: Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else ...[
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
              const SizedBox(
                width: 10,
              ),
              AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: _isHover ? 1 : 0,
                child: GestureDetector(
                  // onTap: widget.onChangeFormName,
                  onTap: () {
                    widget.onToggleEditMode(true);
                  },
                  child: HeroIcon(
                    HeroIcons.pencil,
                    style: HeroIconStyle.solid,
                    size: 15,
                    color: AppTheme.secondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),

      actionsPadding: EdgeInsets.only(right: 10),

      actions: [
        IconButton.outlined(
          onPressed: widget.onTapLink,
          icon: HeroIcon(HeroIcons.link),
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
