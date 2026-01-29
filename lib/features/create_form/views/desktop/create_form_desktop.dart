import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/controller/forms_controller.dart';
import 'package:flashform_app/data/model/form_model.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/features/create_form/views/desktop/preview_view.dart';
import 'package:flashform_app/features/create_form/views/desktop/settings_panel_view.dart';
import 'package:flashform_app/features/home/widgets/editor_app_bar.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';
import 'package:flashform_app/features/widgets/ff_tabbar.dart';
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
  final _titleController = TextEditingController(text: 'Заголовок');
  final _subtitleController = TextEditingController(text: 'Описание');
  final _formTitleController = TextEditingController(text: 'Заголовок формы');
  final _successTextController = TextEditingController();
  final _buttonTextController = TextEditingController(text: 'Оставить заявку');
  final _formButtonTextController = TextEditingController(
    text: 'Оставить заявку',
  );

  int _settingsViewTabIndex = 0;

  final FocusNode _focusNode = FocusNode();

  final List<FormFields> _fields = [];
  String? _heroImageUrl;

  // Theme
  String _formTheme = 'light';

  // Font-sizes
  double _titleFontSize = 42;
  double _subtitleFontSize = 22;

  // Action type
  String _actionType = 'button-url';

  // Initial button color
  Color _buttonColor = Colors.blue;
  Color _formButtonColor = Colors.blue;

  bool _isPublishing = false;

  bool _hasRedirectURL = false;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _formTitleController.dispose();
    _buttonTextController.dispose();
    _successTextController.dispose();
    super.dispose();
  }

  // ValueChanged<Color> callback
  void buttonChangeColor(Color color) {
    setState(() => _buttonColor = color);
  }

  void formButtonChangeColor(Color color) {
    setState(() => _formButtonColor = color);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final formId = ref.read(currentFormIdProvider);

    if (_fields.isEmpty) {
      showSnackbar(
        context,
        type: SnackbarType.info,
        message: 'Добавьте хотя бы одно поле',
      );
      return; // Добавил return, чтобы не продолжать выполнение
    }

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    setState(() {
      _isPublishing = true;
    });

    try {
      String title = _titleController.text.trim();
      String subtitle = _subtitleController.text.trim();
      String formTitle = _formTitleController.text.trim();
      String buttonText = _buttonTextController.text.trim();
      String successText = _successTextController.text.trim();

      if (buttonText.isEmpty) buttonText = 'Оставить заявку';

      final fieldsData = _fields
          .map(
            (field) => {
              'label': field.label,
              'type': field.type,
            },
          )
          .toList();

      final Map<String, dynamic> data = {
        'id': formId,
        'user_id': user.id,
        'title': title,
        'form_title': formTitle,
        'subtitle': subtitle,
        'hero_image': _heroImageUrl,
        'theme': _formTheme,
        'fields': fieldsData,
        'is_active': true,
        'success_text': successText,
        'button_text': buttonText,
      };

      await ref.read(formControllerProvider.notifier).publishForm(data);

      if (!mounted) return;

      showSnackbar(
        context,
        type: SnackbarType.success,
        message: 'Форма успешно опубликована',
      );
    } catch (e) {
      debugPrint(
        'Ошибка при сохранении формы: $e',
      ); // Лучше использовать debugPrint

      showSnackbar(
        context,
        type: SnackbarType.error,
        message: 'Ошибка при публикации формы',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: EditorAppBar(
        formId: ref.watch(currentFormIdProvider),
        automaticallyImplyLeading: true,
        isPublishing: _isPublishing,
        onPublish: () async {
          await _submitForm();
        },
      ),
      body: DefaultTabController(
        length: 3,
        child: Padding(
          padding: EdgeInsetsGeometry.all(16),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 350,
                  child: Column(
                    children: [
                      FFTabBar(
                        tabs: [
                          Text('Контент'),
                          Text('Footer'),
                          Text('Интеграция'),
                        ],
                        onTap: (index) {
                          setState(() {
                            _settingsViewTabIndex = index;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: SettingsPanelView(
                            tabIndex: _settingsViewTabIndex,
                            fields: _fields,
                            onFieldsChanged: () {
                              setState(() {});
                            },
                            formKey: _formKey,
                            titleController: _titleController,
                            buttonColor: _buttonColor,
                            formTheme: _formTheme,

                            heroImageUrl: _heroImageUrl,
                            subtitleController: _subtitleController,
                            formTitleController: _formTitleController,
                            actionType: _actionType,
                            onActionTypeChanged: (value) {
                              setState(() {
                                _actionType = value!;
                              });
                            },
                            focusNode: _focusNode,

                            onButtonColorChanged: buttonChangeColor,
                            formButtonColor: _formButtonColor,
                            formButtonTextController: _formButtonTextController,
                            onFormButtonColorChanged: formButtonChangeColor,
                            titleFontSize: _titleFontSize,
                            subtitleFontSize: _subtitleFontSize,
                            titleFontSizeChanged: (value) => setState(() {
                              _titleFontSize = value;
                            }),
                            subtitleFontSizeChanged: (value) => setState(() {
                              _subtitleFontSize = value;
                            }),

                            successTextController: _successTextController,
                            buttonTextController: _buttonTextController,

                            onHeroImageChanged: (url) {
                              setState(() {
                                _heroImageUrl = url;
                              });
                            },
                            onThemeChanged: (theme) {
                              setState(() {
                                _formTheme = theme!;
                              });
                            },

                            hasRedirectUrl: _hasRedirectURL,
                            onRedirectUrlValueChanged: (value) {
                              setState(() {
                                _hasRedirectURL = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 16,
                ),

                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: PreviewView(
                      fields: _fields,
                      formKey: _formKey,
                      titleController: _titleController,
                      formTheme: _formTheme,
                      heroImageUrl: _heroImageUrl,
                      subtitleController: _subtitleController,
                      formTitleController: _formTitleController,
                      focusNode: _focusNode,
                      titleFontSize: _titleFontSize,
                      actionType: _actionType,
                      buttonColor: _buttonColor,
                      formButtonColor: _formButtonColor,
                      formButtonTextController: _formButtonTextController,
                      onFormButtonColorChanged: formButtonChangeColor,
                      subtitleFontSize: _subtitleFontSize,
                      successTextController: _successTextController,
                      buttonTextController: _buttonTextController,

                      onHeroImageChanged: (url) {
                        setState(() {
                          _heroImageUrl = url;
                        });
                      },
                      onThemeChanged: (theme) {
                        setState(() {
                          _formTheme = theme!;
                        });
                      },
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
