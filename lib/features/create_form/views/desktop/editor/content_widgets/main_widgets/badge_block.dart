import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart'
    show ResponsiveHelper;
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/data/model/create_form_state.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BuildBadgeBlock extends StatefulWidget {
  const BuildBadgeBlock({
    super.key,
    required this.controller,
    this.formState,
    required this.uiControllers,
  });

  final CreateFormState? formState;
  final CreateFormController controller;
  final FormUIControllers uiControllers;

  @override
  State<BuildBadgeBlock> createState() => _BuildBadgeBlockState();
}

class _BuildBadgeBlockState extends State<BuildBadgeBlock> {
  bool _hasBadge = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        border: Border.all(width: 1.5, color: AppTheme.border),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: .center,
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                'Тег',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              CupertinoSwitch(
                value: widget.formState?.hasBadge ?? false,
                activeTrackColor: Colors.green,

                onChanged: (value) {
                  setState(() {
                    widget.controller.updateHasBadge(value);
                  });
                },
              ),
            ],
          ),
          if (widget.formState?.hasBadge == true)
            FFTextField(
              maxLength: 25,
              controller: widget.uiControllers.badgeController,
            ),
        ],
      ),
    );
  }
}
