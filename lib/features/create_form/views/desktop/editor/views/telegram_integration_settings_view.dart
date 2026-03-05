import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

class TelegramBotIntegrationSettingsView extends ConsumerStatefulWidget {
  const TelegramBotIntegrationSettingsView({super.key});

  @override
  ConsumerState<TelegramBotIntegrationSettingsView> createState() =>
      _TelegramBotIntegrationSettingsViewState();
}

class _TelegramBotIntegrationSettingsViewState
    extends ConsumerState<TelegramBotIntegrationSettingsView> {
  late TextEditingController _chatIdController;

  @override
  void initState() {
    super.initState();
    _chatIdController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final formState = ref.watch(createFormProvider);
    _chatIdController.text = formState.telegramChatId ?? '';
  }

  @override
  void dispose() {
    _chatIdController.dispose();
    super.dispose();
  }

  void _saveTelegramSettings() {
    final controller = ref.read(createFormProvider.notifier);

    if (_chatIdController.text.isEmpty) {
      showSnackbar(
        context,
        type: SnackbarType.info,
        message: 'Заполните Chat ID',
      );
      return;
    }

    controller.updateTelegramChatId(_chatIdController.text);
    controller.updateTelegramEnabled(true);

    showSnackbar(
      context,
      type: SnackbarType.success,
      message: 'Telegram настройки сохранены',
    );
  }

  void _disconnectTelegram() {
    final controller = ref.read(createFormProvider.notifier);
    controller.clearTelegramSettings();
    _chatIdController.clear();

    showSnackbar(
      context,
      type: SnackbarType.info,
      message: 'Telegram отключен',
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(createFormProvider);
    final isConnected = formState.telegramEnabled;

    return SizedBox(
      width: 400,
      child: Drawer(
        backgroundColor: Colors.white,
        child: Container(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Telegram-уведомления',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        if (isConnected)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '✓ Подключено',
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
                      icon: HeroIcon(HeroIcons.xMark),
                      onPressed: () => Scaffold.of(context).closeEndDrawer(),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Description
                Text(
                  'Получайте данные о новых лидах мгновенно. Не дайте клиенту остыть — реагируйте в первые 60 секунд.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                SizedBox(height: 24),

                // Helper text
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📱 Как подключить:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. Напишите @fformMeBot боту в Telegram\n'
                        '2. Нажмите на кнопку - Начать\n'
                        '3. Скопируйте полученный Chat ID\n',
                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Chat ID field
                FFTextField(
                  controller: _chatIdController,
                  title: 'Telegram Chat ID',
                  hintText: '123456789',
                  prefixIcon: HeroIcon(HeroIcons.codeBracket),
                ),
                SizedBox(height: 20),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: FFButton(
                    onPressed: _saveTelegramSettings,
                    text: isConnected ? 'Обновить' : 'Подключить',
                    secondTheme: false,
                  ),
                ),
                if (isConnected)
                  SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () {
                          _disconnectTelegram();
                        },
                        label: Text('Отключить'),
                        icon: HeroIcon(HeroIcons.xMark),
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
