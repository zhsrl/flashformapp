import 'package:easy_localization/easy_localization.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/data/model/create_form_state.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

class SettingsFormWidget extends ConsumerStatefulWidget {
  const SettingsFormWidget({
    super.key,
    this.formState,
    this.controller,
    this.uiControllers,
  });

  final dynamic formState;
  final CreateFormController? controller;
  final FormUIControllers? uiControllers;

  @override
  ConsumerState<SettingsFormWidget> createState() => _SettingsFormWidgetState();
}

class _SettingsFormWidgetState extends ConsumerState<SettingsFormWidget> {
  final List<Map<String, dynamic>> _fieldList = [
    {
      'icon': HeroIcons.envelope,
      'title': 'Email',
      'type': 'email',
    },
    {
      'icon': HeroIcons.phone,
      'title': 'Номер телефона',
      'type': 'phone',
    },
    {
      'icon': HeroIcons.user,
      'title': 'Имя',
      'type': 'name',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final CreateFormState formState =
        widget.formState ?? ref.watch(createFormProvider);
    final successAction = formState.successAction ?? 'thx';
    final successSelection = {successAction};
    final fields = formState.fields;
    final CreateFormController controller =
        widget.controller ?? ref.read(createFormProvider.notifier);
    final FormUIControllers uiControllers =
        widget.uiControllers ?? ref.watch(formUIControllersProvider);
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: context.screenWidth,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          border: Border.all(width: 1.5, color: AppTheme.border),
        ),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            FFTextField(
              title: 'Заголовок формы',
              controller: uiControllers.formTitleController,
            ),
            FFTextField(
              hintText: 'Кнопка',
              title: 'Текст кнопки',
              controller: uiControllers.formButtonTextController,
            ),
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  'Поля ввода',
                  style: TextStyle(
                    fontWeight: .w500,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    showAddInputFieldDialog(controller);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.secondary,
                  ),
                  icon: Icon(Icons.add),
                  label: Text('Добавить поле'),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            if (fields.isNotEmpty)
              ReorderableListView.builder(
                shrinkWrap: true,
                buildDefaultDragHandles: false,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fields.length,
                padding: .zero,
                onReorder: (oldIndex, newIndex) {
                  controller.reorderField(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final field = fields[index];
                  return InputFieldOptions(
                    title: field.label,
                    type: field.type,
                    id: field.id,
                    onRemove: () => controller.removeField(index),
                    key: ValueKey(field),
                    index: index,
                    isRequired: field.requiredField,
                    onRequiredChanged: (value) =>
                        controller.updateFieldRequired(index, value),
                    onLabelChanged: (label) =>
                        controller.updateFieldLabel(index, label),
                  );
                },
              ),

            // _buildActionTypeWidget(
            //   context,
            //   formState,
            //   controller,
            //   uiControllers,
            //   ref,
            // ),
            _buildActionAfterSuccessForm(
              context,
              formState,
              controller,
              uiControllers,
              ref,
              successSelection,
            ),
          ],
        ),
      ),
    );
  }

  void showAddInputFieldDialog(CreateFormController controller) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Text('Выберите тип поле'),
          content: SizedBox(
            width: 400,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _fieldList.length,
              itemBuilder: (context, index) {
                final inputField = _fieldList[index];
                final label = inputField['title'] as String;
                final type = inputField['type'] as String;
                return InputFieldItem(
                  icon: inputField['icon'],
                  title: inputField['title'],
                  onTap: () {
                    controller.addField(label, type);

                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionAfterSuccessForm(
    BuildContext context,
    dynamic formState,
    CreateFormController controller,
    FormUIControllers uiControllers,
    WidgetRef ref,
    Set<String> successSelection,
  ) {
    return Container(
      // padding: EdgeInsets.all(16),
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
              final selectedAction = value.isNotEmpty ? value.first : 'thx';
              controller.updateSuccessAction(selectedAction);
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
            selected: successSelection,
          ),

          const SizedBox(
            height: 16,
          ),

          // WHATSAPP
          if (successSelection.first == 'whatsapp')
            Column(
              children: [
                FFTextField(
                  hintText: '7771234567',
                  controller: uiControllers.whatsappNumberController,
                  title: 'forms.phone_without_code'.tr(),
                  prefixIcon: HeroIcon(HeroIcons.phone),
                  onChanged: (value) {
                    ref.read(createFormProvider.notifier).markAsChanged();
                  },
                ),
                FFTextField(
                  title: 'forms.whatsapp_message_text'.tr(),
                  hintText: 'forms.whatsapp_message_placeholder'.tr(),
                  prefixIcon: HeroIcon(HeroIcons.chatBubbleOvalLeft),
                  controller: uiControllers.whatsappMessageController,
                  onChanged: (value) {
                    ref.read(createFormProvider.notifier).markAsChanged();
                  },
                ),
              ],
            ),

          // REDIRECT
          if (successSelection.first == 'redirect')
            Column(
              children: [
                FFTextField(
                  hintText: 'forms.redirect_placeholder'.tr(),
                  title: 'forms.redirect_url'.tr(),
                  controller: uiControllers.formRedirectUrlController,
                  prefixIcon: const HeroIcon(HeroIcons.link),
                  onChanged: (value) {
                    ref.read(createFormProvider.notifier).markAsChanged();
                  },
                ),
              ],
            ),

          if (successSelection.first == 'thx')
            Column(
              children: [
                FFTextField(
                  hintText: 'forms.thx_title_placeholder'.tr(),
                  title: 'forms.thx_title_label'.tr(),
                  controller: uiControllers.thxTitleController,
                  onChanged: (value) {
                    ref.read(createFormProvider.notifier).markAsChanged();
                  },
                ),
                FFTextField(
                  hintText: 'forms.thx_description_placeholder'.tr(),
                  title: 'forms.thx_description_label'.tr(),
                  controller: uiControllers.thxDescriptionController,
                  onChanged: (value) {
                    ref.read(createFormProvider.notifier).markAsChanged();
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class InputFieldOptions extends StatefulWidget {
  const InputFieldOptions({
    super.key,
    this.id,
    this.title,
    this.type,
    this.index,
    this.onRemove,
    required this.isRequired,
    required this.onRequiredChanged,
    required this.onLabelChanged,
  });

  final String? id;
  final String? title;
  final String? type;
  final int? index;
  final VoidCallback? onRemove;
  final bool isRequired;
  final ValueChanged<bool> onRequiredChanged;
  final ValueChanged<String> onLabelChanged;

  @override
  State<InputFieldOptions> createState() => _InputFieldOptionsState();
}

class _InputFieldOptionsState extends State<InputFieldOptions> {
  bool _onHover = false;
  bool _expanded = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.title ?? '');
  }

  @override
  void didUpdateWidget(InputFieldOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title && widget.title != _controller.text) {
      _controller.text = widget.title ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildFieldOption(
    String type,
  ) {
    return Column(
      children: [
        FFTextField(
          title: 'Заголовок',
          controller: _controller,
          onChanged: (value) {
            widget.onLabelChanged(value);
          },
        ),
        CheckboxListTile(
          value: widget.isRequired,
          contentPadding: .zero,
          onChanged: (value) {
            if (value != null) {
              widget.onRequiredChanged(value);
            }
          },
          title: Text('Обязательное поле'),

          activeColor: AppTheme.secondary,
          checkColor: AppTheme.primary,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() {
        _onHover = true;
      }),
      onExit: (event) => setState(() {
        _onHover = false;
      }),
      child: AnimatedContainer(
        duration: Duration(microseconds: 100),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1, color: AppTheme.fourty),
          borderRadius: BorderRadius.circular(15),
        ),
        margin: .only(bottom: 10),
        child: Column(
          mainAxisSize: .min,
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              crossAxisAlignment: .center,
              children: [
                Row(
                  children: [
                    Tooltip(
                      message: 'Сменить позицию',
                      child: InkWell(
                        child: ReorderableDragStartListener(
                          index: widget.index!,
                          child: HeroIcon(
                            HeroIcons.bars2,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      widget.type == 'phone'
                          ? 'Телефон'
                          : widget.type == 'email'
                          ? 'Почта'
                          : widget.type == 'name'
                          ? 'Имя'
                          : 'Чекбокс',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    MouseRegion(
                      onEnter: (event) => setState(() {
                        _onHover = true;
                      }),
                      onExit: (event) => setState(() {
                        _onHover = false;
                      }),
                      child: Visibility(
                        visible: _onHover,
                        child: Tooltip(
                          message: 'Удалить',
                          child: InkWell(
                            onTap: widget.onRemove,
                            child: HeroIcon(
                              HeroIcons.trash,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Tooltip(
                      message: 'Открыть настройку',
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _expanded = !_expanded;
                          });
                        },
                        child: HeroIcon(
                          _expanded
                              ? HeroIcons.chevronUp
                              : HeroIcons.chevronDown,

                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(
                height: 8,
              ),
              _buildFieldOption(
                widget.type ?? 'name',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class InputFieldItem extends StatefulWidget {
  const InputFieldItem({
    super.key,
    this.icon,
    this.title,
    this.onTap,
  });

  final HeroIcons? icon;
  final String? title;
  final VoidCallback? onTap;

  @override
  State<InputFieldItem> createState() => _InputFieldItemState();
}

class _InputFieldItemState extends State<InputFieldItem> {
  bool _onHover = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(10),
      child: MouseRegion(
        onEnter: (event) {
          setState(() {
            _onHover = true;
          });
        },
        onExit: (event) {
          setState(() {
            _onHover = false;
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _onHover ? AppTheme.primary : AppTheme.eff2f7,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: .only(bottom: 10),
          child: Row(
            crossAxisAlignment: .center,

            mainAxisSize: .min,
            children: [
              HeroIcon(widget.icon ?? HeroIcons.minus),
              const SizedBox(
                width: 10,
              ),
              Text(widget.title ?? 'null'),
            ],
          ),
        ),
      ),
    );
  }
}
