import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/controller/forms_controller.dart';
import 'package:flashform_app/data/model/form_model.dart';
import 'package:flashform_app/features/create_form/views/desktop/settings_panel_view.dart';
import 'package:flashform_app/features/home/widgets/editor_app_bar.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _formTitleController = TextEditingController();
  final List<FormFields> _fields = [];

  bool _isDarkTheme = false;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _formTitleController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fields.isEmpty) {
      showSnackbar(
        context,
        type: SnackbarType.info,
        message: 'Добавьте хотя бы одно поле',
      );
    }

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    try {
      String title = _titleController.text.trim();
      String subtitle = _subtitleController.text.trim();
      String formTitle = _formTitleController.text.trim();

      final fieldsData = _fields
          .map(
            (field) => {
              'label': field.label,
              'type': field.type,
            },
          )
          .toList();

      final Map<String, dynamic> data = {
        'id': widget.formId,
        'user_id': user.id,
        'title': title,
        'form_title': formTitle,
        'subtitle': subtitle,
        'theme': _isDarkTheme ? 'dark' : 'light',
        'fields': fieldsData,
        'is_active': true,
      };

      await ref.read(formControllerProvider.notifier).publishForm(data);

      if (!mounted) return;

      showSnackbar(
        context,
        type: SnackbarType.success,
        message: 'Форма успешно опубликована',
      );
    } catch (e) {
      Exception('Ошибка при сохранении формы: $e');

      showSnackbar(
        context,
        type: SnackbarType.error,
        message: 'Ошибка при публикации формы',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _titleController.addListener(() {
      debugPrint("Родитель видит изменения: ${_titleController.text}");
    });

    debugPrint('Title при ребилде: ${_titleController.text}');
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: EditorAppBar(
        formId: widget.formId,
        automaticallyImplyLeading: true,
        onPublish: () async {
          await _submitForm();
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(16),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsPanelView(
                  fields: _fields,
                  formKey: _formKey,
                  titleController: _titleController,
                  isDarkTheme: _isDarkTheme,
                  subtitleController: _subtitleController,
                  formTitleController: _formTitleController,
                  onThemeChanged: (value) {
                    setState(() {
                      _isDarkTheme = value;
                    });
                  },
                ),

                const SizedBox(
                  width: 16,
                ),
                Container(
                  width: 350,
                  height: 200,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
