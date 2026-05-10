import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:easy_localization/easy_localization.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        ],
      ),
    );
  }
}
