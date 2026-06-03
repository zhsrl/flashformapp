import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/data/controller/plan_usage_controller.dart';
import 'package:flashform_app/features/create_form/sections/editor/desktop/content_widgets/main_widgets/badge_block.dart';
import 'package:flashform_app/features/create_form/sections/editor/desktop/content_widgets/main_widgets/buttons_block.dart';
import 'package:flashform_app/features/create_form/sections/editor/desktop/content_widgets/main_widgets/description_block.dart';
import 'package:flashform_app/features/create_form/sections/editor/desktop/content_widgets/main_content_block.dart';
import 'package:flashform_app/features/create_form/sections/editor/desktop/content_widgets/main_widgets/offer_block.dart';
import 'package:flashform_app/features/widgets/ff_loading.dart';
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

    required this.uiControllers,
  });

  final dynamic formState;
  final VoidCallback onChanged;

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
            BuildButtonsBlock(
              formState: formState,
              controller: controller,
              uiControllers: uiControllers,
            ),
            BuildBadgeBlock(
              formState: formState,
              controller: controller,
              uiControllers: uiControllers,
            ),
            BuildMainContentBlock(
              contentUrl: formState.heroImageUrl,
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

            BuildMainContentBlock(
              contentUrl: formState.heroImageUrl,
            ),
          ],
        );
      },
      loading: () => Center(
        child: FFLoading(),
      ),
    );
  }
}
