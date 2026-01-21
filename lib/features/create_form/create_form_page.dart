import 'package:flashform_app/features/create_form/views/desktop/create_form_desktop.dart';
import 'package:flashform_app/features/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';

class CreateFormPage extends StatefulWidget {
  const CreateFormPage({
    super.key,
    required this.formId,
  });

  final String formId;

  @override
  State<CreateFormPage> createState() => _CreateFormPageState();
}

class _CreateFormPageState extends State<CreateFormPage> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: SizedBox(),
      desktop: CreateFormDesktopView(
        formId: widget.formId,
      ),
    );
  }
}
