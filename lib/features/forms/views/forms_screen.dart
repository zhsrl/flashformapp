import 'package:flashform_app/features/forms/views/desktop/forms_view_desktop.dart';
import 'package:flashform_app/features/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';

class FormsScreen extends StatelessWidget {
  const FormsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: Center(
        child: Text('Mobile forms view'),
      ),
      desktop: FormsViewDesktop(),
      tablet: Center(
        child: Text('Tablet forms view'),
      ),
    );
  }
}
