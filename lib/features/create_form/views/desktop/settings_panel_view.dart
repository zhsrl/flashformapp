import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/model/form_model.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/features/create_form/widgets/image_picker_widget.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

class SettingsPanelView extends StatefulWidget {
  const SettingsPanelView({
    super.key,
    this.fields,
    this.formKey,
    this.formTitleController,
    this.subtitleController,
    this.titleController,
    required this.onThemeChanged,
    this.isDarkTheme = false,
    this.heroImageUrl,
    this.onHeroImageChanged,
  });

  final List<FormFields>? fields;
  final GlobalKey<FormState>? formKey;
  final bool isDarkTheme;
  final String? heroImageUrl;
  final ValueChanged<String?>? onHeroImageChanged;
  final ValueChanged<bool> onThemeChanged;
  final TextEditingController? titleController;
  final TextEditingController? subtitleController;
  final TextEditingController? formTitleController;

  @override
  State<SettingsPanelView> createState() => _SettingsPanelViewState();
}

class _SettingsPanelViewState extends State<SettingsPanelView> {
  // final List<FormFields> _fields = [];
  int _tabIndex = 0;

  void _addField() {
    showDialog(
      context: context,
      builder: (context) {
        String fieldLabel = '';
        String fieldType = 'name';

        // Используем StatefulBuilder, чтобы обновлять состояние внутри диалога
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Добавить поле'),
              backgroundColor: AppTheme.background,
              content: SizedBox(
                width: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Показываем поле ввода только если это НЕ телефон
                    if (fieldType != 'phone') ...[
                      FFTextField(
                        hintText: 'Название поля',
                        onChanged: (value) => fieldLabel = value,
                      ),
                      const SizedBox(height: 16),
                    ],

                    DropdownButtonFormField<String>(
                      dropdownColor: AppTheme.fourty,
                      style: TextStyle(color: AppTheme.secondary),
                      value:
                          fieldType, // Используем value вместо initialValue для реактивности
                      decoration: const InputDecoration(labelText: 'Тип поля'),
                      items: const [
                        DropdownMenuItem(
                          value: 'name',
                          child: Row(
                            children: [
                              HeroIcon(HeroIcons.user, size: 20),
                              SizedBox(width: 8),
                              Text('Имя'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'email',
                          child: Row(
                            children: [
                              HeroIcon(HeroIcons.envelope, size: 20),
                              SizedBox(width: 8),
                              Text('Email'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'phone',
                          child: Row(
                            children: [
                              HeroIcon(HeroIcons.phone, size: 20),
                              SizedBox(width: 8),
                              Text('Номер телефона'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'text',
                          child: Row(
                            children: [
                              HeroIcon(
                                HeroIcons.chatBubbleOvalLeftEllipsis,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text('Текст (многострочный)'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        // Обновляем состояние диалога через setState из StatefulBuilder
                        setState(() {
                          if (value != null) fieldType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Максимум 25 символов',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              actions: [
                FFButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: 'Отмена',
                ),
                FFButton(
                  secondTheme: true,
                  onPressed: () {
                    if (fieldType == 'phone') {
                      fieldLabel = 'Телефон';
                    }

                    if (fieldLabel.isNotEmpty) {
                      // Используем setState родительского виджета (SettingsPanelView),
                      // чтобы обновить список полей на главном экране
                      this.setState(() {
                        widget.fields?.add(
                          FormFields(
                            label: fieldLabel,
                            type: fieldType,
                          ),
                        );
                      });
                      Navigator.pop(context);
                    }
                  },
                  text: 'Добавить',
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeField(int index) {
    setState(() {
      widget.fields?.removeAt(index);
    });
  }

  Widget _buildImageBlock() {
    return Consumer(
      builder: (context, ref, child) {
        debugPrint('Current form id: ${ref.watch(currentFormIdProvider)}');
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              width: 1.5,
              color: AppTheme.border,
            ),
          ),
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(
            16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Изображения',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              ImagePickerWidget(
                folder: ref.watch(currentFormIdProvider),
                imageUrl: widget.heroImageUrl,
                onImageUploaded: (imageUrl) =>
                    widget.onHeroImageChanged!(imageUrl),
                onImageDeleted: () {
                  if (widget.onHeroImageChanged != null) {
                    widget.onHeroImageChanged!(null);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOfferBlock() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          width: 1.5,
          color: AppTheme.border,
        ),
      ),
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Оффер и текст',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          FFTextField(
            hintText: 'Оффер',
            controller: widget.titleController,
          ),
          FFTextField(
            hintText: 'Текст (дополнительный)',
            controller: widget.subtitleController,
          ),
        ],
      ),
    );
  }

  Widget _buildFormTitleBlock() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          width: 1.5,
          color: AppTheme.border,
        ),
      ),
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Заголовок формы',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          FFTextField(
            hintText: 'Заголовок формы',
            controller: widget.formTitleController,
          ),
        ],
      ),
    );
  }

  Widget _buildInputsBlock() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          width: 1.5,
          color: AppTheme.border,
        ),
      ),
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Поля формы',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton.filled(
                onPressed: () {
                  _addField();
                },
                color: AppTheme.secondary,
                icon: HeroIcon(HeroIcons.plus),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          if (widget.fields!.isEmpty)
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.fourty,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Нет полей. Нажмите "Добавить поле"',
                  style: TextStyle(
                    color: AppTheme.secondary.withAlpha(50),
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              itemCount: widget.fields?.length,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                final field = widget.fields![index];
                return Card(
                  color: AppTheme.background,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(15),
                    side: BorderSide(
                      width: 1,
                      color: AppTheme.border,
                    ),
                  ),

                  child: ListTile(
                    leading: HeroIcon(
                      field.type == 'phone'
                          ? HeroIcons.phone
                          : field.type == 'text'
                          ? HeroIcons.chatBubbleOvalLeftEllipsis
                          : field.type == 'email'
                          ? HeroIcons.envelope
                          : HeroIcons.user,
                    ),
                    title: Text(field.label),
                    subtitle: Text(
                      field.type == 'phone' ? 'Телефон' : 'Текст',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _removeField(index);
                      },
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildThemeBlock() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          width: 1.5,
          color: AppTheme.border,
        ),
      ),
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(
        16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Темная тема',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 20),
          CupertinoSwitch(
            value: widget.isDarkTheme,

            activeTrackColor: AppTheme.primary,
            thumbColor: AppTheme.secondary,

            onChanged: (value) {
              widget.onThemeChanged(value);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: _tabIndex,
      child: Form(
        key: widget.formKey,
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Container(
                height: 40,

                decoration: BoxDecoration(
                  color: AppTheme.fourty,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TabBar(
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w800,

                    fontFamily: 'GoogleSans',
                  ),

                  overlayColor: WidgetStatePropertyAll(Colors.transparent),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppTheme.secondary,
                  unselectedLabelColor: AppTheme.secondary.withAlpha(50),
                  onTap: (value) {
                    setState(() {
                      _tabIndex = value;
                    });
                  },
                  indicator: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  tabs: [
                    Text('Контент'),
                    Text('Интеграция'),
                  ],
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: _tabIndex == 0
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,

                firstChild: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    _buildThemeBlock(),
                    _buildImageBlock(),
                    _buildOfferBlock(),
                    _buildFormTitleBlock(),
                    _buildInputsBlock(),
                  ],
                ),

                secondChild: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(child: Text("Настройки интеграций тут")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
