import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';

import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/data/controller/integration_controller.dart';
import 'package:flashform_app/data/repository/form_repository.dart';

import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:heroicons/heroicons.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class EditorIntergrationView extends ConsumerStatefulWidget {
  const EditorIntergrationView({
    super.key,
    required this.formId,
  });

  final String formId;

  @override
  ConsumerState<EditorIntergrationView> createState() =>
      _SettingsIntergrationViewDesktopState();
}

class _SettingsIntergrationViewDesktopState
    extends ConsumerState<EditorIntergrationView> {
  bool _isMetaPixelEnabled = false;
  bool _isYandexMetrikaEnabled = false;

  Future<void> _onAddMetaPixel() async {
    final currentFormId = ref.read(currentFormIdProvider);
    await ref.watch(metaPixelControllerProvider.notifier).save(currentFormId);
  }

  Future<void> _onAddYandexMetrikaId() async {
    final currentFormId = ref.read(currentFormIdProvider);
    await ref
        .watch(yandexMetrikaControllerProvider.notifier)
        .save(currentFormId);
  }

  @override
  Widget build(BuildContext context) {
    final uiControllers = ref.watch(formUIControllersProvider);

    return Column(
      children: [
        _buildMetaPixelIntegration(
          isEnabled: uiControllers.metaPixelIdController.text != ''
              ? true
              : _isMetaPixelEnabled,
          controller: uiControllers.metaPixelIdController,
          onTap: () async {
            await _onAddMetaPixel().then((a) {
              if (context.mounted) {
                showSnackbar(
                  context,
                  type: SnackbarType.info,
                  message: 'Meta Pixel успешно добавлен',
                );
              }
            });
          },
          onChanged: (value) => setState(() {
            _isMetaPixelEnabled = value;
          }),
        ),
        _buildYandexMetrikaIntegration(
          isEnabled: uiControllers.yandexMetrikaIdController.text != ''
              ? true
              : _isYandexMetrikaEnabled,
          controller: uiControllers.yandexMetrikaIdController,
          onTap: () async {
            await _onAddYandexMetrikaId().then((a) {
              if (context.mounted) {
                showSnackbar(
                  context,
                  type: SnackbarType.info,
                  message: 'Yandex Metrika ID успешно добавлен',
                );
              }
            });
          },
          onChanged: (value) => setState(() {
            _isYandexMetrikaEnabled = value;
          }),
        ),
      ],
    );
  }

  Widget _buildMetaPixelIntegration({
    bool isEnabled = true,
    ValueChanged<bool>? onChanged,
    VoidCallback? onTap,
    TextEditingController? controller,
  }) {
    return Container(
      width: context.screenWidth,
      decoration: _buildBlocksDecotration(),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Center(
                      child: SvgPicture.asset('images/meta.svg'),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Meta Pixel',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              CupertinoSwitch(
                value: isEnabled,
                thumbColor: AppTheme.secondary,
                inactiveThumbColor: AppTheme.border,
                activeTrackColor: AppTheme.primary,
                onChanged: onChanged,
              ),
            ],
          ),

          if (isEnabled) ...[
            const SizedBox(
              height: 8,
            ),
            FFTextField(
              maxLines: 1,
              prefixIcon: HeroIcon(HeroIcons.codeBracket),
              hintText: 'Введите Pixel Id',
              controller: controller,
              onChanged: (value) {
                ref.read(createFormProvider.notifier).updateMetaPixelId(value);
                ref.read(createFormProvider.notifier).markAsChanged();
              },
            ),
            SizedBox(
              width: context.screenWidth,
              child: FFButton(
                onPressed: onTap ?? () {},

                text: 'Сохранить',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildYandexMetrikaIntegration({
    bool isEnabled = true,
    ValueChanged<bool>? onChanged,
    VoidCallback? onTap,
    TextEditingController? controller,
  }) {
    return Container(
      width: context.screenWidth,
      decoration: _buildBlocksDecotration(),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Center(
                      child: SvgPicture.asset('images/metrika.svg'),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Яндекс Метрика',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              CupertinoSwitch(
                value: isEnabled,

                thumbColor: AppTheme.secondary,
                inactiveThumbColor: AppTheme.border,
                activeTrackColor: AppTheme.primary,
                onChanged: onChanged,
              ),
            ],
          ),

          if (isEnabled) ...[
            const SizedBox(
              height: 8,
            ),
            FFTextField(
              maxLines: 1,
              prefixIcon: HeroIcon(HeroIcons.codeBracket),
              hintText: 'Введите Metrika Id',
              onChanged: (value) {
                ref
                    .read(createFormProvider.notifier)
                    .updateYandexMetrikaId(value);
                ref.read(createFormProvider.notifier).markAsChanged();
              },
              controller: controller,
            ),
            SizedBox(
              width: context.screenWidth,
              child: FFButton(
                onPressed: onTap ?? () {},

                text: 'Сохранить',
              ),
            ),
          ],
        ],
      ),
    );
  }

  BoxDecoration _buildBlocksDecotration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      color: AppTheme.background,
      border: Border.all(width: 1.5, color: AppTheme.border),
    );
  }
}
