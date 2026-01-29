import 'dart:async';

import 'package:flashform_app/features/auth/confirm_email.dart';
import 'package:flashform_app/features/auth/signup_page.dart';
import 'package:flashform_app/features/create_form/create_form_page.dart';
import 'package:flashform_app/features/home/screens/home_page.dart';
import 'package:flashform_app/features/auth/signin_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final routerProvider = Provider<GoRouter>(
  (ref) {
    final supabase = Supabase.instance.client;
    return GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
      redirect: (context, state) {
        final session = supabase.auth.currentSession;

        final location = state.uri.toString();
        final isAuthPage = location == '/signin' || location == '/signup';

        if (session == null && !isAuthPage) {
          return '/signin';
        }

        if (session != null && isAuthPage) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => NoTransitionPage(
            child: HomePage(),
          ),
        ),
        GoRoute(
          path: '/signin',
          pageBuilder: (context, state) => NoTransitionPage(
            child: SigninPage(),
          ),
        ),
        GoRoute(
          path: '/signup',
          pageBuilder: (context, state) => NoTransitionPage(
            child: SignupPage(),
          ),
        ),
        GoRoute(
          path: '/cofirm-email',
          pageBuilder: (context, state) => NoTransitionPage(
            child: ConfirmEmailPage(),
          ),
        ),
        GoRoute(
          path: '/create-form/:id',

          pageBuilder: (context, state) {
            final id = state.pathParameters['id'];
            return NoTransitionPage(
              child: CreateFormPage(
                formId: id!,
              ),
            );
          },
        ),
      ],
    );
  },
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
