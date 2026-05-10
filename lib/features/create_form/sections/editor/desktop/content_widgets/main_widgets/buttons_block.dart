import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/data/model/create_form_state.dart';
import 'package:flashform_app/features/create_form/sections/editor/desktop/editor_view_desktop.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

class BuildButtonsBlock extends ConsumerStatefulWidget {
  const BuildButtonsBlock({
    super.key,
    this.formState,
    required this.controller,
    required this.uiControllers,
  });

  final dynamic formState;
  final CreateFormController controller;
  final FormUIControllers uiControllers;

  @override
  ConsumerState<BuildButtonsBlock> createState() => _BuildButtonsBlockState();
}

class _BuildButtonsBlockState extends ConsumerState<BuildButtonsBlock> {
  late Set<String> _selected;
  late Set<String> _secondSelected;
  bool _hasSecondButton = false;
  bool _syncedFromState = false;

  @override
  void initState() {
    super.initState();
    _selected = {'form'};
    _secondSelected = {'form'};
    _syncFromFormState(widget.formState, notify: false);
  }

  @override
  void didUpdateWidget(covariant BuildButtonsBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_syncedFromState) {
      _syncFromFormState(widget.formState, notify: true);
    }
  }

  void _syncFromFormState(dynamic formState, {required bool notify}) {
    if (formState is! CreateFormState) return;
    if (!_canSyncFromFormState(formState)) return;

    final firstType = _resolveButtonType(
      formState.mainFirstButton,
      fallbackActionType: formState.actionType,
    );
    final secondType = _resolveButtonType(formState.mainSecondButton);
    final hasSecond =
        formState.hasSecondButton || _hasButtonData(formState.mainSecondButton);

    if (notify) {
      setState(() {
        _selected = {firstType};
        _secondSelected = {secondType};
        _hasSecondButton = hasSecond;
      });
    } else {
      _selected = {firstType};
      _secondSelected = {secondType};
      _hasSecondButton = hasSecond;
    }

    _syncedFromState = true;
  }

  bool _canSyncFromFormState(CreateFormState state) {
    return state.mainFirstButton != null ||
        state.mainSecondButton != null ||
        state.hasSecondButton;
  }

  bool _hasButtonData(MainPageButtonModel? button) {
    if (button == null) return false;
    return (button.text?.isNotEmpty ?? false) ||
        (button.url?.isNotEmpty ?? false) ||
        (button.anchor?.isNotEmpty ?? false);
  }

  String _resolveButtonType(
    MainPageButtonModel? button, {
    String? fallbackActionType,
  }) {
    final rawType = button?.type;
    if (rawType != null && rawType.isNotEmpty) {
      return rawType;
    }

    if (button?.url?.isNotEmpty ?? false) return 'url';
    if (fallbackActionType == 'form') return 'form';
    return 'url';
  }

  void updateFirstButtonActionSelected(
    Set<String> newSelection,
  ) {
    setState(() {
      _selected = newSelection;
    });

    widget.controller.updateMainFirstButton(type: newSelection.single);
  }

  void updateSecondButtonActionSelected(
    Set<String> newSelection,
  ) {
    setState(() {
      _secondSelected = newSelection;
    });

    widget.controller.updateMainSecondButton(type: newSelection.single);
  }

  Widget _buildFirstButton() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        FFTextField(
          hintText: 'Текст кнопки',
          title: 'Текст в кнопке',
          maxLength: 30,
          controller: widget.uiControllers.mainFirstButtonController,
        ),
        const Text(
          'Тип действии',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          height: 8,
        ),
        SegmentedButton(
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: AppTheme.primary,
            selectedForegroundColor: AppTheme.secondary,
          ),
          showSelectedIcon: false,
          expandedInsets: EdgeInsets.all(0),
          onSelectionChanged: updateFirstButtonActionSelected,
          multiSelectionEnabled: false,

          segments: <ButtonSegment<String>>[
            ButtonSegment<String>(
              value: 'form',
              label: Text('Форма'),
              enabled: true,
            ),
            ButtonSegment<String>(
              value: 'url',
              label: Text('Редирект'),
              enabled: true,
            ),
          ],
          selected: _selected,
        ),

        const SizedBox(
          height: 16,
        ),

        if (_selected.contains('form')) ...[
          Column(
            children: [
              Text('Вы можете настраивать форму в вкладке настройки '),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  ref.read(editorTabIndexProvider.notifier).state = 3;
                },
                child: Text(
                  'Перейти в настройки',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (_selected.contains('url'))
          FFTextField(
            prefixIcon: HeroIcon(HeroIcons.link),
            hintText: 'Redirect URL',
            controller:
                widget.uiControllers.mainFirstButtonRedirectUrlController,
          ),
        // if (_selected.contains('anchor')) Text('AA'),
      ],
    );
  }

  Widget _buildSecondButton() {
    return Container(
      width: context.screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        border: Border.all(width: 1.5, color: AppTheme.border),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: .center,
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                'Вторая кнопка',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              CupertinoSwitch(
                value: _hasSecondButton,
                activeTrackColor: Colors.green,

                onChanged: (value) {
                  setState(() {
                    _hasSecondButton = value;
                    widget.controller.updateHasSecondButton(value);
                    widget.controller.updateMainSecondButton(enabled: value);
                  });
                },
              ),
            ],
          ),
          if (_hasSecondButton) ...[
            const SizedBox(
              height: 8,
            ),
            FFTextField(
              title: 'Текст в кнопке',
              maxLength: 30,
              controller: widget.uiControllers.mainSecondButtonController,
            ),

            const SizedBox(
              height: 8,
            ),
            SegmentedButton(
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppTheme.primary,
                selectedForegroundColor: AppTheme.secondary,
              ),
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.all(0),
              onSelectionChanged: updateSecondButtonActionSelected,
              multiSelectionEnabled: false,

              segments: <ButtonSegment<String>>[
                ButtonSegment<String>(
                  value: 'form',
                  label: Text('Форма'),
                  enabled: true,
                ),
                ButtonSegment<String>(
                  value: 'url',
                  label: Text('Редирект'),
                  enabled: true,
                ),
                // ButtonSegment<String>(
                //   value: 'anchor',
                //   label: Text('Блок'),
                //   enabled: true,
                // ),
              ],
              selected: _secondSelected,
            ),

            const SizedBox(
              height: 16,
            ),

            if (_secondSelected.contains('form')) ...[
              Column(
                children: [
                  Text('Вы можете настраивать форму в вкладке настройки '),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      ref.read(editorTabIndexProvider.notifier).state = 2;
                    },
                    child: Text(
                      'Перейти в настройки',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (_secondSelected.contains('url'))
              FFTextField(
                prefixIcon: HeroIcon(HeroIcons.link),
                hintText: 'Redirect URL',
                controller:
                    widget.uiControllers.mainSecondButtonRedirectUrlController,
              ),
            // if (_secondSelected.contains('anchor')) Text('AA'),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
            crossAxisAlignment: .start,
            children: [
              const Text(
                'Кнопка',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildFirstButton(),
            ],
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        _buildSecondButton(),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }
}
