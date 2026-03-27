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
      final successAction = form.data?['form']['success_action'] as Map?;

      // ===== ОСНОВНЫЕ ДАННЫЕ =====
      uiControllers.titleController.text =
          form.data?['title']['text'] ?? 'Заголовок сайта';
      uiControllers.subtitleController.text =
          form.data?['subtitle']['text'] ?? 'Описание';
      uiControllers.formTitleController.text =
          form.data?['form']['title'] ?? 'Заголовок формы';
      uiControllers.buttonTextController.text =
          form.data?['button']['text'] ?? 'Кнопка';
      uiControllers.formButtonTextController.text =
          form.data?['form']['button']['text'] ?? 'Оставить заявку';
      uiControllers.successTextController.text =
          form.data?['form']['success_text'] ?? 'Успешная форма';

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
      uiControllers.metaPixelIdController.text =
          form.data?['settings']['meta-pixel-id'] ?? '';
      uiControllers.yandexMetrikaIdController.text =
          form.data?['settings']['ya-metrika-id'] ?? '';

      // ===== FOOTER ДАННЫЕ =====
      uiControllers.footerCompanyNameController.text =
          form.data?['footer']['legal-info']['company-name'] ?? '';
      uiControllers.footerIdNumberController.text =
          form.data?['footer']['legal-info']['id-number'] ?? '';
      uiControllers.footerAddressController.text =
          form.data?['footer']['legal-info']['address'] ?? '';

      debugPrint('✅ loadFormData: Все данные загружены успешно!');
    } catch (e, stackTrace) {
      debugPrint('❌ loadFormData: Ошибка - $e');
      debugPrint('❌ stackTrace: $stackTrace');
    } finally {
      onLoadComplete();
    }
  }
}
