import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/image_controller.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/features/create_form/widgets/image_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuildMainContentBlock extends ConsumerWidget {
  const BuildMainContentBlock({
    super.key,

    required this.contentUrl,
  });

  final String? contentUrl;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final currentFormId = ref.watch(currentFormIdProvider);
    return Container(
      width: context.screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: AppTheme.background,
        border: Border.all(width: 1.5, color: AppTheme.border),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Контент',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ImagePickerWidget(
            folder: currentFormId,
            formId: currentFormId,
            imageUrl: contentUrl,

            onImageDeleted: () async {
              ref.read(createFormProvider.notifier).updateHeroImage(null);
              ref.read(imageControllerProvider.notifier).reset();
            },
          ),
        ],
      ),
    );
  }
}
