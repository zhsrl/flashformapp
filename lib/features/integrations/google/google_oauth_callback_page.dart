import 'package:flashform_app/core/utils/google_oauth.dart';
import 'package:flashform_app/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleOAuthCallbackPage extends StatefulWidget {
  const GoogleOAuthCallbackPage({super.key});

  @override
  State<GoogleOAuthCallbackPage> createState() =>
      _GoogleOAuthCallbackPageState();
}

class _GoogleOAuthCallbackPageState extends State<GoogleOAuthCallbackPage> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    final uri = Uri.base;
    final code = uri.queryParameters['code'];
    final formId = uri.queryParameters['state'];

    if (code == null || formId == null) {
      setState(() {
        _errorMessage = 'Не удалось получить код авторизации.';
      });
      return;
    }

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'google_oauth_exchange',
        body: {
          'code': code,
          'redirect_uri': googleOAuthRedirectUri(),
          'form_id': formId,
        },
      );

      if (response.status >= 400) {
        logger.e('OAuth exchange failed: ${response.data}');
        setState(() {
          _errorMessage = 'Ошибка авторизации Google.';
        });
        return;
      }

      if (!mounted) return;
      context.go('/create-form/$formId?drawer=google');
    } catch (error) {
      logger.e('OAuth exchange error: $error');
      setState(() {
        _errorMessage = 'Ошибка подключения Google Sheets.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _errorMessage == null
            ? const CircularProgressIndicator()
            : Text(_errorMessage!),
      ),
    );
  }
}
