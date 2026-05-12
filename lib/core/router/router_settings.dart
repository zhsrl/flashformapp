import 'dart:async';

import 'package:flashform_app/core/router/adaptive_page.dart';
import 'package:flashform_app/features/auth/presentation/pages/confirm_email.dart';
import 'package:flashform_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:flashform_app/features/auth/presentation/pages/signup_page.dart';
import 'package:flashform_app/features/create_form/presentation/create_form_page.dart';
import 'package:flashform_app/features/forms/views/forms_screen.dart';
import 'package:flashform_app/features/home/screens/home_page.dart';
import 'package:flashform_app/features/auth/presentation/pages/signin_page.dart';
import 'package:flashform_app/features/settings/settings_screen.dart';
import 'package:flashform_app/features/tables/leads_detail_screen.dart';
import 'package:flashform_app/features/tables/leads_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final routerProvider = Provider<GoRouter>(
  (ref) {
    final supabase = Supabase.instance.client;

    return GoRouter(
      initialLocation: '/forms',
      refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
      redirect: (context, state) {
        final session = supabase.auth.currentSession;

        final location = state.uri.path;
        final isSigninOrSignup = location == '/signin' || location == '/signup';
        final isResetPassword = location == '/reset-password';

        if (session == null && !isSigninOrSignup && !isResetPassword) {
          return '/signin';
        }

        if (session != null && isSigninOrSignup) {
          return '/forms';
        }

        return null;
      },
      routes: [
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
          path: '/reset-password',
          pageBuilder: (context, state) => NoTransitionPage(
            child: ResetPasswordPage(),
          ),
        ),
        GoRoute(
          path: '/confirm-email',
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
        GoRoute(
          path: '/detail/:id',

          pageBuilder: (context, state) {
            final id = state.pathParameters['id'];
            return NoTransitionPage(
              child: LeadsDetailScreen(
                formId: id!,
              ),
            );
          },
        ),
        ShellRoute(
          pageBuilder: (context, state, child) {
            return adaptivePage(
              context: context,
              child: HomePage(child: child),
              key: state.pageKey,
            );
          },
          routes: [
            GoRoute(
              path: '/forms',
              pageBuilder: (context, state) => adaptivePage(
                context: context,
                child: FormsScreen(),
                key: state.pageKey,
              ),
            ),
            GoRoute(
              path: '/tables',
              pageBuilder: (context, state) => adaptivePage(
                context: context,
                child: LeadsScreen(),
                key: state.pageKey,
              ),
            ),
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => adaptivePage(
                context: context,
                child: SettingsScreen(),
                key: state.pageKey,
              ),
            ),
          ],
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
