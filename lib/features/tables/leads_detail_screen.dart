import 'package:flashform_app/features/tables/views/desktop/leads_detail_view_desktop.dart';
import 'package:flashform_app/features/tables/views/mobile/leads_detail_view_mobile.dart';
import 'package:flashform_app/features/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';

class LeadsDetailScreen extends StatelessWidget {
  const LeadsDetailScreen({
    super.key,
    required this.formId,
  });

  final String formId;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: LeadsDetailViewMobile(
        formId: formId,
      ),
      desktop: LeadsDetailViewDesktop(formId: formId),
      tablet: LeadsDetailViewDesktop(formId: formId),
    );
  }
}
