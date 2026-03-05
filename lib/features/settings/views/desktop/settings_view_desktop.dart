import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/features/home/widgets/home_appbar.dart';
import 'package:flashform_app/features/settings/widgets/profile_widget_desktop.dart';
import 'package:flashform_app/features/widgets/ff_tabbar.dart';
import 'package:flutter/material.dart';

class SettingsViewDesktop extends StatefulWidget {
  const SettingsViewDesktop({super.key});

  @override
  State<SettingsViewDesktop> createState() => _SettingsViewDesktopState();
}

class _SettingsViewDesktopState extends State<SettingsViewDesktop>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      endDrawer: ChangePasswordDialog(),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FFTabBar(
                    controller: _tabController,
                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    tabs: [
                      Text('Профиль'),
                      Text('Подписка'),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),

                  [
                    SettingsProfileView(),
                    Text('Subscription'),
                  ].elementAt(_selectedIndex),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
