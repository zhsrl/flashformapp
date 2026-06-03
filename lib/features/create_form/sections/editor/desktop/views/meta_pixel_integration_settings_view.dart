import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/integration_controller.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

class MetaPixelIntegrationSettingsView extends ConsumerStatefulWidget {
  const MetaPixelIntegrationSettingsView({
    super.key,
    required this.formId,
  });

  final String formId;

  @override
  ConsumerState<MetaPixelIntegrationSettingsView> createState() =>
      _MetaPixelIntegrationSettingsViewState();
}

class _MetaPixelIntegrationSettingsViewState
    extends ConsumerState<MetaPixelIntegrationSettingsView> {
  late TextEditingController _pixelIdController;

  @override
  void initState() {
    super.initState();
    _pixelIdController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final formState = ref.watch(createFormProvider);
    _pixelIdController.text = formState.metaPixelId;
  }

  @override
  void dispose() {
    _pixelIdController.dispose();
    super.dispose();
  }

  Future<void> _savePixel() async {
    if (_pixelIdController.text.trim().isEmpty) {
      showSnackbar(
        context,
        type: SnackbarType.info,
        message: 'Укажите Pixel ID',
      );
      return;
    }

    ref
        .read(createFormProvider.notifier)
        .updateMetaPixelId(
          _pixelIdController.text.trim(),
        );

    await ref.read(metaPixelControllerProvider.notifier).save(widget.formId);

    showSnackbar(
      context,
      type: SnackbarType.success,
      message: 'Meta Pixel сохранен',
    );
  }

  Future<void> _disconnectPixel() async {
    final controller = ref.read(createFormProvider.notifier);
    await ref.read(metaPixelControllerProvider.notifier).delete(widget.formId);
    controller.updateMetaPixelId('');
    _pixelIdController.clear();

    showSnackbar(
      context,
      type: SnackbarType.info,
      message: 'Meta Pixel отключен',
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(createFormProvider);
    final isConnected = formState.metaPixelId.isNotEmpty;

    return SizedBox(
      width: 400,
      child: Drawer(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Meta Pixel',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (isConnected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Подключено',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      icon: const HeroIcon(HeroIcons.xMark),
                      onPressed: () => Scaffold.of(context).closeEndDrawer(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Укажите Pixel ID для передачи событий в Meta.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 20),
                FFTextField(
                  controller: _pixelIdController,
                  title: 'Pixel ID',
                  hintText: '1234567890',
                  prefixIcon: const HeroIcon(HeroIcons.codeBracket),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FFButton(
                    onPressed: _savePixel,
                    text: isConnected ? 'Обновить' : 'Подключить',
                    secondTheme: false,
                  ),
                ),
                if (isConnected)
                  SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: TextButton.icon(
                        onPressed: _disconnectPixel,
                        label: Text('Отключить'),
                        icon: const HeroIcon(HeroIcons.xMark),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
