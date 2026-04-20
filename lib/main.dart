import 'dart:async';
import 'package:arenda/app/app.dart';
import 'package:arenda/app/core/services/app_initalizer.dart';
import 'package:arenda/app/core/routes/app_router.dart';
import 'package:arenda/app/core/services/platform/error_handler_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';


Future<void> main() async {
  // ──  Register error hooks BEFORE everything else ──────────────────
  final errorHandler = createAndRegisterErrorHandler();
  // ──  Wrap everything in a guarded zone ─────────────────────────────
  await runZonedGuarded(
    () async {
      // ensureInitialized must be called in the same zone as runApp
      final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarContrastEnforced: false,
        ),
      );
      // ──  Bootstrap all services (.env, orientation, storage, supabase, cache)
      final initResult = await AppInitializer.initialize();
      // ── Launch app ────────────────────────────────────────────────
      runApp(
        ProviderScope(
          overrides: [
            ...initResult.providerOverrides,
            initialRouteProvider.overrideWithValue(initResult.initialRoute),
            errorHandlerServiceProvider.overrideWithValue(errorHandler),
          ],
          // Wires Riverpod provider errors into errorHandler
          observers: [RiverpodErrorObserver(errorHandler)],
          child: const ArendaApp(),
        ),
      );
    },
    // ── Zone sink — last line of defence ─────────────────────────────────────
    (Object error, StackTrace stack) {
      errorHandler.onZoneError(error, stack);
    },
  );
}
