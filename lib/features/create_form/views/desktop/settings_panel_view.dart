import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/features/create_form/widgets/image_picker_widget.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_tabbar.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

class SettingsPanelView extends ConsumerStatefulWidget {
  const SettingsPanelView({
    super.key,

    // Контроллеры оставляем, так как они управляются родителем для синхронизации
    required this.titleController,
    required this.subtitleController,
    this.formTitleController,
    this.buttonTextController,
    this.formButtonTextController,
    this.successTextController,
    this.buttonUrlController,
    required this.focusNode,
  });

  final TextEditingController titleController;
  final TextEditingController subtitleController;
  final TextEditingController? formTitleController;
  final TextEditingController? buttonTextController;
  final TextEditingController? formButtonTextController;
  final TextEditingController? successTextController;
  final TextEditingController? buttonUrlController;
  final FocusNode focusNode;

  @override
  ConsumerState<SettingsPanelView> createState() => _SettingsPanelViewState();
}

class _SettingsPanelViewState extends ConsumerState<SettingsPanelView>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Подписываемся на стейт
    final formState = ref.watch(createFormProvider);
    final controller = ref.read(createFormProvider.notifier);

    return SizedBox(
      width: 350,
      child: Column(
        children: [
          FFTabBar(
            tabs: [
              Text('Контент'),
              Text('Footer'),
              Text('Интеграция'),
            ],
            controller: _tabController,
            onTap: (index) {
              setState(() {
                _tabIndex = index;
              });
            },
          ),
          const SizedBox(
            height: 16,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Form(
                key: _formKey,
                child: SizedBox(
                  width: 350,
                  child: AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _tabIndex == 0
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,

                    // Вкладка "Контент"
                    firstChild: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildThemeBlock(context, formState.theme, controller),
                        _buildMainContentBlock(
                          context,
                          ref,
                          formState.heroImageUrl,
                        ),
                        _buildOfferBlock(context, formState, controller),
                        _buildDescriptionBlock(context, formState, controller),
                        _buildActionTypeBlock(
                          context,
                          formState.actionType!,
                          controller,
                        ),
                        _buildActionTypeWidget(context, formState, controller),
                      ],
                    ),

                    // Вкладка "Интеграции" (пока пустая)
                    secondChild: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Center(child: Text("Настройки интеграций тут")),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- БЛОКИ ИНТЕРФЕЙСА ---
  Widget _buildThemeBlock(
    BuildContext context,
    String currentTheme,
    CreateFormController controller,
  ) {
    return Container(
      width: context.screenWidth,
      decoration: _blockDecoration(),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Выберите тему',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownMenu(
            width: 350,

            initialSelection: currentTheme,
            menuStyle: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(AppTheme.background),
              maximumSize: WidgetStatePropertyAll(Size.square(300)),
              minimumSize: WidgetStatePropertyAll(Size.square(200)),
            ),
            onSelected: (value) {
              if (value != null) controller.updateTheme(value);
            },
            inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.border),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'dark', label: 'Темная тема'),
              DropdownMenuEntry(value: 'light', label: 'Светлая тема'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContentBlock(
    BuildContext context,
    WidgetRef ref,
    String? heroImageUrl,
  ) {
    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: _blockDecoration(),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Контент',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ImagePicker сам внутри работает с контроллерами,
            // но мы передаем текущий URL и колбэки для обновления стейта редактора
            ImagePickerWidget(
              // folder: formId - можно получить из провайдера, если нужно
              imageUrl: heroImageUrl,
              onImageUploaded: (url) =>
                  ref.read(createFormProvider.notifier).updateHeroImage(url),
              onImageDeleted: () =>
                  ref.read(createFormProvider.notifier).updateHeroImage(null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferBlock(
    BuildContext context,
    dynamic formState,
    CreateFormController controller,
  ) {
    return Container(
      decoration: _blockDecoration(),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Заголовок',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          FFTextField(
            hintText: 'Напишите заголовок',
            onChanged: (value) => controller.updateTitle(value),
            controller: widget
                .titleController, // Используем контроллер переданный из родителя
          ),
          const SizedBox(width: 8),
          _buildSizeSlider(
            label: 'Размер текста',
            value: formState.titleFontSize,
            max: 42,
            min: 24,
            onChanged: (val) => controller.updateTitleFontSize(val),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionBlock(
    BuildContext context,
    dynamic formState,
    CreateFormController controller,
  ) {
    return Container(
      decoration: _blockDecoration(),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Описание',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          FFTextField(
            hintText: 'Напишите описание',
            controller: widget.subtitleController,
            onChanged: (value) {
              controller.updateSubtitle(value);
            },
          ),
          const SizedBox(width: 8),
          _buildSizeSlider(
            label: 'Размер текста',
            value: formState.subtitleFontSize,
            max: 22,
            min: 12,
            onChanged: (val) => controller.updateSubtitleFontSize(val),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTypeBlock(
    BuildContext context,
    String currentType,
    CreateFormController controller,
  ) {
    return Container(
      width: context.screenWidth,
      decoration: _blockDecoration(),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Выберите тип действия',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownMenu(
            width: 350,

            initialSelection: currentType,
            onSelected: (value) {
              if (value != null) controller.updateActionType(value);
            },
            menuStyle: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(AppTheme.background),
              maximumSize: WidgetStatePropertyAll(Size.square(300)),
              minimumSize: WidgetStatePropertyAll(Size.square(200)),
            ),
            inputDecorationTheme: InputDecorationTheme(
              fillColor: AppTheme.background,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.border),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            dropdownMenuEntries: const [
              DropdownMenuEntry(
                value: 'button-url',
                label: 'Кнопка со ссылкой',
              ),
              DropdownMenuEntry(value: 'form', label: 'Форма'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTypeWidget(
    BuildContext context,
    dynamic formState,
    CreateFormController controller,
  ) {
    return AnimatedCrossFade(
      firstChild: _buildButtonUrlWidget(context, formState, controller),
      secondChild: _buildFormWidget(context, formState, controller),
      crossFadeState: formState.actionType == 'button-url'
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 100),
    );
  }

  // --- ПОД-ВИДЖЕТЫ ДЛЯ BUTTON-URL ---
  Widget _buildButtonUrlWidget(
    BuildContext context,
    dynamic formState,
    CreateFormController controller,
  ) {
    return Container(
      width: context.screenWidth,
      decoration: _blockDecoration(),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Настройки кнопки',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FFTextField(
            hintText: 'Текст в кнопке',
            controller: widget.buttonTextController,
            onChanged: (value) => controller.updateButtonText(value),
            maxLength: 30,
            prefixIcon: const HeroIcon(HeroIcons.listBullet),
          ),
          FFTextField(
            hintText: 'URL (ссылка)',
            prefixIcon: const HeroIcon(HeroIcons.link),
            controller: widget.buttonUrlController,
            onChanged: (value) => controller.updateButtonUrl(value),
          ),
          _buildColorPickerRow(
            context: context,
            currentColor: formState.buttonColor,
            onColorChanged: (color) => controller.updateButtonColor(color),
          ),
        ],
      ),
    );
  }

  // --- ПОД-ВИДЖЕТЫ ДЛЯ FORM ---
  Widget _buildFormWidget(
    BuildContext context,
    dynamic formState,
    CreateFormController controller,
  ) {
    return Container(
      width: context.screenWidth,
      decoration: _blockDecoration(),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Настройки формы',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FFTextField(
            prefixIcon: const HeroIcon(HeroIcons.documentText),
            hintText: 'Заполните форму ...',
            title: 'Заголовок формы',
            controller: widget.formTitleController,
            onChanged: (value) => controller.updateFormTitle(value),
          ),

          _buildFieldsList(context, formState.fields, controller),

          FFTextField(
            hintText: 'например, Регистрация',
            title: 'Текст в кнопке',
            controller: widget.formButtonTextController,
            onChanged: (value) => controller.updateFormButtonText(value),
            maxLength: 30,
            prefixIcon: const HeroIcon(HeroIcons.bold),
          ),
          FFTextField(
            hintText: '',
            title: 'Сообщение после успешной отправки',
            focusNode: widget.focusNode,
            controller: widget.successTextController,
            onChanged: (value) => controller.updateSuccessText(value),
            prefixIcon: const HeroIcon(HeroIcons.bold),
          ),

          // Redirect Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Redirect URL', style: TextStyle(fontSize: 16)),
                  // Tooltip можно сократить для чистоты
                ],
              ),
              CupertinoSwitch(
                value: formState.hasRedirectUrl,
                activeTrackColor: AppTheme.primary,
                onChanged: (val) => controller.updateHasRedirectUrl(val),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (formState.hasRedirectUrl)
            FFTextField(
              hintText: 'например, WhatsApp...',
              title: 'Ссылка на перенаправление',
              prefixIcon: const HeroIcon(HeroIcons.link),
              onChanged: (value) => controller.updateFormRedirectUrl(value),
              // onChanged: (val) => controller.updateRedirectUrl(val),
            ),

          _buildColorPickerRow(
            context: context,
            currentColor: formState.formButtonColor,
            onColorChanged: (color) => controller.updateFormButtonColor(color),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsList(
    BuildContext context,
    List<dynamic> fields,
    CreateFormController controller,
  ) {
    return Container(
      decoration: _blockDecoration(),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Поля формы',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton.filled(
                onPressed: () => _showAddFieldDialog(context, controller),
                color: AppTheme.secondary,
                icon: const HeroIcon(HeroIcons.plus),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (fields.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.fourty,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Нет полей',
                  style: TextStyle(color: AppTheme.secondary.withAlpha(50)),
                ),
              ),
            )
          else
            ListView.builder(
              itemCount: fields.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final field = fields[index];
                return Card(
                  color: AppTheme.background,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(width: 1, color: AppTheme.border),
                  ),
                  child: ListTile(
                    leading: HeroIcon(_getIconForFieldType(field.type)),
                    title: Text(field.label),
                    subtitle: Text(field.type == 'phone' ? 'Телефон' : 'Текст'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => controller.removeField(index),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  BoxDecoration _blockDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      color: AppTheme.background,
      border: Border.all(width: 1.5, color: AppTheme.border),
    );
  }

  HeroIcons _getIconForFieldType(String type) {
    switch (type) {
      case 'phone':
        return HeroIcons.phone;
      case 'email':
        return HeroIcons.envelope;
      case 'text':
        return HeroIcons.chatBubbleOvalLeftEllipsis;
      default:
        return HeroIcons.user;
    }
  }

  Widget _buildSizeSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(width: 1.5, color: AppTheme.border),
              ),
              padding: const EdgeInsets.all(8),
              child: Text(
                '${value.toInt()} px',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          thumbColor: AppTheme.secondary,
          label: value.toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildColorPickerRow({
    required BuildContext context,
    required Color currentColor,
    required ValueChanged<Color> onColorChanged,
  }) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.background,
            title: const Text('Выберите цвет'),
            content: BlockPicker(
              pickerColor: currentColor,
              onColorChanged: (color) {
                onColorChanged(color);
                Navigator.pop(context); // Закрываем при выборе
              },
              availableColors: const [
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
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Выберите цвет', style: TextStyle(fontSize: 16)),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFieldDialog(
    BuildContext context,
    CreateFormController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        String fieldLabel = '';
        String fieldType = 'name';

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
                      value: fieldType,
                      decoration: const InputDecoration(labelText: 'Тип поля'),
                      items: const [
                        DropdownMenuItem(value: 'name', child: Text('Имя')),
                        DropdownMenuItem(value: 'email', child: Text('Email')),
                        DropdownMenuItem(
                          value: 'phone',
                          child: Text('Номер телефона'),
                        ),
                        DropdownMenuItem(value: 'text', child: Text('Текст')),
                      ],
                      onChanged: (value) => setState(() => fieldType = value!),
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
                  text: 'Добавить',
                  onPressed: () {
                    if (fieldType == 'phone') fieldLabel = 'Телефон';
                    if (fieldLabel.isNotEmpty) {
                      // Вызываем контроллер Riverpod!
                      controller.addField(fieldLabel, fieldType);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
