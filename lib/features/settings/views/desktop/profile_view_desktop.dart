import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/app_validator.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/auth_controller.dart';
import 'package:flashform_app/data/controller/user_controller.dart';
import 'package:flashform_app/data/model/subscription_plan.dart';
import 'package:flashform_app/data/model/user.dart';
import 'package:flashform_app/features/home/widgets/subscription_widget.dart';
import 'package:flashform_app/features/settings/widgets/subscription_widget.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SettingsProfileView extends ConsumerStatefulWidget {
  const SettingsProfileView({
    super.key,
    this.onOpenChangePassword,
    this.onOpenSubscriptionPlans,
  });

  final VoidCallback? onOpenChangePassword;
  final VoidCallback? onOpenSubscriptionPlans;

  @override
  ConsumerState<SettingsProfileView> createState() =>
      _SettingsProfileViewState();
}

class _SettingsProfileViewState extends ConsumerState<SettingsProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _idController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _idController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);
    final authNotifier = ref.watch(authControllerProvider.notifier);

    // Обработка состояния загрузки
    if (userState.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // Обработка ошибки
    if (userState.error != null) {
      return Center(child: Text('Ошибка: ${userState.error}'));
    }

    final user = userState.user;
    if (user == null) {
      return Center(
        child: LoadingAnimationWidget.waveDots(
          color: AppTheme.secondary,
          size: 30,
        ),
      );
    }

    // Устанавливаем значения в TextFields при первой загрузке
    if (_nameController.text.isEmpty) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _idController.text = user.id;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.only(bottom: 150),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileInfoWidget(
            user: user,
          ),
          Divider(
            thickness: 0.5,
            height: 32,
          ),

          ProfileSubscriptionWidget(
            user: userState.user!,
            onOpenSubscriptionPlans: widget.onOpenSubscriptionPlans!,
          ),
          const SizedBox(
            height: 16,
          ),
          FFTextField(
            title: 'Ваше имя',
            hintText: 'Имя',
            controller: _nameController,
          ),
          FFTextField(
            title: 'Эл. почта',
            hintText: 'example@gmail.com',
            controller: _emailController,
            suffixIcon: HeroIcon(HeroIcons.lockClosed),
            enabled: false,
            bottomMargin: 16,
          ),
          Row(
            children: [
              Expanded(
                flex: 8,
                child: FFTextField(
                  title: 'Код пользователя',
                  hintText: 'id',
                  controller: _idController,

                  enabled: false,
                  bottomMargin: 16,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                flex: 1,
                child: Tooltip(
                  message: 'Скопировать ID',
                  child: IconButton(
                    onPressed: () {
                      String id = _idController.text;

                      Clipboard.setData(
                        ClipboardData(text: id),
                      ).then((_) {
                        if (!context.mounted) return;
                        showSnackbar(
                          context,
                          type: SnackbarType.info,
                          message: 'ID скопирован',
                        );
                      });
                    },
                    icon: HeroIcon(
                      HeroIcons.clipboardDocument,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
            width: context.screenWidth,
            child: FFButton(
              onPressed: () {
                String name = _nameController.text;
                debugPrint('Entered name: $name');
                ref
                    .read(userControllerProvider.notifier)
                    .updateProfile(
                      name: name,
                    );
              },
              text: 'Сохранить',
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: widget.onOpenChangePassword,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.secondary,
                ),
                icon: HeroIcon(HeroIcons.key),
                label: Text('Сменить пароль'),
              ),

              TextButton.icon(
                onPressed: () async {
                  await authNotifier.signOut();
                },

                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                icon: HeroIcon(HeroIcons.arrowLeftEndOnRectangle),
                label: Text('или выйти'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileInfoWidget extends StatelessWidget {
  const ProfileInfoWidget({
    super.key,
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // borderRadius: BorderRadius.circular(20),
            color: AppTheme.primary,
            border: Border.all(
              width: 1,
              color: AppTheme.secondary,
            ),
          ),

          child: Center(
            child: Text(
              '${user.name[0]}${user.name[1]}'.toUpperCase(),

              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 16,
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              user.email,
              style: TextStyle(
                color: AppTheme.secondary.withAlpha(100),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword(String oldPass, String newPass) async {
    final authNotifier = ref.read(authControllerProvider.notifier);

    if (oldPass.isEmpty || newPass.isEmpty) return;

    await authNotifier.changePassword(
      oldPassword: oldPass,
      newPassword: newPass,
    );

    // Проверяем состояние после выполнения
    final authState = ref.read(authControllerProvider);

    authState.when(
      loading: () {
        // Загрузка
      },
      error: (error, stackTrace) {
        // Ошибка - показываем сообщение об ошибке
        if (mounted) {
          showSnackbar(
            context,
            type: SnackbarType.error,
            message: 'Ошибка: $error',
          );
        }
      },
      data: (_) {
        // Успех - закрываем диалог и показываем сообщение
        if (mounted) {
          showSnackbar(
            context,
            type: SnackbarType.success,
            message: 'Пароль успешно изменен',
          );
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Изменить пароль',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: HeroIcon(HeroIcons.xMark),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  FFTextField(
                    title: 'Старый пароль',
                    hintText: 'Введите пароль',
                    isPassword: true,
                    validator: AppValidators.password,
                    controller: _oldPasswordController,
                  ),
                  FFTextField(
                    title: 'Новый пароль',
                    hintText: 'Придумайте новый пароль',
                    isPassword: true,
                    validator: AppValidators.password,
                    controller: _newPasswordController,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: context.screenWidth,

              child: FFButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    String oldPass = _oldPasswordController.text;
                    String newPass = _newPasswordController.text;

                    _changePassword(oldPass, newPass);
                  }
                },
                text: 'Изменить',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
