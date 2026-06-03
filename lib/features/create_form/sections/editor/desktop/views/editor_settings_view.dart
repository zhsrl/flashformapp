import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/data/controller/plan_usage_controller.dart';
import 'package:flashform_app/features/create_form/sections/editor/desktop/content_widgets/footer_block.dart';
import 'package:flashform_app/features/create_form/sections/editor/desktop/widgets/settings_form_widget.dart';
import 'package:flashform_app/features/create_form/sections/editor/desktop/widgets/settings_slug_widget.dart';
import 'package:flashform_app/features/create_form/sections/editor/desktop/widgets/meta_pixel_integration_tile.dart';
import 'package:flashform_app/features/create_form/sections/editor/desktop/widgets/telegram_integration_tile.dart';
import 'package:flashform_app/features/create_form/sections/editor/desktop/widgets/yandex_metrika_integration_tile.dart';
import 'package:flashform_app/features/widgets/ff_loading.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../widgets/google_sheets_integration_tile.dart';

class EditorSettingsView extends ConsumerStatefulWidget {
  const EditorSettingsView({
    super.key,
    required this.formId,
  });

  final String formId;

  @override
  ConsumerState<EditorSettingsView> createState() =>
      _SettingsIntergrationViewDesktopState();
}

class _SettingsIntergrationViewDesktopState
    extends ConsumerState<EditorSettingsView> {
  @override
  Widget build(BuildContext context) {
    final uiControllers = ref.watch(formUIControllersProvider);

    final usageAsync = ref.watch(planUsageProvider);
    final formState = ref.read(createFormProvider);

    return usageAsync.when(
      data: (usage) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              BuildSlugChangeWidget(
                isAvailable: usage.canChangeSlug,
              ),
              Text(
                'Форма',
                style: TextStyle(
                  fontWeight: .w500,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SettingsFormWidget(),
              const SizedBox(
                height: 8,
              ),
              BuildFooterBlock(
                uiControllers: uiControllers,
                formState: formState,
                isAvailable: usage.hasFooter,
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                'Интеграции',
                style: TextStyle(
                  fontWeight: .w500,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              MetaPixelIntegrationTile(
                formId: widget.formId,
                isAvailable: usage.hasMetaPixelIntegration,
              ),
              YandexMetrikaIntegrationTile(
                formId: widget.formId,
                isAvailable: usage.hasYaMetrikaIntegration,
              ),
              TelegramIntegrationTile(
                formId: widget.formId,
                isAvailable: usage.hasTelegramBotIntegration,
              ),
              GoogleSheetsIntegrationTile(
                formId: widget.formId,
                isAvailable: usage.hasGoogleSheetsIntegration,
              ),
            ],
          ),
        );
      },
      error: (er, st) {
        return Text('Ошибка при загрузке интеграции: $er');
      },
      loading: () {
        return FFLoading();
      },
    );
  }
}
