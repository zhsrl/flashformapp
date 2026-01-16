import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConfirmEmailPage extends StatefulWidget {
  const ConfirmEmailPage({super.key, this.email});

  final String? email;

  @override
  State<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'images/envelope.png',
                width: 80,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                'Confirm your email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'We send confirmation message. Please check email. After confirm we can sign in to Flashform',
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 12,
              ),
              FFButton(
                onPressed: () {
                  context.push('/signin');
                },
                text: 'Go back',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
