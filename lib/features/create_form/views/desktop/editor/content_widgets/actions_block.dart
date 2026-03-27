import 'package:easy_localization/easy_localization.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

class BuildActionsBlock extends ConsumerStatefulWidget {
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
  ConsumerState<BuildActionsBlock> createState() => _BuildActionsBlockState();
}

class _BuildActionsBlockState extends ConsumerState<BuildActionsBlock> {
  late Set<String> _successFormActionSelect;

  @override
  void initState() {
    super.initState();
    // Восстановляем выбор из контроллера
    final savedAction = widget.formState.successAction ?? 'thx';
    _successFormActionSelect = {savedAction};
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Action type
        Container(
          width: context.screenWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
            border: Border.all(width: 1.5, color: AppTheme.border),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'forms.choose_action_type'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownMenu(
                width: 350,

                initialSelection: widget.currentType,
                onSelected: (value) {
                  if (value != null) widget.controller.updateActionType(value);
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
                dropdownMenuEntries: [
                  DropdownMenuEntry(
                    value: 'button-url',
                    label: 'forms.action_type_button_url'.tr(),
                  ),
                  DropdownMenuEntry(
                    value: 'form',
                    label: 'forms.action_type_form'.tr(),
                  ),
                ],
              ),
            ],
          ),
        ),

        _buildActionTypeWidget(
          context,
          widget.formState,
          widget.controller,
          widget.uiControllers,
          ref,
        ),
        _buildActionAfterSuccessForm(
          context,
          widget.formState,
          widget.controller,
          widget.uiControllers,
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
          Text(
            'forms.button_settings'.tr(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          FFTextField(
            hintText: 'forms.button_text'.tr(),

            controller: uiControllers.buttonTextController,
            onChanged: (value) => {
              controller.updateButtonText(value),
              ref.read(createFormProvider.notifier).markAsChanged(),
            },
          ),
          FFTextField(
            hintText: 'forms.url'.tr(),
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
          Text(
            'forms.form_settings'.tr(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FFTextField(
            prefixIcon: const HeroIcon(HeroIcons.documentText),
            hintText: 'forms.fill_form_placeholder'.tr(),
            title: 'forms.form_title'.tr(),
            controller: uiControllers.formTitleController,
            onChanged: (value) => {
              controller.updateFormTitle(value),
              ref.read(createFormProvider.notifier).markAsChanged(),
            },
          ),

          _buildFieldsList(context, formState.fields, controller),

          FFTextField(
            hintText: 'forms.button_text_example_registration'.tr(),
            title: 'forms.button_text'.tr(),
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
            title: 'forms.success_message_after_submit'.tr(),
            focusNode: widget.focusNode,
            controller: uiControllers.successTextController,
            onChanged: (value) => {
              controller.updateSuccessText(value),
              ref.read(createFormProvider.notifier).markAsChanged(),
            },
            prefixIcon: const HeroIcon(HeroIcons.bold),
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

  Widget _buildActionAfterSuccessForm(
    BuildContext context,
    dynamic formState,
    CreateFormController controller,
    FormUIControllers uiControllers,
    WidgetRef ref,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Text(
            'forms.success_action_type'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          SegmentedButton(
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppTheme.primary,
              selectedForegroundColor: AppTheme.secondary,
            ),
            showSelectedIcon: false,
            expandedInsets: EdgeInsets.all(0),
            onSelectionChanged: (value) {
              setState(() {
                _successFormActionSelect = value;
              });
              // Сохраняем в контроллер
              final selectedAction = value.isNotEmpty ? value.first : 'thx';
              widget.controller.updateSuccessAction(selectedAction);
              ref.read(createFormProvider.notifier).markAsChanged();
            },
            segments: <ButtonSegment<String>>[
              ButtonSegment<String>(
                value: 'whatsapp',
                label: Text('forms.action_whatsapp'.tr()),
                enabled: true,
              ),
              ButtonSegment<String>(
                value: 'redirect',
                label: Text('forms.action_redirect'.tr()),
                enabled: true,
              ),
              ButtonSegment<String>(
                value: 'thx',
                label: Text('forms.action_thank_you_page'.tr()),
                enabled: true,
              ),
            ],
            selected: _successFormActionSelect,
          ),

          const SizedBox(
            height: 16,
          ),

          // WHATSAPP
          if (_successFormActionSelect.contains('whatsapp'))
            Column(
              children: [
                FFTextField(
                  hintText: '7771234567',
                  controller: uiControllers.whatsappNumberController,
                  title: 'forms.phone_without_code'.tr(),
                  prefixIcon: HeroIcon(HeroIcons.phone),
                  onChanged: (value) => {
                    widget.controller.updateWhatsappNumber(value),
                    ref.read(createFormProvider.notifier).markAsChanged(),
                  },
                ),
                FFTextField(
                  title: 'forms.whatsapp_message_text'.tr(),
                  hintText: 'forms.whatsapp_message_placeholder'.tr(),
                  prefixIcon: HeroIcon(HeroIcons.chatBubbleOvalLeft),
                  controller: uiControllers.whatsappMessageController,
                  onChanged: (value) => {
                    widget.controller.updateWhatsappMessage(value),
                    ref.read(createFormProvider.notifier).markAsChanged(),
                  },
                ),
              ],
            ),

          // REDIRECT
          if (_successFormActionSelect.contains('redirect'))
            Column(
              children: [
                FFTextField(
                  hintText: 'forms.redirect_placeholder'.tr(),
                  title: 'forms.redirect_url'.tr(),
                  controller: uiControllers.formRedirectUrlController,
                  prefixIcon: const HeroIcon(HeroIcons.link),
                  onChanged: (value) => {
                    controller.updateFormRedirectUrl(value),
                    ref.read(createFormProvider.notifier).markAsChanged(),
                  },
                ),
              ],
            ),

          if (_successFormActionSelect.contains('thx'))
            Column(
              children: [
                FFTextField(
                  hintText: 'forms.thx_title_placeholder'.tr(),
                  title: 'forms.thx_title_label'.tr(),
                  controller: uiControllers.thxTitleController,
                  onChanged: (value) => {
                    widget.controller.updateThxTitle(value),
                    ref.read(createFormProvider.notifier).markAsChanged(),
                  },
                ),
                FFTextField(
                  hintText: 'forms.thx_description_placeholder'.tr(),
                  title: 'forms.thx_description_label'.tr(),
                  controller: uiControllers.thxDescriptionController,
                  onChanged: (value) => {
                    widget.controller.updateThxDescription(value),
                    ref.read(createFormProvider.notifier).markAsChanged(),
                  },
                ),
              ],
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
              Text(
                'forms.form_fields'.tr(),
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
                  'forms.no_fields'.tr(),
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
                    subtitle: Text(
                      field.type == 'phone'
                          ? 'forms.field_type_phone'.tr()
                          : 'forms.field_type_text'.tr(),
                    ),
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
      color: Colors.white,
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
            title: Text('forms.choose_color'.tr()),
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
            Text('forms.choose_color'.tr(), style: TextStyle(fontSize: 16)),
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
              title: Text('forms.add_field'.tr()),
              backgroundColor: Colors.white,
              content: SizedBox(
                width: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (fieldType != 'phone') ...[
                      FFTextField(
                        hintText: 'forms.field_name'.tr(),
                        onChanged: (value) => fieldLabel = value,
                      ),
                      const SizedBox(height: 16),
                    ],
                    DropdownButtonFormField<String>(
                      dropdownColor: AppTheme.fourty,
                      style: TextStyle(color: AppTheme.secondary),
                      value: fieldType,
                      decoration: InputDecoration(
                        labelText: 'forms.field_type'.tr(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'name',
                          child: Text('forms.field_name_option'.tr()),
                        ),
                        DropdownMenuItem(
                          value: 'email',
                          child: Text('forms.field_email_option'.tr()),
                        ),
                        DropdownMenuItem(
                          value: 'phone',
                          child: Text('forms.field_phone_option'.tr()),
                        ),
                        DropdownMenuItem(
                          value: 'text',
                          child: Text('forms.field_text_option'.tr()),
                        ),
                      ],
                      onChanged: (value) => setState(() => fieldType = value!),
                    ),
                  ],
                ),
              ),
              actions: [
                FFButton(
                  onPressed: () => Navigator.pop(context),
                  text: 'common.cancel'.tr(),
                ),
                FFButton(
                  secondTheme: true,
                  text: 'common.add'.tr(),
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
