import 'package:flashform_app/data/controller/forms_controller.dart';
import 'package:flashform_app/data/controller/image_controller.dart';
import 'package:flashform_app/data/model/create_form_state.dart'
    show CreateFormState;
import 'package:flashform_app/data/model/form.dart';
import 'package:flashform_app/data/model/form_link.dart';

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
  void updateFormName(String name) => state = state.copyWith(name: name);
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
  void updateHasLabel(bool hasLabel) =>
      state = state.copyWith(hasLabel: hasLabel);
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

  void updateSuccessAction(String action) =>
      state = state.copyWith(successAction: action);
  void updateWhatsappNumber(String number) =>
      state = state.copyWith(whatsappNumber: number);
  void updateWhatsappMessage(String message) =>
      state = state.copyWith(whatsappMessage: message);
  void updateThxTitle(String title) => state = state.copyWith(thxTitle: title);
  void updateThxDescription(String description) =>
      state = state.copyWith(thxDescription: description);

  // Footer methods

  void updateHasFooter(bool value) {
    state = state.copyWith(hasFooter: value);
  }

  void updateFooterCompanyName(String value) {
    state = state.copyWith(footerCompanyName: value);
  }

  void updateFooterIdNumber(String value) {
    state = state.copyWith(footerIdNumber: value);
  }

  void updateFooterAddress(String value) {
    state = state.copyWith(footerAddress: value);
  }

  void updateFooterLinks(List<FooterLink> links) {
    state = state.copyWith(footerLinks: links);
  }

  void copyFooterFromForm(CreateFormState sourceForm) {
    state = state.copyWith(
      hasFooter: sourceForm.hasFooter,
      footerCompanyName: sourceForm.footerCompanyName,
      footerIdNumber: sourceForm.footerIdNumber,
      footerAddress: sourceForm.footerAddress,
      footerLinks: sourceForm.footerLinks,
    );
    markAsChanged();
  }

  // Telegram methods
  void updateTelegramEnabled(bool enabled) {
    state = state.copyWith(telegramEnabled: enabled);
    markAsChanged();
  }

  void updateTelegramChatId(String chatId) {
    state = state.copyWith(telegramChatId: chatId);
    markAsChanged();
  }

  void clearTelegramSettings() {
    state = state.copyWith(
      telegramEnabled: false,
      telegramChatId: null,
    );
    markAsChanged();
  }

  void initializeFromModel(FormModel form) {
    final data = form.data ?? {};
    final fieldsList = (data['form']['fields'] as List? ?? [])
        .map((e) => FormFields.fromJson(e))
        .toList();

    // Загружаем success_action из новой структуры
    final successAction = data['form']['success_action'] as Map?;
    final successActionType = successAction?['type'] as String? ?? 'thx';
    final whatsappNumber = successAction?['whatsapp_number'] as String?;
    final whatsappMessage = successAction?['whatsapp_message'] as String?;
    final thxTitle = successAction?['thx_title'] as String?;
    final thxDescription = successAction?['thx_description'] as String?;
    final redirectUrl = successAction?['redirect_url'] as String?;
    final hasLabel = data['settings']['has-label'] as bool;
    // Загружаем Telegram настройки
    final notificationSettings = data['notification_settings'] as Map?;
    final telegramSettings = notificationSettings?['telegram'] as Map?;
    final telegramEnabled = telegramSettings?['enabled'] as bool? ?? false;
    final telegramChatId = telegramSettings?['chat_id'] as String?;

    // Загружаем Footer данные
    final footerData = data['footer'] as Map?;
    final footerCompanyName =
        footerData?['legal-info']['company-name'] as String?;
    final footerIdNumber = footerData?['legal-info']['id-number'] as String?;
    final footerAddress = footerData?['legal-info']['address'] as String?;
    final hasFooter = data['footer']['enabled'] as bool;
    final footerLinksData = footerData?['links'] as List? ?? [];
    final footerLinks = footerLinksData
        .map((linkMap) {
          if (linkMap is Map) {
            final label = linkMap.keys.first as String;
            final url = linkMap.values.first as String;
            return FooterLink(label: label, url: url);
          }
          return null;
        })
        .whereType<FooterLink>()
        .toList();

    state = state.copyWith(
      name: form.name,
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
      successText: data['form']['success_text'],
      titleFontSize: data['title']['size'],
      subtitleFontSize: data['subtitle']['size'],
      actionType: data['action_type'],
      successAction: successActionType,
      whatsappNumber: whatsappNumber,
      whatsappMessage: whatsappMessage,
      thxTitle: thxTitle,
      thxDescription: thxDescription,
      redirectUrl: redirectUrl,
      hasRedirectUrl: redirectUrl != null ? true : false,
      yandexMetrikaId: data['settings']['ya-metrika-id'],
      metaPixelId: data['settings']['meta-pixel-id'],
      hasLabel: hasLabel,
      telegramEnabled: telegramEnabled,
      telegramChatId: telegramChatId,
      hasFooter: hasFooter,
      footerCompanyName: footerCompanyName,
      footerIdNumber: footerIdNumber,
      footerAddress: footerAddress,
      footerLinks: footerLinks,
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
    final imageNotifier = ref.read(imageControllerProvider.notifier);

    final imageState = ref.read(imageControllerProvider);

    if (state.fields.isEmpty && state.actionType == 'form') {
      return false;
    }

    state = state.copyWith(isPublishing: true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("User not authenticated");

      if (imageState.localImageBytes != null) {
        final uploadedUrl = await imageNotifier.uploadImage(
          folder: formId,
          bytes: imageState.localImageBytes,
        );

        if (uploadedUrl != null) {
          updateHeroImage(uploadedUrl); // Обновляем стейт формы URL-ом
        } else {
          throw Exception('Не удалось загрузить изображение');
        }
      }

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
          'success_text': state.successText,
          'button': {
            'text': state.formButtonText,
            'color': state.formButtonColor.toHexString(),
          },
          'success_action': {
            'type': state.successAction,
            'whatsapp_number': state.whatsappNumber,
            'whatsapp_message': state.whatsappMessage,
            'thx_title': state.thxTitle,
            'thx_description': state.thxDescription,
            'redirect_url': state.redirectUrl,
          },
        },
        'theme': state.theme,
        'settings': {
          'meta-pixel-id': state.metaPixelId,
          'ya-metrika-id': state.yandexMetrikaId,
          'has-label': state.hasLabel,
        },
        'notification_settings': {
          'telegram': {
            'enabled': state.telegramEnabled,
            'chat_id': state.telegramChatId,
          },
        },
        'footer': {
          'enabled': state.hasFooter,
          'legal-info': {
            'company-name': state.footerCompanyName,
            'id-number': state.footerIdNumber,
            'address': state.footerAddress,
          },
          'links': state.footerLinks.map((element) {
            return {
              element.label: element.url,
            };
          }).toList(),
        },
      };

      debugPrint('Data to save: $data');

      await ref.read(formControllerProvider.notifier).publishForm(data);

      imageNotifier.resetPickedImage();
      clearChanges();

      return true;
    } catch (e) {
      debugPrint('Error publishing form: $e');
      return false;
    } finally {
      state = state.copyWith(isPublishing: false);
    }
  }
}
