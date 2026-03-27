import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/features/home/widgets/home_appbar.dart';
import 'package:flashform_app/features/settings/utils/subscription_plans_presenter.dart';
import 'package:flashform_app/features/settings/views/desktop/profile_view_desktop.dart';
import 'package:flutter/material.dart';

enum EndDrawerType {
  none,
  changePassword,
  subscriptionPlans,
}

class SettingsViewDesktop extends StatefulWidget {
  const SettingsViewDesktop({super.key});

  @override
  State<SettingsViewDesktop> createState() => _SettingsViewDesktopState();
}

class _SettingsViewDesktopState extends State<SettingsViewDesktop>
    with SingleTickerProviderStateMixin {
  EndDrawerType _endDrawerType = EndDrawerType.none;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openChangePasswordDrawer() {
    setState(() => _endDrawerType = EndDrawerType.changePassword);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaffoldKey.currentState?.openEndDrawer();
    });
  }

  void _openSubscriptionPlansDrawer() {
    showSubscriptionPlansPresenter(context);
  }

  Widget _buildDrawerContent() {
    switch (_endDrawerType) {
      case EndDrawerType.changePassword:
        return ChangePasswordDialog();
      case EndDrawerType.subscriptionPlans:
      case EndDrawerType.none:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: HomeAppBar(),
      endDrawer: _endDrawerType != EndDrawerType.none
          ? Drawer(
              width: 400,
              child: _buildDrawerContent(),
            )
          : null,
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: context.isMobile
            ? EdgeInsets.symmetric(horizontal: 16)
            : EdgeInsets.zero,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 500,
                minWidth: 300,
              ),
              child: SettingsProfileView(
                onOpenChangePassword: _openChangePasswordDrawer,
                onOpenSubscriptionPlans: _openSubscriptionPlansDrawer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
