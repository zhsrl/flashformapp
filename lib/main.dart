import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/router/router_settings.dart';
import 'package:flashform_app/data/controller/forms_controller.dart';
import 'package:flashform_app/data/controller/plan_usage_controller.dart';
import 'package:flashform_app/data/controller/user_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await EasyLocalization.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Supabase.initialize(
    url: 'https://bilgviofjcaoxeruzita.supabase.co',
    anonKey: 'sb_publishable_dc9-9PshZxrcJYs85GE3fw_h3YsHQz6',
    authOptions: FlutterAuthClientOptions(
      authFlowType: kIsWeb ? AuthFlowType.implicit : AuthFlowType.pkce,
    ),
  );
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ru'), Locale('kk')],
      path: 'assets/translations',
      saveLocale: true,
      fallbackLocale: const Locale('ru'),
      startLocale: const Locale('ru'),
      child: ProviderScope(child: const MyApp()),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription<AuthState>? _authSubscription;
  String? _activeUserId;

  @override
  void initState() {
    super.initState();
    final auth = Supabase.instance.client.auth;
    _activeUserId = auth.currentUser?.id;

    _authSubscription = auth.onAuthStateChange.listen((event) {
      final nextUserId = event.session?.user.id;

      if (_activeUserId == nextUserId) return;

      _activeUserId = nextUserId;

      // Important: user-scoped providers keep old cache unless explicitly reset.
      ref.invalidate(userControllerProvider);
      ref.invalidate(formControllerProvider);
      ref.invalidate(planUsageProvider);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routerConfig = ref.watch(routerProvider);

    return ToastificationWrapper(
      child: MaterialApp.router(
        routerConfig: routerConfig,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'Flashform: Создай лендинг с формой за 10 минут!',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'GoogleSans',
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppTheme.secondary,
            primary: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}
