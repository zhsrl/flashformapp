import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/integration_controller.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:heroicons/heroicons.dart';

class SettingsIntergrationViewDesktop extends ConsumerStatefulWidget {
  SettingsIntergrationViewDesktop({
    super.key,
    required this.formId,
  });

  final String formId;

  @override
  ConsumerState<SettingsIntergrationViewDesktop> createState() =>
      _SettingsIntergrationViewDesktopState();
}

class _SettingsIntergrationViewDesktopState
    extends ConsumerState<SettingsIntergrationViewDesktop> {
  bool _isMetaPixelEnabled = false;
  bool _isYandexMetrikaEnabled = false;

  final _metaPixelController = TextEditingController();
  final _yandexMetrikaController = TextEditingController();

  @override
  void initState() async {
    super.initState();
    final metaPixel = ref.watch(metaPixelControllerProvider.notifier);
    metaPixel.get(widget.formId);
  }

  @override
  void dispose() {
    _metaPixelController.dispose();
    _yandexMetrikaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMetaPixelIntegration(
          isEnabled: _isMetaPixelEnabled,
          controller: _metaPixelController,
          onChanged: (value) => setState(() {
            _isMetaPixelEnabled = value;
          }),
        ),
        _buildYandexMetrikaIntegration(
          isEnabled: _isYandexMetrikaEnabled,
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
                    'Подключить Meta Pixel',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Switch(
                value: isEnabled,
                thumbColor: WidgetStatePropertyAll(AppTheme.secondary),
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
            ),
            SizedBox(
              width: context.screenWidth,
              child: FFButton(
                onPressed: onTap ?? () {},

                text: 'Добавить',
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
                    'Подключить Метрику',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Switch(
                value: isEnabled,
                thumbColor: WidgetStatePropertyAll(AppTheme.secondary),
                onChanged: onChanged,
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(
              height: 8,
            ),
            FFTextField(
              prefixIcon: HeroIcon(HeroIcons.codeBracket),
              maxLines: 1,
              hintText: 'Введите Metrika Id',
            ),
            SizedBox(
              width: context.screenWidth,
              child: FFButton(
                onPressed: () {},
                text: 'Добавить',
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

  HeroIcons _getIconForFieldType(String type) {
    switch (type) {
      case 'phone':
        return HeroIcons.phone;
      case 'email':
        return HeroIcons.envelope;
      case 'text':
        return HeroIcons.chatBubbleOvalLeftEllipsis;
      default:
        return HeroIcons.user;
    }
  }

  Widget _buildSizeSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(width: 1.5, color: AppTheme.border),
              ),
              padding: const EdgeInsets.all(8),
              child: Text(
                '${value.toInt()} px',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          thumbColor: AppTheme.secondary,
          label: value.toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
