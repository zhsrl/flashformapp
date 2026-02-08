import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/actions_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/description_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/main_content_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/offer_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/theme_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditorContentView extends StatelessWidget {
  const EditorContentView({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.formState,
    required this.onChanged,
    required this.ref,
    required this.uiControllers,
  });

  final WidgetRef ref;
  final dynamic formState;
  final VoidCallback onChanged;
  final CreateFormController controller;
  final FormUIControllers uiControllers;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BuildThemeBlock(
          currentTheme: formState.theme,
          controller: controller,
          onChanged: onChanged,
        ),
        BuildMainContentBlock(
          contentUrl: formState.heroImageUrl,
        ),
        BuildOfferBlock(
          onChanged: onChanged,
          formState: formState,
          controller: controller,
          uiControllers: uiControllers,
        ),

        BuildDescriptionBlock(
          onChanged: onChanged,
          formState: formState,
          controller: controller,
          uiControllers: uiControllers,
        ),
        BuildActionsBlock(
          currentType: formState.actionType,
          controller: controller,
          focusNode: focusNode,
          formState: formState,
          uiControllers: uiControllers,
        ),
      ],
    );
  }
}
