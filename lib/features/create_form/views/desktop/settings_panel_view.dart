import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/model/form_model.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/features/create_form/widgets/image_picker_widget.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_tabbar.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

class SettingsPanelView extends StatefulWidget {
  const SettingsPanelView({
    super.key,

    required this.tabIndex,

    this.fields,
    this.onFieldsChanged,
    this.formKey,
    this.formTitleController,
    this.subtitleController,
    this.titleController,
    this.titleFontSize = 42,
    this.subtitleFontSize = 22,
    this.titleFontSizeChanged,
    this.subtitleFontSizeChanged,

    required this.onThemeChanged,
    this.formTheme = 'light',
    this.buttonColor,
    this.actionType = 'button-url',
    this.onActionTypeChanged,
    this.onButtonColorChanged,
    this.formButtonColor,
    this.onFormButtonColorChanged,
    this.formButtonTextController,
    this.heroImageUrl,
    this.onHeroImageChanged,
    this.buttonTextController,
    this.successTextController,

    // redirect url
    this.hasRedirectUrl = false,
    this.onRedirectUrlValueChanged,
    this.focusNode,
  });

  final List<FormFields>? fields;
  final VoidCallback? onFieldsChanged;
  final GlobalKey<FormState>? formKey;

  final String? heroImageUrl;

  final ValueChanged<String?>? onHeroImageChanged;
  final ValueChanged<String?> onThemeChanged;

  final TextEditingController? titleController;
  final double titleFontSize;
  final ValueChanged<double>? titleFontSizeChanged;

  final TextEditingController? subtitleController;
  final double subtitleFontSize;
  final ValueChanged<double>? subtitleFontSizeChanged;
  final TextEditingController? formTitleController;

  final String formTheme;
  final TextEditingController? buttonTextController;
  final TextEditingController? formButtonTextController;
  final Color? formButtonColor;
  final ValueChanged<Color>? onFormButtonColorChanged;
  final String actionType;
  final ValueChanged<String?>? onActionTypeChanged;

  final Color? buttonColor;
  final ValueChanged<Color>? onButtonColorChanged;

  // form redirect url
  final bool hasRedirectUrl;
  final ValueChanged<bool>? onRedirectUrlValueChanged;

  // success text field options
  final FocusNode? focusNode;
  final TextEditingController? successTextController;

  // tab
  final int tabIndex;

  @override
  State<SettingsPanelView> createState() => _SettingsPanelViewState();
}

class _SettingsPanelViewState extends State<SettingsPanelView> {
  int _mainContentTabIndex = 0;

  Widget _buildThemeBlock() {
    return Container(
      width: context.screenWidth,
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Выберите тему',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          DropdownMenu(
            width: context.screenWidth,
            initialSelection: widget.formTheme,
            onSelected: (value) => widget.onThemeChanged(value),
            inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppTheme.border,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            menuStyle: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.white),
              maximumSize: WidgetStatePropertyAll(Size(300, 300)),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(10),
                  side: BorderSide.none,
                ),
              ),
            ),

            dropdownMenuEntries: [
              DropdownMenuEntry(value: 'dark', label: 'Темная тема'),
              DropdownMenuEntry(value: 'light', label: 'Светлая тема'),
            ],
          ),
        ],
      ),
    );
  }

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
                      initialValue:
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
                      setState(() {
                        widget.fields?.add(
                          FormFields(
                            label: fieldLabel,
                            type: fieldType,
                          ),
                        );
                      });
                      widget.onFieldsChanged?.call();
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

  Widget _buildMainContentBlock() {
    return Consumer(
      builder: (context, ref, child) {
        debugPrint('Current form id: ${ref.watch(currentFormIdProvider)}');
        return DefaultTabController(
          length: 2,
          child: Container(
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
                  'Контент',
                  style: TextStyle(
                    fontSize: 16,
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
            'Заголовок',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          FFTextField(
            hintText: 'Напишите заголовок',
            controller: widget.titleController,
          ),
          const SizedBox(
            width: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Размер текст',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    width: 1.5,
                    color: AppTheme.border,
                  ),
                ),
                padding: EdgeInsets.all(8),
                child: Text(
                  '${widget.titleFontSize} px',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: widget.titleFontSize,
            allowedInteraction: SliderInteraction.tapAndSlide,
            max: 42,
            min: 24,
            divisions: 18,
            thumbColor: AppTheme.secondary,
            padding: EdgeInsets.only(top: 16),
            label: widget.titleFontSize.toString(),
            onChanged: widget.titleFontSizeChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionBlock() {
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
            'Описание',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          FFTextField(
            hintText: 'Напишите описание',
            controller: widget.subtitleController,
          ),
          const SizedBox(
            width: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Размер текст',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    width: 1.5,
                    color: AppTheme.border,
                  ),
                ),
                padding: EdgeInsets.all(8),
                child: Text(
                  '${widget.subtitleFontSize} px',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: widget.subtitleFontSize,
            allowedInteraction: SliderInteraction.tapAndSlide,
            max: 22,
            min: 12,
            divisions: 10,
            thumbColor: AppTheme.secondary,
            padding: EdgeInsets.only(top: 16),
            label: widget.subtitleFontSize.toString(),
            onChanged: widget.subtitleFontSizeChanged!,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTypeBlock() {
    return Container(
      width: context.screenWidth,
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Выберите тип действии',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          DropdownMenu(
            width: context.screenWidth,
            initialSelection: widget.actionType,
            onSelected: (value) => widget.onActionTypeChanged!(value),
            inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppTheme.border,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            menuStyle: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.white),
              maximumSize: WidgetStatePropertyAll(Size(300, 300)),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(10),
                  side: BorderSide.none,
                ),
              ),
            ),

            dropdownMenuEntries: [
              DropdownMenuEntry(
                value: 'button-url',
                label: 'Кнопка сo ссылкой',
              ),
              DropdownMenuEntry(
                value: 'form',
                label: 'Форма',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTypeWidget() {
    // BUTTON-URL
    Widget buttonUrlWidget() {
      return Container(
        width: context.screenWidth,
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Настройки кнопки',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            FFTextField(
              hintText: 'Текст в кнопке',
              controller: widget.buttonTextController,
              maxLength: 30,
              prefixIcon: HeroIcon(
                HeroIcons.listBullet,
              ),
            ),
            FFTextField(
              hintText: 'URL (ссылка)',
              prefixIcon: HeroIcon(
                HeroIcons.link,
              ),
            ),

            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: AppTheme.background,
                      title: Text(
                        'Выберите цвет',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: BlockPicker(
                        pickerColor: widget.buttonColor,
                        onColorChanged: (value) {
                          widget.onButtonColorChanged!(value);

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        availableColors: [
                          Colors.red,
                          Colors.pink,
                          Colors.purple,
                          Colors.deepPurple,

                          Colors.indigo,
                          Colors.blue,
                          Colors.lightBlue,
                          Colors.cyan,
                          Colors.teal,
                          Colors.green,
                          Colors.lightGreen,
                          Colors.orange,
                          Colors.deepOrange,
                          Colors.brown,
                          Colors.amber,
                          Colors.blueAccent,
                          Colors.blueGrey,
                          Colors.black,
                        ],
                      ),
                    );
                  },
                );
              },
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Выберите цвет',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.buttonColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget formWidget() {
      return Container(
        width: context.screenWidth,
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Настройки формы',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            FFTextField(
              prefixIcon: HeroIcon(HeroIcons.documentText),
              hintText: 'Заполните форму ...',
              title: 'Заголовoк формы',
              controller: widget.formTitleController,
            ),
            _buildInputsBlock(),

            FFTextField(
              hintText: 'например, Регистрация',
              title: 'Текст в кнопке',
              controller: widget.formButtonTextController,
              maxLength: 30,
              prefixIcon: HeroIcon(
                HeroIcons.bold,
              ),
            ),
            FFTextField(
              hintText: '',
              title: 'Сообщение после успешной отправки формы',

              focusNode: widget.focusNode,
              controller: widget.successTextController,

              prefixIcon: HeroIcon(
                HeroIcons.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Redirect URL',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Tooltip(
                        margin: EdgeInsets.only(right: 1000, left: 16),
                        message:
                            'Автоматическая переадресация позволяет мгновенно переводить клиента в удобный мессенджер (WhatsApp, Telegram) или на страницу с бонусом сразу после того, как он оставил свои данные. Это сокращает путь клиента и повышает вероятность успешной сделки.',

                        child: Opacity(
                          opacity: 0.5,
                          child: Row(
                            children: [
                              HeroIcon(
                                HeroIcons.informationCircle,
                                size: 15,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                'Для чего это нужно?',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                CupertinoSwitch(
                  value: widget.hasRedirectUrl,
                  activeTrackColor: AppTheme.primary,

                  onChanged: widget.onRedirectUrlValueChanged,
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            if (widget.hasRedirectUrl == true)
              FFTextField(
                hintText: 'например, WhatsApp, Telegram',
                title: 'Ссылка на перенаправление',

                prefixIcon: HeroIcon(
                  HeroIcons.link,
                ),
              ),

            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: AppTheme.background,
                      title: Text(
                        'Выберите цвет кнопки',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: BlockPicker(
                        pickerColor: widget.formButtonColor,
                        onColorChanged: (value) {
                          widget.onFormButtonColorChanged!(value);

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        availableColors: [
                          Colors.red,
                          Colors.pink,
                          Colors.purple,
                          Colors.deepPurple,

                          Colors.indigo,
                          Colors.blue,
                          Colors.lightBlue,
                          Colors.cyan,
                          Colors.teal,
                          Colors.green,
                          Colors.lightGreen,
                          Colors.orange,
                          Colors.deepOrange,
                          Colors.brown,
                          Colors.amber,
                          Colors.blueAccent,
                          Colors.blueGrey,
                          Colors.black,
                        ],
                      ),
                    );
                  },
                );
              },
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Выберите цвет',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.formButtonColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedCrossFade(
      // Action type == button-url
      firstChild: buttonUrlWidget(),
      // Action type == form
      secondChild: formWidget(),
      crossFadeState: widget.actionType == 'button-url'
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: Duration(milliseconds: 100),
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
                  fontSize: 16,
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

  Widget _buildSuccessTextBlock() {
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
            'Текст успешной формы',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          FFTextField(
            hintText: 'Введите текст',
            controller: widget.successTextController,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int tabIndex = widget.tabIndex;
    return Form(
      key: widget.formKey,
      child: SizedBox(
        width: 350,
        child: AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: tabIndex == 0
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,

          firstChild: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              _buildThemeBlock(),
              _buildMainContentBlock(),
              _buildOfferBlock(),
              _buildDescriptionBlock(),
              _buildActionTypeBlock(),
              _buildActionTypeWidget(),
              // _buildFormTitleBlock(),
              // _buildInputsBlock(),
              // _buildButtonSettingsBlock(),
              // _buildSuccessTextBlock(),
            ],
          ),

          secondChild: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(child: Text("Настройки интеграций тут")),
            ],
          ),
        ),
      ),
    );
  }
}
