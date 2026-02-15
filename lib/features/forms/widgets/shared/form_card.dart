import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/model/form.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum FormPublishState { active, disabled }

class FormStateWidget extends StatelessWidget {
  const FormStateWidget({
    super.key,
    required this.state,
  });

  final FormPublishState state;

  @override
  Widget build(BuildContext context) {
    String text = state == FormPublishState.active ? 'Активна' : 'Отключена';
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      // width: 90,
      decoration: BoxDecoration(
        color: state == FormPublishState.active
            ? AppTheme.primary
            : AppTheme.tertiary,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.secondary,
          ),
        ),
      ),
    );
  }
}

class FormCard extends StatefulWidget {
  const FormCard({
    super.key,
    required this.form,
  });

  final FormModel form;

  @override
  State<FormCard> createState() => _FormCardState();
}

class _FormCardState extends State<FormCard> {
  bool _isHover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          _isHover = true;
        });
      },
      onExit: (event) {
        setState(() {
          _isHover = false;
        });
      },
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isHover ? 0.98 : 1,
        duration: Duration(milliseconds: 100),
        child: GestureDetector(
          onTap: () {
            context.go('/create-form/${widget.form.id}');
          },

          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                if (_isHover)
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IntrinsicWidth(
                      child: FormStateWidget(
                        state: widget.form.isActive
                            ? FormPublishState.active
                            : FormPublishState.disabled,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            widget.form.name,

                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(),
                      ],
                    ),
                  ],
                ),

                RichText(
                  text: TextSpan(
                    text: 'fform.me/',
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'GoogleSans',
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: widget.form.slug,

                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'GoogleSans',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
