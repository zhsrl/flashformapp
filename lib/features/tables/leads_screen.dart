import 'package:flashform_app/features/tables/views/desktop/leads_view_desktop.dart';
import 'package:flashform_app/features/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';

class LeadsScreen extends StatelessWidget {
  const LeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: Center(
        child: Text('Mobile tables view'),
      ),
      desktop: LeadsViewDesktop(),
      tablet: Center(
        child: Text('Tablet tables view'),
      ),
    );
  }
}
