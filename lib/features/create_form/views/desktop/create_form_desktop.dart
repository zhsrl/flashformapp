// ignore: depend_on_referenced_packages

import 'package:flashform_app/data/controller/image_controller.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flutter_svg/svg.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/forms_controller.dart';
import 'package:flashform_app/features/create_form/views/desktop/preview_view.dart';
import 'package:flashform_app/features/create_form/views/desktop/settings_panel_view.dart';
import 'package:flashform_app/features/home/widgets/editor_app_bar.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';

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

class _CreateFormDesktopViewState extends ConsumerState<CreateFormDesktopView> {
  final _titleController = TextEditingController(text: 'Заголовок');
  final _subtitleController = TextEditingController(text: 'Описание');
  final _formTitleController = TextEditingController(text: 'Заголовок формы');
  final _successTextController = TextEditingController(text: 'Успешная форма');
  final _buttonTextController = TextEditingController(text: 'Кнопка');
  final _formButtonTextController = TextEditingController(
    text: 'Оставить заявку',
  );

  bool _isloadingInitialData = true;
  bool isFormNameChange = false;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _formTitleController.dispose();
    _buttonTextController.dispose();
    _successTextController.dispose();

    super.dispose();
  }

  Future<void> _loadFormData() async {
    try {
      final formController = ref.read(formControllerProvider.notifier);
      final form = await formController.fetchForm(widget.formId);

      debugPrint('Form: ${form.data}');

      if (mounted) {
        ref.read(createFormProvider.notifier).initializeFromModel(form);

        _titleController.text = form.data?['title']['text'] ?? 'Заголовк';
        _subtitleController.text = form.data?['subtitle']['text'] ?? 'Описание';
        _formTitleController.text =
            form.data?['form']['title'] ?? 'Заголовок формы';
        _buttonTextController.text = form.data?['button']['text'] ?? 'Кнопка';
        _formButtonTextController.text =
            form.data?['form']['button']['text'] ?? 'Оставить заявку';
        _successTextController.text =
            form.data?['success_text'] ?? 'Успешная форма';
      }
    } catch (e) {
      debugPrint('Error loading form: $e');
    } finally {
      setState(() {
        _isloadingInitialData = false;
      });
    }
  }

  Future<void> _updateFormName(String name) async {
    final formControllerNotifier = ref.read(formControllerProvider.notifier);
    final createFormControllerNotifier = ref.read(createFormProvider.notifier);
    await formControllerNotifier.updateFormName(name, widget.formId);

    ref.invalidate(formControllerProvider);
    createFormControllerNotifier.updateFormName(name);

    setState(() {
      isFormNameChange = false;
    });
  }

  Future<void> _handlePublish(String formId) async {
    final imageNotifier = ref.read(imageControllerProvider.notifier);
    final formNotifier = ref.read(createFormProvider.notifier);

    final imageState = ref.read(imageControllerProvider);

    try {
      String? imageUrl = ref.read(createFormProvider).heroImageUrl;

      // Invalidate form status provider
      ref.invalidate(formStatusProvider(formId));

      if (imageState.localImageBytes != null) {
        final uploadImageUrl = await imageNotifier.uploadImage(
          folder: formId,
          bytes: imageState.localImageBytes,
        );

        if (uploadImageUrl != null) {
          imageUrl = uploadImageUrl;
          debugPrint('URL to fetch: $imageUrl');
          formNotifier.updateHeroImage(imageUrl);
        } else {
          throw Exception('Не удалось загрузить изображение');
        }

        final success = await formNotifier.publishForm(formId);

        if (mounted) {
          if (success) {
            imageNotifier.resetPickedImage();
            _showLinkDialog(formId);
            // showSnackbar(
            //   context,
            //   type: SnackbarType.success,
            //   message: 'Опубликовано!',
            // );
            formNotifier.clearChanges();
          } else {
            showSnackbar(
              context,
              type: SnackbarType.error,
              message: 'Ошибка публикации',
            );
          }
        }
      } else {
        final success = await formNotifier.publishForm(formId);

        if (mounted) {
          if (success) {
            imageNotifier.resetPickedImage();

            _showLinkDialog(formId);
            formNotifier.clearChanges();
          } else {
            showSnackbar(
              context,
              type: SnackbarType.error,
              message: 'Ошибка публикации',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error chain: $e');
      if (mounted) {
        showSnackbar(context, type: SnackbarType.error, message: 'Ошибка: $e');
      }
      throw Exception(e);
    } finally {
      formNotifier.updateIsPublishing(false);
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
                    'images/logo-dark.svg',
                    width: 100,
                  ),
                ),
              ),

              content: formStatusAsync.when(
                data: (isActive) {
                  debugPrint('page is active: $isActive');

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

                              Text(
                                'https://fform.me/${formSlug.value ?? ''}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  // color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              FFButton(
                                onPressed: () {},
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
      _handlePublish(widget.formId);
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
      context.go('/');
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
              context.go('/');
            }
          }
        },

        onPublish: () async {
          await _handlePublish(widget.formId);
        },
      ),

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
                    SettingsPanelView(
                      titleController: _titleController,
                      onChanged: ref
                          .read(createFormProvider.notifier)
                          .markAsChanged,
                      formButtonTextController: _formButtonTextController,
                      subtitleController: _subtitleController,
                      formTitleController: _formTitleController,

                      focusNode: _focusNode,

                      successTextController: _successTextController,
                      buttonTextController: _buttonTextController,
                    ),

                    const SizedBox(
                      width: 16,
                    ),
                    PreviewView(
                      titleController: _titleController,
                      subtitleController: _subtitleController,
                      formTitleController: _formTitleController,
                      buttonTextController: _buttonTextController,
                      formButtonTextController: _formButtonTextController,
                      successTextController: _successTextController,
                      focusNode: _focusNode,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
