import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/features/create_form/presentation/desktop/create_form_desktop.dart';
import 'package:flashform_app/features/create_form/presentation/mobile/create_form_mobile_view.dart';
import 'package:flashform_app/features/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateFormPage extends StatefulWidget {
  const CreateFormPage({
    super.key,
    required this.formId,
    this.openDrawer,
  });

  final String formId;
  final String? openDrawer;

  @override
  State<CreateFormPage> createState() => _CreateFormPageState();
}

class _CreateFormPageState extends State<CreateFormPage> {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        currentFormIdProvider.overrideWithValue(widget.formId),
      ],

      child: ResponsiveLayout(
        mobile: CreateFormMobileView(
          formId: widget.formId,
          openDrawer: widget.openDrawer,
        ),
        tablet: CreateFormDesktopView(
          formId: widget.formId,
          openDrawer: widget.openDrawer,
        ),
        desktop: CreateFormDesktopView(
          formId: widget.formId,
          openDrawer: widget.openDrawer,
        ),
      ),
    );
  }
}
