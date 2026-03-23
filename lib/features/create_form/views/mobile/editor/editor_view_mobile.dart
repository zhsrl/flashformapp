import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/data/controller/plan_usage_controller.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/actions_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/description_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/footer_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/label_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/main_content_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/offer_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/theme_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
    final usageAsync = ref.watch(planUsageProvider);
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
          usageAsync.when(
            data: (usage) {
              return Column(
                children: [
                  BuildLabelSettingsBlock(
                    isAvailable: usage.canRemoveBranding,
                    formState: formState,
                    uiControllers: uiControllers,
                  ),
                  BuildFooterBlock(
                    uiControllers: uiControllers,
                    formState: formState,
                    isAvailable: usage.hasFooter,
                  ),
                ],
              );
            },
            error: (er, st) {
              return Column(
                children: [
                  BuildLabelSettingsBlock(
                    isAvailable: false,
                    formState: formState,
                    uiControllers: uiControllers,
                  ),
                  BuildFooterBlock(
                    uiControllers: uiControllers,
                    formState: formState,
                    isAvailable: false,
                  ),
                ],
              );
            },
            loading: () => Center(
              child: LoadingAnimationWidget.waveDots(
                color: AppTheme.secondary,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
