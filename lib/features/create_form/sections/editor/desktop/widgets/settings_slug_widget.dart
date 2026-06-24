import 'package:easy_localization/easy_localization.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/logger.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/forms_controller.dart';
import 'package:flashform_app/data/controller/slug_validation_controller.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class BuildSlugChangeWidget extends ConsumerStatefulWidget {
  const BuildSlugChangeWidget({
    super.key,
    this.isAvailable = false,
  });

  final bool isAvailable;

  @override
  ConsumerState<BuildSlugChangeWidget> createState() =>
      _BuildSlugChangeWidgetState();
}

class _BuildSlugChangeWidgetState extends ConsumerState<BuildSlugChangeWidget> {
  final TextEditingController _slugController = TextEditingController();
  String? _lastSyncedSlug;
  bool _isSaving = false;

  @override
  void dispose() {
    _slugController.dispose();
    super.dispose();
  }

  /// Синхронизирует значение из базы данных с текстовым полем контроллера
  void _syncController(String slug) {
    if (_lastSyncedSlug == slug) return;

    // Перезаписываем контроллер, если он пустой, совпадает с прошлым засинканным,
    // или если мы не находимся в процессе сохранения нового слага
    final shouldOverwrite =
        _slugController.text.isEmpty ||
        _slugController.text == _lastSyncedSlug ||
        _lastSyncedSlug == null;

    if (shouldOverwrite) {
      _slugController.text = slug;
      _slugController.selection = TextSelection.collapsed(
        offset: _slugController.text.length,
      );
      _lastSyncedSlug = slug;
    }
  }

  @override
  Widget build(BuildContext context) {
    final slugAvailableState = ref.watch(slugValidationProvider);
    final currentFormId = ref.watch(currentFormIdProvider);
    final currentFormSlugState = ref.watch(
      currentFormSlugProvider(currentFormId),
    );

    // Слушаем изменения слага из БД
    currentFormSlugState.whenData(_syncController);

    // Наблюдаем за состоянием загрузки основного контроллера форм
    final formsState = ref.watch(formControllerProvider);
    final isControllerLoading = formsState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    final isLoading = _isSaving || isControllerLoading;

    return Container(
      width: context.screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(width: 1.5, color: AppTheme.border),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ссылка',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            width: context.screenWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              border: Border.all(width: 1.5, color: AppTheme.border),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FFTextField(
                  enabled: widget.isAvailable && !isLoading,
                  formatters: [
                    // Полезно разрешить только латиницу, цифры и дефис для URL-адреса
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z0-9\-]'),
                    ),
                  ],
                  controller: _slugController,
                  onChanged: (value) {
                    ref
                        .read(slugValidationProvider.notifier)
                        .onSlugChanged(value);
                  },
                  prefixText: 'fform.me/',
                ),
                const SizedBox(height: 8),
                slugAvailableState.when(
                  data: (isAvailable) {
                    if (isAvailable == null) {
                      return const SizedBox();
                    }

                    return isAvailable
                        ? const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                'Свободно',
                                style: TextStyle(
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            children: [
                              Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                'Занят',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          );
                  },
                  error: (er, st) {
                    return const Icon(Icons.wifi_off, color: Colors.orange);
                  },
                  loading: () => const Row(
                    children: [
                      CupertinoActivityIndicator(),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Проверяем',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                SizedBox(
                  width: context.screenWidth,
                  child: FFButton(
                    isLoading: isLoading,
                    onPressed: (widget.isAvailable && !isLoading)
                        ? () async {
                            final newSlug = _slugController.text.trim();
                            if (newSlug.isEmpty) return;

                            setState(() {
                              _isSaving = true;
                            });

                            try {
                              // 1. Сначала дожидаемся успешного сохранения в БД
                              await ref
                                  .read(formControllerProvider.notifier)
                                  .updateFormSlug(
                                    newSlug,
                                    currentFormId,
                                  );

                              // 2. Сбрасываем синхронизационный флаг, чтобы виджет принял новое значение
                              _lastSyncedSlug = null;

                              // 3. Инвалидируем провайдер слага, заставляя его прочитать свежие данные
                              ref.invalidate(
                                currentFormSlugProvider(currentFormId),
                              );

                              // 4. Сбрасываем плашку проверки слага в UI (так как он теперь наш сохраненный)

                              ref.invalidate(slugValidationProvider);

                              if (context.mounted) {
                                showSnackbar(
                                  context,
                                  type: SnackbarType.success,
                                  message: 'Ссылка успешно сохранена!',
                                );
                              }
                            } catch (e, st) {
                              if (context.mounted) {
                                logger.d(
                                  'ChangeSlugLog: ',
                                  error: e,
                                  stackTrace: st,
                                );
                                showSnackbar(
                                  context,
                                  type: SnackbarType.error,
                                  message: 'Ошибка при сохранении: $e',
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isSaving = false;
                                });
                              }
                            }
                          }
                        : null,
                    text: 'Сохранить',
                  ),
                ),
                const SizedBox(height: 8),
                if (!widget.isAvailable)
                  Row(
                    children: [
                      const HeroIcon(
                        HeroIcons.informationCircle,
                        size: 15,
                        color: Colors.deepOrangeAccent,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        'forms.available_go_pro'.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
