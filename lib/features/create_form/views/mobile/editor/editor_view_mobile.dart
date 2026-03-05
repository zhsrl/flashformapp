import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/actions_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/description_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/main_content_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/offer_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/theme_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditorViewMobile extends ConsumerStatefulWidget {
  const EditorViewMobile({
    super.key,
    required this.onChanged,
    required this.focusNode,
  });

  final FocusNode focusNode;
  final VoidCallback onChanged;

  @override
  ConsumerState<EditorViewMobile> createState() => _EditorViewMobileState();
}

class _EditorViewMobileState extends ConsumerState<EditorViewMobile>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(createFormProvider);

    final controller = ref.read(createFormProvider.notifier);
    final uiControllers = ref.watch(formUIControllersProvider);

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          BuildThemeBlock(
            currentTheme: formState.theme,
            controller: controller,
            onChanged: widget.onChanged,
          ),
          BuildMainContentBlock(
            contentUrl: formState.heroImageUrl,
          ),
          BuildOfferBlock(
            onChanged: widget.onChanged,
            formState: formState,
            controller: controller,
            uiControllers: uiControllers,
          ),

          BuildDescriptionBlock(
            onChanged: widget.onChanged,
            formState: formState,
            controller: controller,
            uiControllers: uiControllers,
          ),
          BuildActionsBlock(
            currentType: formState.actionType,
            controller: controller,
            focusNode: widget.focusNode,
            formState: formState,
            uiControllers: uiControllers,
          ),
        ],
      ),
    );
  }
}
