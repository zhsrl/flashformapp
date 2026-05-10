import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/model/create_form_state.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/features/create_form/sections/widgets/logo_image_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Consumer;

class BuildLogoBlock extends StatelessWidget {
  const BuildLogoBlock({super.key, required this.formState});

  final CreateFormState formState;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,

        border: Border.all(
          width: 1.5,
          color: Colors.transparent,
        ),
      ),
      width: context.screenWidth,

      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(
            'Лого',
            style: TextStyle(
              fontWeight: .w500,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Consumer(
            builder: (context, ref, child) {
              final currentFormId = ref.read(currentFormIdProvider);

              return LogoImagePickerWidget(
                folder: '$currentFormId/logo',
                imageUrl: formState.logo,
                onImageUpdated: (url) {
                  ref.read(createFormProvider.notifier).updateLogo(url);
                  ref.read(createFormProvider.notifier).markAsChanged();
                },
                onImageDeleted: () {
                  ref.read(createFormProvider.notifier).updateLogo(null);
                  ref.read(createFormProvider.notifier).markAsChanged();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
