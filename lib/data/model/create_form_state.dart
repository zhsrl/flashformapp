import 'package:flashform_app/data/model/form.dart';
import 'package:flashform_app/data/model/form_link.dart';
import 'package:flutter/material.dart';

const _undefined = Object();

class MainPageButtonModel {
  MainPageButtonModel({
    this.text,
    this.type,
    this.anchor,
    this.enabled,
    this.url,
  });

  final String? text;
  final String? type;
  final String? url;
  final String? anchor;
  final bool? enabled;
}

class CreateFormState {
  final String? name;

  // Main Content
  final String? title;
  final String? subtitle;
  final String? heroImageUrl;

  final MainPageButtonModel? mainFirstButton;
  final MainPageButtonModel? mainSecondButton;
  final bool hasSecondButton;

  final String? badge;
  final bool hasBadge;

  // Branding
  final String theme; // 'light' | 'dark'
  final Color? primaryColor;
  final String? logo;

  // Settings - Footer
  final bool hasFooter;
  final String? footerCompanyName;
  final String? footerIdNumber;
  final String? footerAddress;
  final List<FooterLink> footerLinks; // Новое поле для хранения ссылок

  // Settings - Watermark Flashform
  final bool hasLabel; // false | true;

  // Settings - Integrations
  final String metaPixelId;
  final String yandexMetrikaId;
  final bool telegramEnabled;
  final String? telegramChatId;

  // Settings - Page slug
  final String? slug;

  // States
  final bool hasChanges;
  final bool isPublishing;
  final bool isSaving;

  // Settings - Form
  final String? formTitle;
  final String? formButtonText;
  final String? successText;
  final String actionType; // 'button-url' | 'form'
  final bool hasRedirectUrl;
  final String? redirectUrl;
  final String? whatsappNumber;
  final String? whatsappMessage;
  final String? thxTitle;
  final String? thxDescription;
  final String? successAction;
  final List<FormFields> fields;
  final String? buttonUrl;

  const CreateFormState({
    this.name,
    this.slug,
    this.title,
    this.subtitle,
    this.formTitle,
    this.badge,
    this.hasBadge = false,
    this.logo,
    this.primaryColor,
    this.mainFirstButton,
    this.mainSecondButton,
    this.hasSecondButton = false,

    this.hasChanges = false,
    this.formButtonText,
    this.successText = '',
    this.heroImageUrl,
    this.buttonUrl,
    this.theme = 'light',
    this.actionType = 'button-url',

    this.hasRedirectUrl = false,
    this.successAction,
    this.redirectUrl,
    this.hasLabel = true,
    this.whatsappMessage,
    this.whatsappNumber,
    this.thxDescription,
    this.thxTitle,
    this.fields = const [],
    this.isPublishing = false,
    this.isSaving = false,

    this.metaPixelId = '',
    this.yandexMetrikaId = '',
    this.telegramEnabled = false,
    this.telegramChatId,
    this.hasFooter = false,
    this.footerAddress,
    this.footerCompanyName,
    this.footerIdNumber,
    this.footerLinks = const [],
  });

  CreateFormState copyWith({
    String? name,
    // Main
    String? title,
    String? subtitle,
    Object? heroImageUrl = _undefined,
    MainPageButtonModel? mainFirstButton,

    MainPageButtonModel? mainSecondButton,
    bool? hasSecondButton,
    String? badge,
    bool? hasBadge,

    // Branding
    String? theme,
    Color? primaryColor,
    String? logo,

    // Settings
    String? slug,
    String? formTitle,
    String? formButtonText,
    String? successText,
    String? buttonUrl,
    String? actionType,
    bool? hasChanges,
    bool? hasRedirectUrl,
    String? redirectUrl,
    String? successAction,
    String? whatsappMessage,
    String? whatsappNumber,
    String? thxTitle,
    String? thxDescription,
    List<FormFields>? fields,
    bool? isPublishing,
    bool? isSaving,
    bool? hasFooter,
    bool? hasLabel,
    String? metaPixelId,
    String? yandexMetrikaId,
    bool? telegramEnabled,
    String? telegramChatId,
    String? footerCompanyName,
    String? footerIdNumber,
    String? footerAddress,
    List<FooterLink>? footerLinks,
  }) {
    return CreateFormState(
      name: name ?? this.name,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      formTitle: formTitle ?? this.formTitle,
      badge: badge ?? this.badge,
      hasBadge: hasBadge ?? this.hasBadge,
      mainFirstButton: mainFirstButton ?? this.mainFirstButton,
      mainSecondButton: mainSecondButton ?? this.mainSecondButton,
      hasSecondButton: hasSecondButton ?? this.hasSecondButton,
      primaryColor: primaryColor ?? this.primaryColor,
      logo: logo ?? this.logo,

      hasChanges: hasChanges ?? this.hasChanges,

      formButtonText: formButtonText ?? this.formButtonText,
      successText: successText ?? this.successText,
      buttonUrl: buttonUrl ?? this.buttonUrl,
      heroImageUrl: heroImageUrl == _undefined
          ? this.heroImageUrl
          : heroImageUrl as String?,
      theme: theme ?? this.theme,
      isPublishing: isPublishing ?? this.isPublishing,
      isSaving: isSaving ?? this.isSaving,
      actionType: actionType ?? this.actionType,

      hasRedirectUrl: hasRedirectUrl ?? this.hasRedirectUrl,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      whatsappMessage: whatsappMessage ?? this.whatsappMessage,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      thxTitle: thxTitle ?? this.thxTitle,
      thxDescription: thxDescription ?? this.thxDescription,
      successAction: successAction ?? this.successAction,
      fields: fields ?? this.fields,

      metaPixelId: metaPixelId ?? this.metaPixelId,
      yandexMetrikaId: yandexMetrikaId ?? this.yandexMetrikaId,
      telegramEnabled: telegramEnabled ?? this.telegramEnabled,
      telegramChatId: telegramChatId ?? this.telegramChatId,
      hasLabel: hasLabel ?? this.hasLabel,

      hasFooter: hasFooter ?? this.hasFooter,
      footerCompanyName: footerCompanyName ?? this.footerCompanyName,
      footerIdNumber: footerIdNumber ?? this.footerIdNumber,
      footerAddress: footerAddress ?? this.footerAddress,
      footerLinks: footerLinks ?? this.footerLinks,
    );
  }
}
