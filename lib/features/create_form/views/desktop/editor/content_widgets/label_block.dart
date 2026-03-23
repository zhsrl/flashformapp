import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/data/model/create_form_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

class BuildLabelSettingsBlock extends StatefulWidget {
  const BuildLabelSettingsBlock({
    super.key,
    required this.isAvailable,
    required this.formState,
    required this.uiControllers,
  });

  final CreateFormState formState;
  final FormUIControllers uiControllers;
  final bool isAvailable;
  @override
  State<BuildLabelSettingsBlock> createState() =>
      _BuildLabelSettingsBlockState();
}

class _BuildLabelSettingsBlockState extends State<BuildLabelSettingsBlock> {
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _isActive = widget.formState.hasLabel;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,

        border: Border.all(
          width: 1.5,
          color: Colors.transparent,
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Удалить Made on Flashform',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              if (!widget.isAvailable)
                Row(
                  children: [
                    HeroIcon(
                      HeroIcons.informationCircle,
                      size: 15,
                      color: Colors.deepOrangeAccent,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      'Доступно в Pro',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (!widget.isAvailable)
            SizedBox()
          else
            CupertinoSwitch(
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = !_isActive;
                  widget.uiControllers.updateHasLabel(value);
                });
              },
            ),
        ],
      ),
    );
  }
}
