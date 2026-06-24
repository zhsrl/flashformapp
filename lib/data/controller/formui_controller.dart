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

  // Main
  late final TextEditingController titleController;
  late final TextEditingController subtitleController;
  late final TextEditingController mainFirstButtonController;
  late final TextEditingController mainSecondButtonController;
  late final TextEditingController tagController;
  late final TextEditingController mainFirstButtonRedirectUrlController;
  late final TextEditingController mainSecondButtonRedirectUrlController;

  // Settings: Form
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
    // Main
    titleController = TextEditingController();
    subtitleController = TextEditingController();
    mainFirstButtonController = TextEditingController();
    mainSecondButtonController = TextEditingController();
    tagController = TextEditingController();

    mainFirstButtonRedirectUrlController = TextEditingController();
    mainSecondButtonRedirectUrlController = TextEditingController();

    // Settings: Form
    formTitleController = TextEditingController();
    formButtonTextController = TextEditingController();

    buttonTextController = mainFirstButtonController;

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

    tagController.addListener(() {
      _logicNotifier.updateBadge(tagController.text);
    });

    subtitleController.addListener(() {
      _logicNotifier.updateSubtitle(subtitleController.text);
    });

    mainFirstButtonController.addListener(() {
      _logicNotifier.updateMainFirstButton(
        text: mainFirstButtonController.text,
      );
    });

    mainSecondButtonController.addListener(() {
      _logicNotifier.updateMainSecondButton(
        text: mainSecondButtonController.text,
      );
    });

    formTitleController.addListener(
      () => _logicNotifier.updateFormTitle(formTitleController.text),
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

    mainFirstButtonRedirectUrlController.addListener(() {
      _logicNotifier.updateMainFirstButton(
        url: mainFirstButtonRedirectUrlController.text,
      );
      _logicNotifier.updateButtonUrl(
        mainFirstButtonRedirectUrlController.text,
      );
    });

    mainSecondButtonRedirectUrlController.addListener(() {
      _logicNotifier.updateMainSecondButton(
        url: mainSecondButtonRedirectUrlController.text,
      );
    });
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
    mainFirstButtonController.dispose();
    mainSecondButtonController.dispose();
    tagController.dispose();
    mainFirstButtonRedirectUrlController.dispose();
    mainSecondButtonRedirectUrlController.dispose();
    formTitleController.dispose();

    if (!identical(buttonTextController, mainFirstButtonController)) {
      buttonTextController.dispose();
    }
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
