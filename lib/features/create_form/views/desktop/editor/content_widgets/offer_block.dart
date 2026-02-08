import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuildOfferBlock extends ConsumerWidget {
  const BuildOfferBlock({
    super.key,
    required this.onChanged,
    required this.formState,
    required this.controller,
    required this.uiControllers,
  });

  final VoidCallback onChanged;
  final dynamic formState;
  final CreateFormController controller;
  final FormUIControllers uiControllers;

  Widget _buildSizeSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(width: 1.5, color: AppTheme.border),
              ),
              padding: const EdgeInsets.all(8),
              child: Text(
                '${value.toInt()} px',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          thumbColor: AppTheme.secondary,
          label: value.toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: context.screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: AppTheme.background,
        border: Border.all(width: 1.5, color: AppTheme.border),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Заголовок',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          FFTextField(
            hintText: 'Напишите заголовок',
            onChanged: (value) {
              onChanged();
              controller.updateTitle(value);
              ref.read(createFormProvider.notifier).markAsChanged();
            },
            controller: uiControllers.titleController,
          ),
          const SizedBox(width: 8),
          _buildSizeSlider(
            label: 'Размер текста',
            value: formState.titleFontSize,
            max: 42,
            min: 24,
            onChanged: (val) => {
              controller.updateTitleFontSize(val),
              ref.read(createFormProvider.notifier).markAsChanged(),
            },
          ),
        ],
      ),
    );
  }
}
