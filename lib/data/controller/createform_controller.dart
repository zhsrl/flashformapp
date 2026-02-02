import 'package:flashform_app/data/controller/forms_controller.dart';
import 'package:flashform_app/data/model/create_form_state.dart'
    show CreateFormState;
import 'package:flashform_app/data/model/form_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final createFormProvider =
    StateNotifierProvider.autoDispose<CreateFormController, CreateFormState>((
      ref,
    ) {
      return CreateFormController(ref);
    });

class CreateFormController extends StateNotifier<CreateFormState> {
  final Ref ref;

  CreateFormController(this.ref) : super(const CreateFormState());

  bool _hasUnsavedChanges = false;

  void markAsChanged() {
    _hasUnsavedChanges = true;
    state = state.copyWith(hasChanges: true);
  }

  void clearChanges() {
    _hasUnsavedChanges = false;
    state = state.copyWith(hasChanges: false);
  }

  bool get hasUnsavedChanges => _hasUnsavedChanges;

  // Setters for UI
  void updateTitle(String value) => state = state.copyWith(title: value);
  void updateSubtitle(String value) => state = state.copyWith(subtitle: value);
  void updateFormTitle(String value) =>
      state = state.copyWith(formTitle: value);
  void updateTheme(String value) => state = state.copyWith(theme: value);
  void updateHeroImage(String? url) =>
      state = state.copyWith(heroImageUrl: url);
  void updateHasChanges(bool hasChanges) {
    state = state.copyWith(hasChanges: hasChanges);
  }

  void updateActionType(String value) =>
      state = state.copyWith(actionType: value);
  void updateButtonColor(Color color) =>
      state = state.copyWith(buttonColor: color);
  void updateTitleFontSize(double size) =>
      state = state.copyWith(titleFontSize: size);
  void updateSubtitleFontSize(double size) =>
      state = state.copyWith(subtitleFontSize: size);
  void updateFormButtonColor(Color color) =>
      state = state.copyWith(formButtonColor: color);
  void updateHasRedirectUrl(bool hasRedirectUrl) =>
      state = state.copyWith(hasRedirectUrl: hasRedirectUrl);
  void updateFormRedirectUrl(String url) =>
      state = state.copyWith(redirectUrl: url);
  void updateFields(List<FormFields> fields) =>
      state = state.copyWith(fields: fields);
  void updateIsPublishing(bool isPublishing) =>
      state = state.copyWith(isPublishing: isPublishing);
  void updateIsSaving(bool isSaving) =>
      state = state.copyWith(isPublishing: isSaving);
  void updateSuccessText(String successText) =>
      state = state.copyWith(successText: successText);
  void updateMetaPixelId(String id) => state = state.copyWith(metaPixelId: id);
  void updateYandexMetrikaId(String id) =>
      state = state.copyWith(yandexMetrikaId: id);
  void updateButtonUrl(String url) => state = state.copyWith(buttonUrl: url);
  void updateButtonText(String text) =>
      state = state.copyWith(buttonText: text);
  void updateFormButtonText(String text) =>
      state = state.copyWith(formButtonText: text);

  void initializeFromModel(FormModel form) {
    final data = form.data ?? {};
    final fieldsList = (data['form']['fields'] as List? ?? [])
        .map((e) => FormFields.fromJson(e))
        .toList();

    state = state.copyWith(
      title: data['title']['text'],
      subtitle: data['subtitle']['text'],
      formTitle: data['form']['title'],
      theme: data['theme'] ?? 'light',
      heroImageUrl: data['image'],
      fields: fieldsList,
      buttonText: data['button']['text'],
      buttonUrl: data['button']['url'],
      formButtonText: data['form']['button']['text'],
      buttonColor: (data['button']['color'] as String).toColor(),
      formButtonColor: (data['form']['button']['color'] as String).toColor(),
      successText: data['success_text'],
      titleFontSize: data['title']['size'],
      subtitleFontSize: data['subtitle']['size'],
      actionType: data['action_type'],
      hasRedirectUrl: data['form']['button']['redirect_url'] != null
          ? true
          : false,
      redirectUrl: data['form']['button']['redirect-url'],
      yandexMetrikaId: data['settings']['ya-metrika-id'],
      metaPixelId: data['settings']['meta-pixel-id'],
    );
  }

  void addField(String label, String type) {
    final newField = FormFields(label: label, type: type);
    state = state.copyWith(fields: [...state.fields, newField]);
  }

  void removeField(int index) {
    final newFields = List<FormFields>.from(state.fields)..removeAt(index);
    state = state.copyWith(fields: newFields);
  }

  Future<bool> publishForm(String formId) async {
    if (state.fields.isEmpty && state.actionType == 'form') {
      return false;
    }

    state = state.copyWith(isPublishing: true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("User not authenticated");

      debugPrint('TITLE for save: ${state.title}');

      final data = {
        'id': formId,
        'title': {
          'text': state.title,
          'size': state.titleFontSize,
        },
        'subtitle': {
          'text': state.subtitle,
          'size': state.subtitleFontSize,
        },

        'content': 'image',
        'image': state.heroImageUrl,
        'action_type': state.actionType,
        'button': {
          'color': state.buttonColor.toHexString(),
          'text': state.buttonText,
          'url': state.buttonUrl,
        },
        'form': {
          'title': state.formTitle,
          'fields': state.fields.map((e) => e.toJson()).toList(),
          'button': {
            'text': state.formButtonText,
            'color': state.formButtonColor.toHexString(),

            'redirect-url': state.redirectUrl,
          },
        },
        'theme': state.theme,
        'settings': {
          'meta-pixel-id': state.metaPixelId,
          'ya-metrika-id': state.yandexMetrikaId,
        },
      };

      debugPrint('Data to save: $data');

      await ref.read(formControllerProvider.notifier).publishForm(data);
      return true;
    } catch (e) {
      debugPrint('Error publishing form: $e');
      return false;
    } finally {
      state = state.copyWith(isPublishing: false);
    }
  }
}
