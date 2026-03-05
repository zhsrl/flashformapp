import 'package:flashform_app/features/settings/views/desktop/settings_view_desktop.dart';
import 'package:flashform_app/features/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: SettingsViewDesktop(),
      desktop: SettingsViewDesktop(),
      tablet: SettingsViewDesktop(),
    );
  }
}
