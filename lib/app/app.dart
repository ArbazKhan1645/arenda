import 'package:arenda/app/core/routes/app_router.dart';
import 'package:arenda/app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';

class ArendaApp extends ConsumerStatefulWidget {
  const ArendaApp({super.key});

  @override
  ConsumerState<ArendaApp> createState() => _ArendaAppState();
}

class _ArendaAppState extends ConsumerState<ArendaApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Arenda',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.light,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
