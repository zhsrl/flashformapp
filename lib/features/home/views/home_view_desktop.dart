import 'package:dashed_border/dashed_border.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/app_validator.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/forms_controller.dart';
import 'package:flashform_app/features/home/widgets/home_appbar.dart';
import 'package:flashform_app/features/home/widgets/shared/form_card.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomePageDesktopView extends ConsumerStatefulWidget {
  const HomePageDesktopView({super.key});

  @override
  ConsumerState<HomePageDesktopView> createState() =>
      _HomePageDesktopViewState();
}

class _HomePageDesktopViewState extends ConsumerState<HomePageDesktopView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _formTitleController;

  bool _isCreatingForm = false;

  @override
  void initState() {
    super.initState();
    _formTitleController = TextEditingController();
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
    final formsAsync = ref.watch(formControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: HomeAppBar(),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          showCreateFormDialog();
        },
        elevation: 0,
        backgroundColor: AppTheme.secondary,
        child: HeroIcon(
          HeroIcons.plus,
          color: AppTheme.primary,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: formsAsync.when(
          data: (forms) {
            if (forms.isEmpty) {
              return Center(
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 200,
                    height: 200,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: DashedBorder(
                        color: AppTheme.secondary.withAlpha(100),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HeroIcon(
                            HeroIcons.plusCircle,
                            color: AppTheme.secondary.withAlpha(100),
                            size: 50,
                          ),
                          Text(
                            'Создать вашу первую форму!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.secondary.withAlpha(100),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisExtent: 150,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                crossAxisCount: context.isDesktop
                    ? 4
                    : context.isTablet
                    ? 2
                    : 1,
              ),
              itemCount: forms.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return FormCard(form: forms[index]);
              },
            );
          },
          error: (er, st) {
            throw Exception(er.toString());
          },
          loading: () => Center(
            child: LoadingAnimationWidget.waveDots(
              color: AppTheme.primary,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _formTitleController.dispose();
    super.dispose();
  }
}
