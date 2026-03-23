import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/data/controller/plan_usage_controller.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/actions_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/description_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/footer_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/label_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/main_content_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/offer_block.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/content_widgets/theme_block.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EditorContentView extends ConsumerWidget {
  const EditorContentView({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.formState,
    required this.onChanged,
    required this.labelOnChanged,
    required this.ref,
    required this.uiControllers,
  });

  final WidgetRef ref;
  final dynamic formState;
  final VoidCallback onChanged;
  final ValueChanged<bool> labelOnChanged;
  final CreateFormController controller;
  final FormUIControllers uiControllers;
  final FocusNode focusNode;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final usageAsync = ref.watch(planUsageProvider);

    return usageAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      skipError: true,
      data: (usage) {
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
        if (context.mounted) {
          showSnackbar(
            context,
            type: SnackbarType.error,
            message: 'Ошибка: $er',
          );
        }
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
    );
  }
}
