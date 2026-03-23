import 'package:flashform_app/data/model/form.dart';
import 'package:flashform_app/data/model/form_link.dart';
import 'package:flutter/material.dart';

const _undefined = Object();

class CreateFormState {
  final String? name;
  final String? title;
  final String? subtitle;
  final String? slug;
  final String? formTitle;
  final String? buttonText;
  final String? formButtonText;
  final bool hasChanges;
  final String? successText;
  final String? heroImageUrl;
  final String theme; // 'light' | 'dark'
  final String actionType; // 'button-url' | 'form'
  final Color buttonColor;
  final bool hasLabel; // false | true;
  final Color formButtonColor;
  final double titleFontSize;
  final double subtitleFontSize;
  final bool hasRedirectUrl;
  final String? redirectUrl;
  final String? whatsappNumber;
  final String? whatsappMessage;
  final String? thxTitle;
  final String? thxDescription;
  final String? successAction;
  final List<FormFields> fields;
  final bool isPublishing;
  final bool isSaving;
  final String? buttonUrl;
  final String metaPixelId;
  final String yandexMetrikaId;
  final bool telegramEnabled;
  final String? telegramChatId;
  final bool hasFooter;
  final String? footerCompanyName;
  final String? footerIdNumber;
  final String? footerAddress;
  final List<FooterLink> footerLinks; // Новое поле для хранения ссылок

  const CreateFormState({
    this.name,
    this.slug,
    this.title,
    this.subtitle,
    this.formTitle,
    this.buttonText,
    this.hasChanges = false,
    this.formButtonText,
    this.successText = '',
    this.heroImageUrl,
    this.buttonUrl,
    this.theme = 'light',
    this.actionType = 'button-url',
    this.buttonColor = Colors.blue,
    this.formButtonColor = Colors.blue,
    this.titleFontSize = 42,
    this.subtitleFontSize = 22,
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
    String? title,
    String? name,
    String? slug,
    String? subtitle,
    String? formTitle,
    String? buttonText,
    String? formButtonText,
    String? successText,
    String? buttonUrl,
    Object? heroImageUrl = _undefined,
    String? theme,
    String? actionType,
    bool? hasChanges,
    Color? buttonColor,
    Color? formButtonColor,
    double? titleFontSize,
    double? subtitleFontSize,
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
      buttonText: buttonText ?? this.buttonText,
      hasChanges: hasChanges ?? this.hasChanges,

      formButtonText: formButtonText ?? this.formButtonText,
      successText: successText ?? this.successText,
      buttonUrl: buttonUrl ?? this.buttonUrl,
      heroImageUrl: heroImageUrl == _undefined
          ? this.heroImageUrl
          : heroImageUrl as String?,
      theme: theme ?? this.theme,
      actionType: actionType ?? this.actionType,
      buttonColor: buttonColor ?? this.buttonColor,
      formButtonColor: formButtonColor ?? this.formButtonColor,
      titleFontSize: titleFontSize ?? this.titleFontSize,
      subtitleFontSize: subtitleFontSize ?? this.subtitleFontSize,
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
