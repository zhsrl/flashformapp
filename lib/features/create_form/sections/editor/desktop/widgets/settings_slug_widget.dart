import 'package:easy_localization/easy_localization.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/forms_controller.dart';
import 'package:flashform_app/data/controller/slug_validation_controller.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

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

  @override
  void dispose() {
    _slugController.dispose();
    super.dispose();
  }

  void _syncController(String slug) {
    if (_lastSyncedSlug == slug) return;

    final shouldOverwrite =
        _slugController.text.isEmpty || _slugController.text == _lastSyncedSlug;

    if (shouldOverwrite) {
      _slugController.text = slug;
      _slugController.selection = TextSelection.collapsed(
        offset: _slugController.text.length,
      );
      _lastSyncedSlug = slug;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final slugAvailableState = ref.watch(slugValidationProvider);
    final currentFormId = ref.watch(currentFormIdProvider);
    final currentFormSlugState = ref.watch(
      currentFormSlugProvider(currentFormId),
    );

    currentFormSlugState.whenData(_syncController);

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
        crossAxisAlignment: .start,
        children: [
          Text(
            'Ссылка',
            style: TextStyle(
              fontWeight: .w500,
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
              crossAxisAlignment: .start,
              children: [
                FFTextField(
                  enabled: widget.isAvailable,
                  formatters: [
                    // FilteringTextInputFormatter.allow(
                    //   RegExp(r'[a-zA-Z0-9\-]]'),
                    // ),
                  ],

                  controller: _slugController,
                  onChanged: (value) {
                    ref
                        .read(slugValidationProvider.notifier)
                        .onSlugChanged(value);
                  },
                  prefixText: 'fform.me/',
                ),

                slugAvailableState.when(
                  data: (isAvailable) {
                    if (isAvailable == null) {
                      return SizedBox();
                    }

                    return isAvailable
                        ? Row(
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
                        : Row(
                            children: [
                              Icon(
                                Icons.check_circle,
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
                  loading: () => Row(
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
                  height: 8,
                ),
                SizedBox(
                  width: context.screenWidth,
                  child: FFButton(
                    // isLoading: ref.read(formControllerProvider).isLoading,
                    onPressed: widget.isAvailable
                        ? () async {
                            ref
                                .read(formControllerProvider.notifier)
                                .updateFormSlug(
                                  _slugController.text,
                                  currentFormId,
                                );

                            ref.invalidate(
                              currentFormSlugProvider(currentFormId),
                            );
                          }
                        : null,
                    text: 'Сохранить',
                  ),
                ),
                if (!widget.isAvailable)
                  Row(
                    children: [
                      HeroIcon(
                        HeroIcons.informationCircle,
                        size: 15,
                        color: Colors.deepOrangeAccent,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        'forms.available_go_pro'.tr(),
                        style: TextStyle(
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
