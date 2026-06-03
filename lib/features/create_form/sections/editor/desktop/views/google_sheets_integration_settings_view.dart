import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/logger.dart';
import 'package:flashform_app/data/controller/google_sheets_controller.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

class GoogleSheetsIntegrationSettingsView extends ConsumerStatefulWidget {
  const GoogleSheetsIntegrationSettingsView({
    super.key,
    required this.formId,
  });

  final String formId;

  @override
  ConsumerState<GoogleSheetsIntegrationSettingsView> createState() =>
      _GoogleSheetsIntegrationSettingsViewState();
}

class _GoogleSheetsIntegrationSettingsViewState
    extends ConsumerState<GoogleSheetsIntegrationSettingsView> {
  final TextEditingController _spreadsheetIdController =
      TextEditingController();
  final TextEditingController _sheetNameController = TextEditingController();
  bool _sendUtm = false;
  bool _didLoadInitial = false;
  bool _isCreating = false;

  @override
  void dispose() {
    _spreadsheetIdController.dispose();
    _sheetNameController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final spreadsheetId = _spreadsheetIdController.text.trim();
    final sheetName = _sheetNameController.text.trim();

    if (spreadsheetId.isEmpty || sheetName.isEmpty) {
      return;
    }

    await ref
        .read(googleSheetsIntegrationControllerProvider.notifier)
        .saveSettings(
          formId: widget.formId,
          spreadsheetId: spreadsheetId,
          sheetName: sheetName,
          sendUtm: _sendUtm,
        );

    ref.invalidate(googleSheetsIntegrationProvider(widget.formId));
  }

  Future<void> _disconnect() async {
    await ref
        .read(googleSheetsIntegrationControllerProvider.notifier)
        .disconnect(widget.formId);
    ref.invalidate(googleSheetsIntegrationProvider(widget.formId));
  }

  Future<void> _createSpreadsheet() async {
    if (_isCreating) return;
    setState(() {
      _isCreating = true;
    });

    final formState = ref.read(createFormProvider);
    final formName = (formState.name ?? '').trim();
    final title = formName.isEmpty
        ? 'Leads (FForm)'
        : 'Leads (FForm) - $formName';
    const sheetName = 'Leads';

    try {
      final result = await ref
          .read(googleSheetsIntegrationControllerProvider.notifier)
          .createSpreadsheet(
            formId: widget.formId,
            title: title,
            sheetName: sheetName,
          );

      _spreadsheetIdController.text = result.spreadsheetId;
      _sheetNameController.text = result.sheetName;
      ref.invalidate(googleSheetsIntegrationProvider(widget.formId));
    } catch (error) {
      logger.e('Google Sheets create error: $error');
    } finally {
      if (!mounted) return;
      setState(() {
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final integrationAsync = ref.watch(
      googleSheetsIntegrationProvider(widget.formId),
    );
    final savingState = ref.watch(googleSheetsIntegrationControllerProvider);

    return SizedBox(
      width: 400,
      child: Drawer(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: integrationAsync.when(
              data: (integration) {
                final isConnected = integration != null;

                if (!_didLoadInitial && integration != null) {
                  _spreadsheetIdController.text =
                      integration.spreadsheetId ?? '';
                  _sheetNameController.text = integration.sheetName ?? '';
                  _sendUtm = integration.sendUtm;
                  _didLoadInitial = true;
                }

                final hasSpreadsheet =
                    (integration?.spreadsheetId ?? '').isNotEmpty;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Google Sheets',
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
                          onPressed: () =>
                              Scaffold.of(context).closeEndDrawer(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Укажите таблицу и лист, куда будут приходить лиды.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    if (!hasSpreadsheet) ...[
                      FFButton(
                        onPressed: _isCreating || savingState.isLoading
                            ? null
                            : _createSpreadsheet,
                        text: _isCreating
                            ? 'Создаем таблицу...'
                            : 'Создать таблицу автоматически',
                        secondTheme: true,
                      ),
                      const SizedBox(height: 12),
                    ],
                    FFTextField(
                      controller: _spreadsheetIdController,
                      title: 'ID таблицы',
                      hintText: '1sQx... (из URL Google Sheets)',
                      prefixIcon: const HeroIcon(HeroIcons.link),
                    ),
                    const SizedBox(height: 12),
                    FFTextField(
                      controller: _sheetNameController,
                      title: 'Название листа',
                      hintText: 'Лиды',
                      prefixIcon: const HeroIcon(HeroIcons.tableCells),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _sendUtm,
                          onChanged: (value) {
                            setState(() {
                              _sendUtm = value ?? false;
                            });
                          },
                        ),
                        const Text('Посылать UTM метки'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FFButton(
                      onPressed: savingState.isLoading ? null : _saveSettings,
                      text: savingState.isLoading
                          ? 'Сохраняем...'
                          : 'Сохранить',
                      secondTheme: false,
                    ),
                    if (isConnected) ...[
                      const SizedBox(height: 12),
                      FFButton(
                        onPressed: savingState.isLoading ? null : _disconnect,
                        text: 'Отключить',
                        secondTheme: true,
                      ),
                    ],
                  ],
                );
              },
              error: (error, _) {
                logger.e('Google Sheets integration error: $error');
                return const Text('Ошибка загрузки настроек');
              },
              loading: () => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    color: AppTheme.secondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
