import 'package:flashform_app/data/model/form_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';

// Этот провайдер создает контроллеры один раз и уничтожает их при выходе с экрана
final formUIControllersProvider = Provider.autoDispose<FormUIControllers>((
  ref,
) {
  final logicNotifier = ref.read(createFormProvider.notifier);
  final controllers = FormUIControllers(logicNotifier);

  // Автоматически вызываем dispose, когда провайдер больше не нужен
  ref.onDispose(() => controllers.dispose());

  return controllers;
});

class FormUIControllers {
  final CreateFormController _logicNotifier;

  late final TextEditingController titleController;
  late final TextEditingController subtitleController;
  late final TextEditingController formTitleController;
  late final TextEditingController buttonTextController;
  late final TextEditingController formButtonTextController;
  late final TextEditingController successTextController;
  late final TextEditingController buttonUrlController;
  late final TextEditingController formRedirectUrlController;

  late final TextEditingController metaPixelIdController;
  late final TextEditingController yandexMetrikaIdController;

  late final TextEditingController whatsappNumberController;
  late final TextEditingController whatsappMessageController;

  late final TextEditingController thxTitleController;
  late final TextEditingController thxDescriptionController;

  late final TextEditingController footerCompanyNameController;
  late final TextEditingController footerIdNumberController;
  late final TextEditingController footerAddressController;

  FormUIControllers(this._logicNotifier) {
    titleController = TextEditingController();
    subtitleController = TextEditingController();
    formTitleController = TextEditingController();
    buttonTextController = TextEditingController();
    formButtonTextController = TextEditingController();
    successTextController = TextEditingController();
    buttonUrlController = TextEditingController();

    formRedirectUrlController = TextEditingController();
    whatsappNumberController = TextEditingController();
    whatsappMessageController = TextEditingController();
    thxTitleController = TextEditingController();
    thxDescriptionController = TextEditingController();

    metaPixelIdController = TextEditingController();
    yandexMetrikaIdController = TextEditingController();

    footerCompanyNameController = TextEditingController();
    footerIdNumberController = TextEditingController();
    footerAddressController = TextEditingController();

    // Как только юзер печатает, мы обновляем главный стейт
    titleController.addListener(() {
      _logicNotifier.updateTitle(titleController.text);
      // _logicNotifier.markAsChanged(); // Помечаем, что есть изменения
    });

    subtitleController.addListener(() {
      _logicNotifier.updateSubtitle(subtitleController.text);
    });

    formTitleController.addListener(
      () => _logicNotifier.updateFormTitle(formTitleController.text),
    );

    buttonTextController.addListener(
      () => _logicNotifier.updateButtonText(buttonTextController.text),
    );
    formButtonTextController.addListener(
      () => _logicNotifier.updateFormButtonText(formButtonTextController.text),
    );
    successTextController.addListener(
      () => _logicNotifier.updateSuccessText(successTextController.text),
    );
    buttonUrlController.addListener(
      () => _logicNotifier.updateButtonUrl(buttonUrlController.text),
    );
    formRedirectUrlController.addListener(
      () =>
          _logicNotifier.updateFormRedirectUrl(formRedirectUrlController.text),
    );
    whatsappNumberController.addListener(
      () => _logicNotifier.updateWhatsappNumber(whatsappNumberController.text),
    );
    whatsappMessageController.addListener(
      () =>
          _logicNotifier.updateWhatsappMessage(whatsappMessageController.text),
    );
    thxTitleController.addListener(
      () => _logicNotifier.updateThxTitle(thxTitleController.text),
    );
    thxDescriptionController.addListener(
      () => _logicNotifier.updateThxDescription(thxDescriptionController.text),
    );
    metaPixelIdController.addListener(
      () => _logicNotifier.updateMetaPixelId(metaPixelIdController.text),
    );
    yandexMetrikaIdController.addListener(
      () =>
          _logicNotifier.updateYandexMetrikaId(yandexMetrikaIdController.text),
    );

    footerCompanyNameController.addListener(
      () => _logicNotifier.updateFooterCompanyName(
        footerCompanyNameController.text,
      ),
    );
    footerIdNumberController.addListener(
      () => _logicNotifier.updateFooterIdNumber(footerIdNumberController.text),
    );
    footerAddressController.addListener(
      () => _logicNotifier.updateFooterAddress(footerAddressController.text),
    );
  }

  // Метод для заполнения данными при загрузке страницы
  void initializeValues({
    String? title,
    String? subtitle,
    String? formTitle,
    String? formButtonText,
    String? buttonText,
    String? successText,
    String? buttonUrl,
    String? formRedirectUrl,
    String? whatsappNumber,
    String? whatsappMessage,
    String? thxTitle,
    String? thxDescription,
    String? metaPixelId,
    String? yandexMetrikaId,
  }) {
    if (title != null) titleController.text = title;
    if (subtitle != null) subtitleController.text = subtitle;
    if (formTitle != null) formTitleController.text = formTitle;
    if (formButtonText != null) formButtonTextController.text = formButtonText;
    if (buttonText != null) buttonTextController.text = buttonText;
    if (successText != null) successTextController.text = successText;
    if (buttonUrl != null) buttonUrlController.text = buttonUrl;
    if (formRedirectUrl != null)
      formRedirectUrlController.text = formRedirectUrl;
    if (metaPixelId != null) metaPixelIdController.text = metaPixelId;
    if (yandexMetrikaId != null) {
      yandexMetrikaIdController.text = yandexMetrikaId;
    }
    if (whatsappNumber != null) {
      whatsappNumberController.text = whatsappNumber;
    }
    if (whatsappMessage != null) {
      whatsappMessageController.text = whatsappMessage;
    }
    if (thxTitle != null) thxTitleController.text = thxTitle;
    if (thxDescription != null) {
      thxDescriptionController.text = thxDescription;
    }
  }

  void updateHasFooter(bool value) {
    _logicNotifier.updateHasFooter(value);
  }

  void updateHasLabel(bool value) {
    _logicNotifier.updateHasLabel(value);
  }

  void updateFooterLinks(List<FooterLink> links) {
    _logicNotifier.updateFooterLinks(links);
  }

  void updateFooterValues({
    String? footerCompanyName,
    String? footerIdNumber,
    String? footerAddress,
  }) {
    if (footerCompanyName != null) {
      footerCompanyNameController.text = footerCompanyName;
    }
    if (footerIdNumber != null) {
      footerIdNumberController.text = footerIdNumber;
    }
    if (footerAddress != null) {
      footerAddressController.text = footerAddress;
    }
  }

  void dispose() {
    titleController.dispose();
    subtitleController.dispose();
    formTitleController.dispose();
    buttonTextController.dispose();
    formButtonTextController.dispose();
    successTextController.dispose();
    buttonUrlController.dispose();
    formRedirectUrlController.dispose();
    metaPixelIdController.dispose();
    yandexMetrikaIdController.dispose();
    whatsappNumberController.dispose();
    whatsappMessageController.dispose();
    thxTitleController.dispose();
    thxDescriptionController.dispose();
    footerCompanyNameController.dispose();
    footerIdNumberController.dispose();
    footerAddressController.dispose();
  }
}
