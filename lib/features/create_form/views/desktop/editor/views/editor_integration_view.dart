import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/forms_controller.dart';

import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/data/controller/integration_controller.dart';
import 'package:flashform_app/data/repository/form_repository.dart';

import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:heroicons/heroicons.dart';

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

  Future<void> _deleteMetaPixelId() async {
    final formState = ref.read(createFormProvider);

    final uiControllers = ref.read(formUIControllersProvider);

    final form = await ref
        .watch(formControllerProvider.notifier)
        .fetchForm(widget.formId);
    if (formState.metaPixelId.isNotEmpty) {
      _showDeleteDialog(
        'Meta Pixel',
        onCancel: () => setState(() {
          setState(() {
            _isMetaPixelEnabled = true;
          });
          Navigator.pop(context);
        }),

        onConfirm: () async {
          if ((form.data?['settings']['meta-pixel-id'] as String).isNotEmpty) {
            debugPrint('confirmed');
            await ref
                .watch(metaPixelControllerProvider.notifier)
                .delete(widget.formId);
            setState(() {
              uiControllers.metaPixelIdController.text = '';
            });
          }
          if (mounted) {
            Navigator.pop(context);
          }
        },
      );
    }
  }

  Future<void> _deleteYandexMetrikaId() async {
    final formState = ref.read(createFormProvider);

    final uiControllers = ref.read(formUIControllersProvider);

    if (formState.yandexMetrikaId.isNotEmpty) {
      _showDeleteDialog(
        'Яндекс Метрика',
        onCancel: () => setState(() {
          setState(() {
            _isYandexMetrikaEnabled = true;
          });
          Navigator.pop(context);
        }),

        onConfirm: () async {
          await ref
              .watch(yandexMetrikaControllerProvider.notifier)
              .delete(widget.formId);
          setState(() {
            uiControllers.yandexMetrikaIdController.text = '';
          });
          if (mounted) {
            Navigator.pop(context);
          }
        },
      );
    } else {
      return;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final form = ref.read(createFormProvider);

    _isMetaPixelEnabled = form.metaPixelId.isNotEmpty ? true : false;
    _isYandexMetrikaEnabled = form.yandexMetrikaId.isNotEmpty ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    final uiControllers = ref.watch(formUIControllersProvider);

    return Column(
      children: [
        _buildMetaPixelIntegration(
          isEnabled: _isMetaPixelEnabled,

          controller: uiControllers.metaPixelIdController,

          onChanged: (value) async {
            if (value == false) {
              await _deleteMetaPixelId();
            }

            setState(() {
              _isMetaPixelEnabled = value;
            });
          },
        ),

        _buildYandexMetrikaIntegration(
          isEnabled: _isYandexMetrikaEnabled,
          controller: uiControllers.yandexMetrikaIdController,

          onChanged: (value) async {
            final form = await ref
                .watch(formControllerProvider.notifier)
                .fetchForm(widget.formId);

            if (value == false &&
                (form.data?['settings']['ya-metrika-id'] as String)
                    .isNotEmpty) {
              await _deleteYandexMetrikaId();
            }

            setState(() {
              _isYandexMetrikaEnabled = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildMetaPixelIntegration({
    bool isEnabled = true,

    ValueChanged<bool>? onChanged,

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
          ],
        ],
      ),
    );
  }

  Widget _buildYandexMetrikaIntegration({
    bool isEnabled = true,
    ValueChanged<bool>? onChanged,

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

  Widget _buildAlertAtDelete(String name) {
    return Container(
      width: 350,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(50),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          HeroIcon(
            HeroIcons.exclamationCircle,
            style: HeroIconStyle.solid,
            color: Colors.red,
          ),
          const SizedBox(
            width: 8,
          ),

          SizedBox(
            width: 300,
            child: Text(
              'После подтвержение $name удаляется автоматически без публикации страницы',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    String name, {
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: SizedBox(
          width: 350,
          child: Text(
            'Вы хотите отключить интеграцию\n$name?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        content: _buildAlertAtDelete('Meta Pixel'),
        actions: [
          FFButton(
            onPressed: onConfirm ?? () {},
            text: 'Да, удалить',
            secondTheme: true,
          ),
          FFButton(
            onPressed: onCancel ?? () {},
            text: 'Отмена',
          ),
        ],
      ),
    );
  }
}
