import 'package:flashform_app/data/model/form_model.dart';
import 'package:flutter/material.dart';

const _undefined = Object();

class CreateFormState {
  final String? title;
  final String? subtitle;
  final String? formTitle;
  final String? buttonText;
  final String? formButtonText;
  final bool hasChanges;
  final String? successText;
  final String? heroImageUrl;
  final String theme; // 'light' | 'dark'
  final String actionType; // 'button-url' | 'form'
  final Color buttonColor;

  final Color formButtonColor;
  final double titleFontSize;
  final double subtitleFontSize;
  final bool hasRedirectUrl;
  final String? redirectUrl;
  final List<FormFields> fields;
  final bool isPublishing;
  final bool isSaving;
  final String? buttonUrl;
  final String? metaPixelId;
  final String? yandexMetrikaId;

  const CreateFormState({
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
    this.redirectUrl,
    this.fields = const [],
    this.isPublishing = false,
    this.isSaving = false,

    this.metaPixelId,
    this.yandexMetrikaId,
  });

  CreateFormState copyWith({
    String? title,
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
    List<FormFields>? fields,
    bool? isPublishing,
    bool? isSaving,
    String? metaPixelId,
    String? yandexMetrikaId,
  }) {
    return CreateFormState(
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
      fields: fields ?? this.fields,

      metaPixelId: metaPixelId ?? this.metaPixelId,
      yandexMetrikaId: yandexMetrikaId ?? this.yandexMetrikaId,
    );
  }
}
