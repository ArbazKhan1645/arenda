import 'package:arenda/app/core/routes/app_router.dart';
import 'package:arenda/app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArendaApp extends ConsumerWidget {
  const ArendaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Arenda',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // darkTheme: AppTheme.dark,
      darkTheme: AppTheme.light,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
