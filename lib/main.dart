import 'package:easy_localization/easy_localization.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/router/router_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bilgviofjcaoxeruzita.supabase.co',
    anonKey: 'sb_publishable_dc9-9PshZxrcJYs85GE3fw_h3YsHQz6',
    authOptions: FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ru'), Locale('kk')],
      path: '/translations',
      saveLocale: true,
      fallbackLocale: const Locale('ru'),
      startLocale: const Locale('ru'),
      child: ProviderScope(child: const MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerConfig = ref.watch(routerProvider);
    return ToastificationWrapper(
      child: MaterialApp.router(
        routerConfig: routerConfig,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'FlashForm',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'GoogleSans',
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            primary: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}
