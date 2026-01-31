import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/forms_controller.dart';
import 'package:flashform_app/data/model/create_form_state.dart';
import 'package:flashform_app/features/create_form/views/desktop/preview_view.dart';
import 'package:flashform_app/features/create_form/views/desktop/settings_panel_view.dart';
import 'package:flashform_app/features/home/widgets/editor_app_bar.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(createFormProvider);
    final controller = ref.watch(createFormProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: EditorAppBar(
        formName: widget.formId,
        automaticallyImplyLeading: true,
        isPublishing: formState.isPublishing,
        isSaving: formState.isSaving,
        onSave: () async {
          controller.updateIsSaving(true);
          final success = await ref
              .read(createFormProvider.notifier)
              .saveForm(widget.formId);

          if (context.mounted) {
            if (success) {
              controller.updateIsSaving(false);
              showSnackbar(
                context,
                type: SnackbarType.success,
                message: 'Успешно сохранен!',
              );
            } else {
              controller.updateIsSaving(false);
              showSnackbar(
                context,
                type: SnackbarType.error,
                message: 'Ошибка при сохранении',
              );
            }
          }

          controller.updateIsSaving(false);
        },
        onPublish: () async {
          controller.updateIsPublishing(true);
          final success = await ref
              .read(createFormProvider.notifier)
              .publishForm(widget.formId);
          if (context.mounted) {
            if (success) {
              showSnackbar(
                context,
                type: SnackbarType.success,
                message: 'Опубликовано!',
              );
            } else {
              showSnackbar(
                context,
                type: SnackbarType.error,
                message: 'Ошибка публикации',
              );
            }
          }
          controller.updateIsPublishing(false);
        },
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SettingsPanelView(
                titleController: _titleController,
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
