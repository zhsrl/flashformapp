import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/integration_controller.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

class YandexMetrikaIntegrationSettingsView extends ConsumerStatefulWidget {
  const YandexMetrikaIntegrationSettingsView({
    super.key,
    required this.formId,
  });

  final String formId;

  @override
  ConsumerState<YandexMetrikaIntegrationSettingsView> createState() =>
      _YandexMetrikaIntegrationSettingsViewState();
}

class _YandexMetrikaIntegrationSettingsViewState
    extends ConsumerState<YandexMetrikaIntegrationSettingsView> {
  late TextEditingController _metrikaIdController;

  @override
  void initState() {
    super.initState();
    _metrikaIdController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final formState = ref.watch(createFormProvider);
    _metrikaIdController.text = formState.yandexMetrikaId;
  }

  @override
  void dispose() {
    _metrikaIdController.dispose();
    super.dispose();
  }

  Future<void> _saveMetrika() async {
    if (_metrikaIdController.text.trim().isEmpty) {
      showSnackbar(
        context,
        type: SnackbarType.info,
        message: 'Укажите ID метрики',
      );
      return;
    }

    ref
        .read(createFormProvider.notifier)
        .updateYandexMetrikaId(
          _metrikaIdController.text.trim(),
        );

    await ref
        .read(yandexMetrikaControllerProvider.notifier)
        .save(widget.formId);

    showSnackbar(
      context,
      type: SnackbarType.success,
      message: 'Яндекс Метрика сохранена',
    );
  }

  Future<void> _disconnectMetrika() async {
    final controller = ref.read(createFormProvider.notifier);
    await ref
        .read(yandexMetrikaControllerProvider.notifier)
        .delete(widget.formId);
    controller.updateYandexMetrikaId('');
    _metrikaIdController.clear();

    showSnackbar(
      context,
      type: SnackbarType.info,
      message: 'Яндекс Метрика отключена',
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(createFormProvider);
    final isConnected = formState.yandexMetrikaId.isNotEmpty;

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
                          'Яндекс Метрика',
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
                  'Укажите ID счетчика для отправки событий.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 20),
                FFTextField(
                  controller: _metrikaIdController,
                  title: 'ID счетчика',
                  hintText: '12345678',
                  prefixIcon: const HeroIcon(HeroIcons.codeBracket),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FFButton(
                    onPressed: _saveMetrika,
                    text: isConnected ? 'Обновить' : 'Подключить',
                    secondTheme: false,
                  ),
                ),
                if (isConnected)
                  SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: TextButton.icon(
                        onPressed: _disconnectMetrika,
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
