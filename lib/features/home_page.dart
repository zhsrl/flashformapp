import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/controller/auth_controller.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'images/logo-light.svg',
              width: 100,
            ),
            const SizedBox(
              height: 12,
            ),
            Consumer(
              builder: (context, ref, child) {
                return FFButton(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (context.mounted) {
                      context.push('/signin');
                    }
                  },
                  isLoading: ref.watch(authControllerProvider),
                  text: 'Sign out',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
