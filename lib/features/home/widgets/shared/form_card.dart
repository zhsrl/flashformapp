import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/model/form_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

enum FormPublishState { active, disabled }

class FormStateWidget extends StatelessWidget {
  const FormStateWidget({
    super.key,
    required this.state,
  });

  final FormPublishState state;

  @override
  Widget build(BuildContext context) {
    String text = state == FormPublishState.active ? 'active' : 'disabled';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
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
            fontSize: 12,
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
      child: AnimatedScale(
        scale: _isHover ? 0.95 : 1,
        duration: Duration(milliseconds: 50),
        child: GestureDetector(
          onTap: () {
            context.go('/create-form/${widget.form.id}');
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 230,
                      child: Text(
                        widget.form.name,

                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    FormStateWidget(
                      state: widget.form.isActive
                          ? FormPublishState.active
                          : FormPublishState.disabled,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '/${widget.form.slug}',
                      style: TextStyle(
                        color: AppTheme.secondary.withAlpha(100),
                      ),
                    ),
                    SizedBox(),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     SizedBox(),
                //     IconButton.outlined(
                //       onPressed: () {},
                //       icon: Row(
                //         children: [
                //           HeroIcon(HeroIcons.pencilSquare),
                //           const SizedBox(
                //             width: 4,
                //           ),
                //           Text(
                //             'Редактировать',
                //             style: TextStyle(
                //               fontSize: 12,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
