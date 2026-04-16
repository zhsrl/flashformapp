import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/controller/forms_controller.dart';
import 'package:flashform_app/data/controller/image_controller.dart';
import 'package:flashform_app/data/model/create_form_state.dart'
    show CreateFormState, MainPageButtonModel;
import 'package:flashform_app/data/model/form.dart';
import 'package:flashform_app/data/model/form_link.dart';
import 'package:flutter/material.dart';
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

  void updateHasSecondButton(bool value) {
    state = state.copyWith(hasSecondButton: value);
  }

  void updateHasBadge(bool value) {
    state = state.copyWith(hasBadge: value);
  }

  void updateBadge(String value) {
    state = state.copyWith(badge: value);
  }

  void updateActionType(String value) =>
      state = state.copyWith(actionType: value);
  void updateFormName(String name) => state = state.copyWith(name: name);

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
      state = state.copyWith(isSaving: isSaving);
  void updateSuccessText(String successText) =>
      state = state.copyWith(successText: successText);
  void updateMetaPixelId(String id) => state = state.copyWith(metaPixelId: id);
  void updateYandexMetrikaId(String id) =>
      state = state.copyWith(yandexMetrikaId: id);
  void updateButtonUrl(String url) => state = state.copyWith(buttonUrl: url);

  void updateFormButtonText(String text) =>
      state = state.copyWith(formButtonText: text);

  void updateMainFirstButton({
    String? text,
    String? type,
    String? url,
    String? anchor,
    bool? enabled,
  }) {
    final current = state.mainFirstButton;

    state = state.copyWith(
      mainFirstButton: MainPageButtonModel(
        text: text ?? current?.text,
        type: type ?? current?.type,
        url: url ?? current?.url,
        anchor: anchor ?? current?.anchor,
        enabled: enabled ?? current?.enabled,
      ),
    );
  }

  void updateMainSecondButton({
    String? text,
    String? type,
    String? url,
    String? anchor,
    bool? enabled,
  }) {
    final current = state.mainFirstButton;

    state = state.copyWith(
      mainSecondButton: MainPageButtonModel(
        text: text ?? current?.text,
        type: type ?? current?.type,
        url: url ?? current?.url,
        anchor: anchor ?? current?.anchor,
        enabled: enabled ?? current?.enabled,
      ),
    );
  }

  void updateMainFirstButtonText(String text) {
    final current = state.mainFirstButton;
    state = state.copyWith(
      mainFirstButton: MainPageButtonModel(
        text: text,
        type: current?.type,
        url: current?.url,
        anchor: current?.anchor,
        enabled: current?.enabled,
      ),
    );
  }

  void updateMainSecondButtonText(String text) {
    final current = state.mainSecondButton;
    state = state.copyWith(
      mainSecondButton: MainPageButtonModel(
        text: text,
        type: current?.type,
        url: current?.url,
        anchor: current?.anchor,
        enabled: current?.enabled,
      ),
    );
  }

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
    final data = form.data ?? <String, dynamic>{};
    final mainData =
        (data['main'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final formData =
        (data['form'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final brandingData =
        (data['branding'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final settingsData =
        (data['settings'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final integrationsData =
        (settingsData['integrations'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

    debugPrint('main data: $mainData');

    final fieldsList = (formData['fields'] as List? ?? [])
        .whereType<Map>()
        .map((e) => FormFields.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final mainButton1Data = (mainData['button_1'] as Map?)
        ?.cast<String, dynamic>();
    final mainButton2Data = (mainData['button_2'] as Map?)
        ?.cast<String, dynamic>();

    final mainFirstButton = mainButton1Data == null
        ? null
        : MainPageButtonModel(
            text: mainButton1Data['text'] as String?,
            type: mainButton1Data['type'] as String?,
            url: mainButton1Data['url'] as String?,
            anchor: mainButton1Data['anchor'] as String?,
            enabled: mainButton1Data['enabled'] as bool?,
          );

    final mainSecondButton = mainButton2Data == null
        ? null
        : MainPageButtonModel(
            text: mainButton2Data['text'] as String?,
            type: mainButton2Data['type'] as String?,
            url: mainButton2Data['url'] as String?,
            anchor: mainButton2Data['anchor'] as String?,
            enabled: mainButton2Data['enabled'] as bool?,
          );

    final successAction = (formData['success_action'] as Map?)
        ?.cast<String, dynamic>();
    final successActionType = successAction?['type'] as String? ?? 'thx';
    final whatsappNumber = successAction?['whatsapp_number'] as String?;
    final whatsappMessage = successAction?['whatsapp_message'] as String?;
    final thxTitle = successAction?['thx_title'] as String?;
    final thxDescription = successAction?['thx_description'] as String?;
    final redirectUrl = successAction?['redirect_url'] as String?;

    final metaPixel = (integrationsData['meta_pixel_id'] as Map?)
        ?.cast<String, dynamic>();
    final yandexMetrika = (integrationsData['ya_metrika_id'] as Map?)
        ?.cast<String, dynamic>();
    final telegramBot = (integrationsData['telegram_bot'] as Map?)
        ?.cast<String, dynamic>();

    final metaPixelId = metaPixel?['id'] as String? ?? '';
    final yandexMetrikaId = yandexMetrika?['id'] as String? ?? '';
    final telegramEnabled = telegramBot?['enabled'] as bool? ?? false;
    final telegramChatId = telegramBot?['chat_id'] as String?;

    final footerData = (data['footer'] as Map?)?.cast<String, dynamic>();
    final footerLegal = (footerData?['legal-info'] as Map?)
        ?.cast<String, dynamic>();
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

    final primaryColorHex = brandingData['primary_color'] as String?;
    final primaryColor = (primaryColorHex != null && primaryColorHex.isNotEmpty)
        ? primaryColorHex.toColor()
        : null;

    final formButtonData = (formData['button'] as Map?)
        ?.cast<String, dynamic>();

    final mainActionType = mainFirstButton?.type == 'form'
        ? 'form'
        : 'button-url';

    state = state.copyWith(
      name: form.name,
      slug: form.slug,
      title: mainData['title'] as String?,
      subtitle: mainData['subtitle'] as String?,
      heroImageUrl: mainData['image'] as String?,
      badge: mainData['label'] as String?,
      mainFirstButton: mainFirstButton,
      mainSecondButton: mainSecondButton,
      theme: brandingData['theme'] as String? ?? 'light',
      primaryColor: primaryColor,
      logo: brandingData['logo'] as String?,
      formTitle: formData['title'] as String?,
      formButtonText: formButtonData?['text'] as String?,
      successText: formData['success_text'] as String? ?? '',
      fields: fieldsList,
      actionType: mainActionType,
      buttonUrl: mainFirstButton?.url,
      successAction: successActionType,
      whatsappNumber: whatsappNumber,
      whatsappMessage: whatsappMessage,
      thxTitle: thxTitle,
      thxDescription: thxDescription,
      redirectUrl: redirectUrl,
      hasRedirectUrl: redirectUrl != null && redirectUrl.isNotEmpty,
      yandexMetrikaId: yandexMetrikaId,
      metaPixelId: metaPixelId,
      hasLabel: settingsData['is_branded'] as bool? ?? true,
      telegramEnabled: telegramEnabled,
      telegramChatId: telegramChatId,
      hasFooter: footerData?['enabled'] as bool? ?? false,
      footerCompanyName: footerLegal?['company-name'] as String?,
      footerIdNumber: footerLegal?['id-number'] as String?,
      footerAddress: footerLegal?['address'] as String?,
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
      final primaryColorHex = state.primaryColor != null
          ? state.primaryColor!.toHex().replaceFirst('#', '')
          : null;

      final response = {
        'id': formId,
        'name': state.name,
        'branding': {
          'primary_color': primaryColorHex,
          'theme': state.theme,
          'logo': state.logo,
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
        'settings': {
          'integrations': {
            'meta_pixel_id': {
              'id': state.metaPixelId.isEmpty ? null : state.metaPixelId,
              'enabled': state.metaPixelId.isNotEmpty,
            },
            'ya_metrika_id': {
              'id': state.yandexMetrikaId.isEmpty
                  ? null
                  : state.yandexMetrikaId,
              'enabled': state.yandexMetrikaId.isNotEmpty,
            },
            'telegram_bot': {
              'chat_id': state.telegramChatId,
              'enabled': state.telegramEnabled,
            },
          },
          'is_branded': state.hasLabel,
        },
        'form': {
          'title': state.formTitle,
          'fields': state.fields.map((e) => e.toJson()).toList(),
          'success_text': state.successText,
          'button': {
            'text': state.formButtonText,
            'color': primaryColorHex,
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
        'main': {
          'title': state.title,
          'subtitle': state.subtitle,
          'image': state.heroImageUrl,
          'label': state.badge,
          'button_1': {
            'text': state.mainFirstButton?.text,
            'type': state.actionType == 'form' ? 'form' : 'url',
            'url': state.actionType == 'form' ? null : state.buttonUrl,
            'anchor': state.mainFirstButton?.anchor,
          },
          'button_2': {
            'text': state.mainSecondButton?.text,
            'type': state.mainSecondButton?.type,
            'url': state.mainSecondButton?.url,
            'anchor': state.mainSecondButton?.anchor,
            'enabled': state.mainSecondButton?.enabled,
          },
        },
      };

      await ref.read(formControllerProvider.notifier).publishForm(response);

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
