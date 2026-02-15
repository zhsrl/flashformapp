import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/app_validator.dart';
import 'package:flashform_app/data/controller/forms_controller.dart';
import 'package:flashform_app/features/home/widgets/ff_bottom_nav_bar.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.child});

  final Widget child;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _formTitleController;

  bool _isCreatingForm = false;

  @override
  void initState() {
    super.initState();
    _formTitleController = TextEditingController();
  }

  int _getSelectedindex(String location) {
    if (location.startsWith('/forms')) return 0;
    if (location.startsWith('/tables')) return 1;
    if (location.startsWith('/settings')) return 2;

    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/forms');
      case 1:
        context.go('/tables');

      case 2:
        context.go('/settings');
    }
  }

  showCreateFormDialog() {
    showDialog(
      context: context,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.background,

              title: Text(
                'Create new form',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: Consumer(
                builder: (context, ref, child) {
                  return SizedBox(
                    width: 350,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Form(
                          key: _formKey,
                          child: FFTextField(
                            prefixIcon: HeroIcon(HeroIcons.listBullet),
                            hintText: 'Enter form name',
                            controller: _formTitleController,
                            validator: AppValidators.validatorForEmpty,
                          ),
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: FFButton(
                            isLoading: _isCreatingForm,
                            onPressed: () async {
                              try {
                                if (_formKey.currentState!.validate()) {
                                  setDialogState(() {
                                    _isCreatingForm = true;
                                  });

                                  String name = _formTitleController.text
                                      .trim();
                                  final newFormId = await ref
                                      .read(formControllerProvider.notifier)
                                      .createNewForm(name);

                                  if (!context.mounted) return;

                                  debugPrint('Form created! ID: $newFormId');

                                  if (newFormId != null) {
                                    Navigator.pop(context);

                                    setDialogState(() {
                                      _isCreatingForm = false;
                                    });

                                    context.go('/create-form/$newFormId');
                                  }
                                }
                              } finally {
                                if (mounted) {
                                  setDialogState(() {
                                    _isCreatingForm = false;
                                  });
                                }
                              }
                            },
                            text: 'Create',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // return ResponsiveLayout(
    //   mobile: SizedBox(),
    //   desktop: HomePageDesktopView(),
    // );

    final String location = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          FFBottomNavBar(
            selectedIndex: _getSelectedindex(location),
            onItemTapped: (index) {
              _onItemTapped(index, context);
            },
            onCreateForm: () {
              showCreateFormDialog();
            },
          ),
        ],
      ),
    );
  }
}
