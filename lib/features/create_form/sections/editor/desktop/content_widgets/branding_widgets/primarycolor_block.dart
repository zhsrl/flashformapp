import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/model/create_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class BuildPrimaryColorBrandingBlock extends StatefulWidget {
  const BuildPrimaryColorBrandingBlock({
    super.key,
    required this.controller,
    required this.formState,
  });

  final CreateFormState formState;
  final CreateFormController controller;

  @override
  State<BuildPrimaryColorBrandingBlock> createState() =>
      _BuildPrimaryColorBrandingBlockState();
}

class _BuildPrimaryColorBrandingBlockState
    extends State<BuildPrimaryColorBrandingBlock> {
  final List<Color> _suggestedColor = [
    Colors.red,
    Colors.blue,
    Colors.deepOrange,
    Colors.lightGreen,
    Colors.teal,
    Colors.pinkAccent,
    Colors.blueAccent,
    Colors.lightGreen,
    Colors.lightBlueAccent,
  ];
  void showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              content: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  ColorPicker(
                    portraitOnly: true,
                    labelTypes: [],

                    enableAlpha: false,
                    pickerAreaBorderRadius: .circular(20),
                    pickerColor: widget.formState.primaryColor!,
                    onColorChanged: widget.controller.updatePrimaryColor,
                  ),
                  Text(
                    'Рекомендации',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Wrap(
                    children: _suggestedColor.map((color) {
                      return GestureDetector(
                        onTap: () => setDialogState(() {
                          if (!mounted) return;
                          widget.controller.updatePrimaryColor(color);
                        }),
                        child: Container(
                          width: 30,
                          height: 30,
                          margin: .only(right: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = widget.formState.primaryColor!;
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
      width: context.screenWidth,

      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(
            'Основной цвет',
            style: TextStyle(
              fontWeight: .w500,
            ),
          ),
          _buildColorPickerWidget(
            color: primaryColor,
            colorCode: primaryColor.toHex().toUpperCase(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPickerWidget({
    String colorCode = 'FFFFFF',
    Color color = Colors.red,
  }) {
    return GestureDetector(
      onTap: () => showColorPickerDialog(),
      child: Container(
        decoration: BoxDecoration(
          border: .all(width: 1, color: AppTheme.border),
          borderRadius: .circular(15),
        ),
        margin: .only(top: 16),
        padding: .symmetric(
          vertical: 8,
          horizontal: 12,
        ),
        child: Row(
          crossAxisAlignment: .center,
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(
              colorCode,
              style: TextStyle(fontSize: 16),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
