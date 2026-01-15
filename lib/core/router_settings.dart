import 'package:flashform_app/features/home_page.dart';
import 'package:flashform_app/features/signin_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>(
  (ref) {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/signin',
          pageBuilder: (context, state) => NoTransitionPage(
            child: SigninPage(),
          ),
        ),
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => NoTransitionPage(
            child: HomePage(),
          ),
        ),
      ],
    );
  },
);
