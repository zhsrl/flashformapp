import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/data/controller/plan_usage_controller.dart';
import 'package:flashform_app/data/model/create_form_state.dart';
import 'package:flashform_app/features/create_form/sections/editor/desktop/content_widgets/branding_widgets/logo_block.dart';
import 'package:flashform_app/features/create_form/sections/editor/desktop/content_widgets/branding_widgets/primarycolor_block.dart';
import 'package:flashform_app/features/create_form/sections/editor/desktop/content_widgets/branding_widgets/theme_block.dart';
import 'package:flashform_app/features/create_form/sections/editor/desktop/content_widgets/label_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EditorBrandingView extends ConsumerWidget {
  const EditorBrandingView({
    super.key,
    required this.formState,

    required this.controller,
  });

  final CreateFormState formState;

  final CreateFormController controller;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageAsync = ref.watch(planUsageProvider);
    return usageAsync.when(
      data: (usage) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: .min,

            children: [
              BuildThemeBlock(
                controller: controller,
                formState: formState,
              ),
              BuildPrimaryColorBrandingBlock(
                controller: controller,
                formState: formState,
              ),
              BuildLogoBlock(
                formState: formState,
              ),
              BuildLabelSettingsBlock(
                isAvailable: true,
                formState: formState,
                controller: controller,
              ),
            ],
          ),
        );
      },
      error: (er, st) {
        return SizedBox();
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
