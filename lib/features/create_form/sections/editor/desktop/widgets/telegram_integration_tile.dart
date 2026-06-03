import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/integration_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heroicons/heroicons.dart';

class TelegramIntegrationTile extends ConsumerWidget {
  const TelegramIntegrationTile({
    super.key,
    required this.formId,
    required this.isAvailable,
  });

  final String formId;
  final bool isAvailable;

  void _openSettingsDrawer(BuildContext context, WidgetRef ref) {
    ref.read(integrationDrawerProvider.notifier).state =
        IntegrationDrawerType.telegram;
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(createFormProvider);
    final isConnected =
        formState.telegramEnabled && formState.telegramChatId != null;

    return Container(
      width: context.screenWidth,
      decoration: _buildBlocksDecoration(),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
                      child: SvgPicture.asset('assets/images/telegram.svg'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Telegram Bot',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (!isAvailable)
                        Row(
                          children: [
                            const HeroIcon(
                              HeroIcons.informationCircle,
                              size: 15,
                              color: Colors.deepOrangeAccent,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Доступно в Pro',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.deepOrangeAccent,
                              ),
                            ),
                          ],
                        )
                      else if (isConnected)
                        const Text(
                          '✓ Подключено',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        SizedBox(
                          width: 150,
                          child: Text(
                            'Получайте уведомления о лидах в Telegram',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (!isAvailable)
                const SizedBox()
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: isConnected
                        ? Colors.green
                        : Colors.blueAccent,
                  ),
                  onPressed: () => _openSettingsDrawer(context, ref),
                  child: Text(
                    isConnected ? 'Настроить' : 'Подключить',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildBlocksDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      border: Border.all(width: 1.5, color: AppTheme.border),
    );
  }
}
