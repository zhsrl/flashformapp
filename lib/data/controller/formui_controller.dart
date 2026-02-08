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

  FormUIControllers(this._logicNotifier) {
    titleController = TextEditingController();
    subtitleController = TextEditingController();
    formTitleController = TextEditingController();
    buttonTextController = TextEditingController();
    formButtonTextController = TextEditingController();
    successTextController = TextEditingController();
    buttonUrlController = TextEditingController();
    formRedirectUrlController = TextEditingController();

    metaPixelIdController = TextEditingController();
    yandexMetrikaIdController = TextEditingController();

    // МАГИЯ СИНХРОНИЗАЦИИ:
    // Как только юзер печатает, мы обновляем главный стейт
    titleController.addListener(() {
      _logicNotifier.updateTitle(titleController.text);
      // _logicNotifier.markAsChanged(); // Помечаем, что есть изменения
    });

    subtitleController.addListener(() {
      _logicNotifier.updateSubtitle(subtitleController.text);
      // _logicNotifier.markAsChanged();
    });

    // Добавь остальные слушатели...
    formTitleController.addListener(
      () => _logicNotifier.updateFormTitle(formTitleController.text),
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
    if (formRedirectUrl != null) {
      formRedirectUrlController.text = formRedirectUrl;

      if (metaPixelId != null) metaPixelIdController.text = metaPixelId;
      if (yandexMetrikaId != null)
        yandexMetrikaIdController.text = yandexMetrikaId;
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
  }
}
