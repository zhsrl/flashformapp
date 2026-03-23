import 'package:flashform_app/core/mixins/form_loader_mixin.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/data/model/form_link.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/views/telegram_integration_settings_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/forms_controller.dart';
import 'package:flashform_app/features/create_form/views/desktop/preview/preview_view.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/editor_view_desktop.dart';
import 'package:flashform_app/features/home/widgets/editor_app_bar.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateFormDesktopView extends ConsumerStatefulWidget {
  const CreateFormDesktopView({
    super.key,
    required this.formId,
  });

  final String formId;

  @override
  ConsumerState<CreateFormDesktopView> createState() =>
      _CreateFormDesktopViewState();
}

class _CreateFormDesktopViewState extends ConsumerState<CreateFormDesktopView>
    with FormLoaderMixin {
  bool _isloadingInitialData = true;
  bool isFormNameChange = false;
  bool isCopy = false;

  final FocusNode _focusNode = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadFormData(widget.formId, ref, () => mounted, () {
      if (mounted) {
        setState(() {
          _isloadingInitialData = false;
        });
      }
    });
  }

  Future<void> _updateFormName(String name) async {
    final formControllerNotifier = ref.read(formControllerProvider.notifier);
    final createFormControllerNotifier = ref.read(createFormProvider.notifier);
    await formControllerNotifier.updateFormName(name, widget.formId);

    if (!mounted) return;

    ref.invalidate(formControllerProvider);
    createFormControllerNotifier.updateFormName(name);

    if (mounted) {}

    setState(() {
      isFormNameChange = false;
    });
  }

  Future<void> _openURL(String url) async {
    Uri uri = Uri.parse(url);

    await launchUrl(uri);
  }

  Future<void> _onPublishTap() async {
    // Просто вызываем умный метод контроллера
    final success = await ref
        .read(createFormProvider.notifier)
        .publishForm(widget.formId);

    if (!mounted) return;

    if (success) {
      // Если успех — показываем диалог (он никуда не делся!)
      _showLinkDialog(widget.formId);
    } else {
      showSnackbar(
        context,
        type: SnackbarType.error,
        message: 'Ошибка публикации',
      );
    }
  }

  Future<void> _showLinkDialog(
    String formId,
  ) async {
    showDialog(
      context: context,

      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final formStatusAsync = ref.watch(formStatusProvider(formId));
            final formSlug = ref.watch(currentFormSlugProvider(formId));

            ref.invalidate(formStatusProvider);

            return AlertDialog(
              backgroundColor: AppTheme.background,
              titlePadding: EdgeInsets.zero,
              title: Container(
                width: 350,
                height: 50,

                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(
                      20,
                    ),
                  ),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/logo-dark.svg',
                    width: 100,
                  ),
                ),
              ),

              content: formStatusAsync.when(
                data: (isActive) {
                  return isActive
                      ? SizedBox(
                          width: 350,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Страница опубликована!',
                                style: TextStyle(
                                  fontSize: 18,
                                  // color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    'https://fform.me/${formSlug.value ?? ''}',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      // color: AppTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      final url =
                                          'https://fform.me/${formSlug.value ?? ''}';
                                      Clipboard.setData(
                                        ClipboardData(text: url),
                                      ).then((_) {
                                        if (!context.mounted) return;
                                        showSnackbar(
                                          context,
                                          type: SnackbarType.info,
                                          message: 'Ссылка скопирована',
                                        );
                                      });
                                    },
                                    child: HeroIcon(
                                      HeroIcons.documentDuplicate,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              FFButton(
                                onPressed: () async {
                                  await _openURL(
                                    'https://fform.me/${formSlug.value ?? ''}',
                                  );
                                },
                                text: 'Открыть',
                                secondTheme: true,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  final formController = ref.read(
                                    formControllerProvider.notifier,
                                  );

                                  await formController
                                      .unpublishForm(formId)
                                      .then((_) {
                                        ref.invalidate(formStatusProvider);
                                        ref.invalidate(formControllerProvider);
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      });
                                },
                                icon: HeroIcon(HeroIcons.linkSlash),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.secondary,
                                  iconColor: AppTheme.secondary.withAlpha(100),
                                ),
                                label: Text(
                                  'или отключить страницу',
                                  style: TextStyle(
                                    color: AppTheme.secondary.withAlpha(100),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          width: 350,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Страница не опубликована',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                },
                error: (er, st) {
                  return Center(
                    child: Text(er.toString()),
                  );
                },
                loading: () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: LoadingAnimationWidget.waveDots(
                        color: AppTheme.secondary,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Do you want to save them?',
        ),
        actions: [
          FFButton(
            onPressed: () => Navigator.pop(context),
            text: 'Отмена',
          ),
          FFButton(
            onPressed: () {
              Navigator.pop(context);
              _discardChanges();
            },
            text: 'Выход без изменении',
          ),
          FFButton(
            secondTheme: true,
            onPressed: () async {
              Navigator.pop(context);
              await _publishAndLeave();
            },
            text: 'Опубликовать',
          ),
        ],
      ),
    );
  }

  Future<void> _publishAndLeave() async {
    if (mounted) {
      _onPublishTap();
      if (!mounted) return;

      context.pop();

      showSnackbar(
        context,
        type: SnackbarType.error,
        message: 'Error saving form',
      );
    }
  }

  void _discardChanges() {
    ref.read(createFormProvider.notifier).updateHasChanges(false);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/forms');
    }
  }

  void _showDeleteFormDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Удалить форму?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    HeroIcon(
                      HeroIcons.exclamationTriangle,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Форма и все связанные данные будут удалены безвозвратно.',
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          FFButton(
            onPressed: () => Navigator.pop(context),
            text: 'Отмена',
          ),
          FFButton(
            secondTheme: true,
            onPressed: () async {
              Navigator.pop(context);
              await _deleteForm();
            },
            text: 'Удалить',
          ),
        ],
      ),
    );
  }

  Future<void> _deleteForm() async {
    final formState = ref.read(createFormProvider);
    final imageUrl = formState.heroImageUrl;

    try {
      await ref
          .read(formControllerProvider.notifier)
          .deleteForm(widget.formId, imageUrl: imageUrl);

      if (!mounted) return;
      context.go('/forms');
    } catch (e) {
      if (!mounted) return;
      showSnackbar(
        context,
        type: SnackbarType.error,
        message: 'Ошибка при удалении формы',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(createFormProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: EditorAppBar(
        formName: formState.name,
        automaticallyImplyLeading: true,
        isPublishing: formState.isPublishing,
        onTapMore: _showDeleteFormDialog,
        onTapLink: () {
          _showLinkDialog(widget.formId);
        },
        isFormNameChange: isFormNameChange,
        onSaveFormName: (name) async {
          await _updateFormName(name);
        },
        onToggleEditMode: (value) {
          setState(() {
            isFormNameChange = value;
          });
        },

        onBack: () {
          if (formState.hasChanges) {
            _showUnsavedChangesDialog();
          } else {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/forms');
            }
          }
        },

        onPublish: () async {
          await _onPublishTap();
        },
      ),
      endDrawer: TelegramBotIntegrationSettingsView(),
      body: _isloadingInitialData
          ? Center(
              child: LoadingAnimationWidget.waveDots(
                color: AppTheme.secondary,
                size: 40,
              ),
            )
          : Padding(
              padding: EdgeInsetsGeometry.all(16),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EditorView(
                      onChanged: ref
                          .read(createFormProvider.notifier)
                          .markAsChanged,

                      focusNode: _focusNode,
                    ),

                    const SizedBox(
                      width: 16,
                    ),
                    PreviewView(
                      focusNode: _focusNode,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
