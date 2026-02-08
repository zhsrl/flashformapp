import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

class BuildActionsBlock extends ConsumerWidget {
  const BuildActionsBlock({
    super.key,
    required this.currentType,
    required this.controller,
    required this.focusNode,
    required this.formState,
    required this.uiControllers,
  });

  final String currentType;
  final CreateFormController controller;
  final FormUIControllers uiControllers;
  final FocusNode focusNode;
  final dynamic formState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Action type
        Container(
          width: context.screenWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: AppTheme.background,
            border: Border.all(width: 1.5, color: AppTheme.border),
          ),
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
                  ref.read(createFormProvider.notifier).markAsChanged();
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
                  DropdownMenuEntry(
                    value: 'form',
                    label: 'Форма',
                  ),
                ],
              ),
            ],
          ),
        ),

        _buildActionTypeWidget(
          context,
          formState,
          controller,
          uiControllers,
          ref,
        ),
      ],
    );
  }

  Widget _buildActionTypeWidget(
    BuildContext context,
    dynamic formState,
    CreateFormController controller,
    FormUIControllers uiControllers,
    WidgetRef ref,
  ) {
    return AnimatedCrossFade(
      firstChild: _buildButtonUrlWidget(
        context,
        formState,
        controller,
        uiControllers,
        ref,
      ),
      secondChild: _buildFormWidget(
        context,
        formState,
        controller,
        uiControllers,
        ref,
      ),
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
    FormUIControllers uiControllers,
    WidgetRef ref,
  ) {
    return Container(
      width: context.screenWidth,
      decoration: _buildBlocksDecotration(),
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
            controller: uiControllers.buttonTextController,
            onChanged: (value) => {
              controller.updateButtonText(value),
              ref.read(createFormProvider.notifier).markAsChanged(),
            },
            maxLength: 30,
            prefixIcon: const HeroIcon(HeroIcons.listBullet),
          ),
          FFTextField(
            hintText: 'URL (ссылка)',
            prefixIcon: const HeroIcon(HeroIcons.link),
            controller: uiControllers.buttonUrlController,
            onChanged: (value) => {
              controller.updateButtonUrl(value),
              ref.read(createFormProvider.notifier).markAsChanged(),
            },
          ),
          _buildColorPickerRow(
            context: context,
            currentColor: formState.buttonColor,
            onColorChanged: (color) => {
              controller.updateButtonColor(color),
              ref.read(createFormProvider.notifier).markAsChanged(),
            },
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
    FormUIControllers uiControllers,
    WidgetRef ref,
  ) {
    return Container(
      width: context.screenWidth,
      decoration: _buildBlocksDecotration(),
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
            controller: uiControllers.formTitleController,
            onChanged: (value) => {
              controller.updateFormTitle(value),
              ref.read(createFormProvider.notifier).markAsChanged(),
            },
          ),

          _buildFieldsList(context, formState.fields, controller),

          FFTextField(
            hintText: 'например, Регистрация',
            title: 'Текст в кнопке',
            controller: uiControllers.formButtonTextController,
            onChanged: (value) => {
              controller.updateFormButtonText(value),
              ref.read(createFormProvider.notifier).markAsChanged(),
            },
            maxLength: 30,
            prefixIcon: const HeroIcon(HeroIcons.bold),
          ),
          FFTextField(
            hintText: '',
            title: 'Сообщение после успешной отправки',
            focusNode: focusNode,
            controller: uiControllers.successTextController,
            onChanged: (value) => {
              controller.updateSuccessText(value),
              ref.read(createFormProvider.notifier).markAsChanged(),
            },
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
                onChanged: (val) => {
                  controller.updateHasRedirectUrl(val),
                  ref.read(createFormProvider.notifier).markAsChanged(),
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (formState.hasRedirectUrl)
            FFTextField(
              hintText: 'например, WhatsApp...',
              title: 'Ссылка на перенаправление',
              controller: uiControllers.formRedirectUrlController,
              prefixIcon: const HeroIcon(HeroIcons.link),
              onChanged: (value) => {
                controller.updateFormRedirectUrl(value),
                ref.read(createFormProvider.notifier).markAsChanged(),
              },
              // onChanged: (val) => controller.updateRedirectUrl(val),
            ),

          _buildColorPickerRow(
            context: context,
            currentColor: formState.formButtonColor,
            onColorChanged: (color) => {
              controller.updateFormButtonColor(color),
              ref.read(createFormProvider.notifier).markAsChanged(),
            },
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
      decoration: _buildBlocksDecotration(),
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

  BoxDecoration _buildBlocksDecotration() {
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
