import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/forms_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

mixin FormLoaderMixin {
  Future<void> loadFormData(
    String formId,
    WidgetRef ref,

    bool Function() isMounted,
    VoidCallback onLoadComplete,
  ) async {
    try {
      final formController = ref.read(formControllerProvider.notifier);
      final form = await formController.fetchForm(formId);
      final data = form.data ?? <String, dynamic>{};
      final formMainData = data['main'] as Map?;
      final formData = data['form'] as Map?;
      final settingsData = data['settings'] as Map?;
      final integrationsData = settingsData?['integrations'] as Map?;

      if (!isMounted()) {
        debugPrint('⚠️ loadFormData: Widget был размонтирован');
        return;
      }

      final uiControllers = ref.read(formUIControllersProvider);

      debugPrint('📌 loadFormData: Форма загружена - ${form.name}');

      debugPrint('📌 loadFormData: Загружаю данные в контроллер...');
      ref.read(createFormProvider.notifier).initializeFromModel(form);

      debugPrint('📌 loadFormData: Загружаю данные в uiControllers...');

      // Загружаем success_action из новой структуры
      final successAction = formData?['success_action'] as Map?;
      final mainButton = formMainData?['button_1'] as Map?;
      final metaPixel = integrationsData?['meta_pixel_id'] as Map?;
      final yandexMetrika = integrationsData?['ya_metrika_id'] as Map?;
      final footerLegal = (data['footer'] as Map?)?['legal-info'] as Map?;

      // ===== ОСНОВНЫЕ ДАННЫЕ =====
      uiControllers.titleController.text =
          formMainData?['title'] ?? 'Заголовок сайта';
      uiControllers.subtitleController.text =
          formMainData?['subtitle'] ?? 'Описание';
      uiControllers.formTitleController.text =
          formData?['title'] ?? 'Заголовок формы';
      uiControllers.buttonTextController.text = mainButton?['text'] ?? 'Кнопка';
      uiControllers.buttonUrlController.text = mainButton?['url'] ?? '';
      uiControllers.formButtonTextController.text =
          (formData?['button'] as Map?)?['text'] ?? 'Оставить заявку';
      uiControllers.successTextController.text =
          formData?['success_text'] ?? 'Успешная форма';

      // ===== SUCCESS ACTION ДАННЫЕ =====
      uiControllers.formRedirectUrlController.text =
          successAction?['redirect_url'] ?? '';
      uiControllers.whatsappNumberController.text =
          successAction?['whatsapp_number'] ?? '';
      uiControllers.whatsappMessageController.text =
          successAction?['whatsapp_message'] ?? '';
      uiControllers.thxTitleController.text = successAction?['thx_title'] ?? '';
      uiControllers.thxDescriptionController.text =
          successAction?['thx_description'] ?? '';

      // ===== ИНТЕГРАЦИИ =====
      uiControllers.metaPixelIdController.text = metaPixel?['id'] ?? '';
      uiControllers.yandexMetrikaIdController.text = yandexMetrika?['id'] ?? '';

      // ===== FOOTER ДАННЫЕ =====
      uiControllers.footerCompanyNameController.text =
          footerLegal?['company-name'] ?? '';
      uiControllers.footerIdNumberController.text =
          footerLegal?['id-number'] ?? '';
      uiControllers.footerAddressController.text =
          footerLegal?['address'] ?? '';

      debugPrint('✅ loadFormData: Все данные загружены успешно!');
    } catch (e, stackTrace) {
      debugPrint('❌ loadFormData: Ошибка - $e');
      debugPrint('❌ stackTrace: $stackTrace');
    } finally {
      onLoadComplete();
    }
  }
}
