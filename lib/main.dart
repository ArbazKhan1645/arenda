import 'dart:async';

import 'package:arenda/app/app.dart';
import 'package:arenda/app/core/services/app_initalizer.dart';
import 'package:arenda/app/core/services/platform/error_handler_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ──  Register error hooks BEFORE everything else ──────────────────
  final errorHandler = createAndRegisterErrorHandler();
  // ──  Wrap everything in a guarded zone ─────────────────────────────
  await runZonedGuarded(
    () async {
      // ──  Bootstrap all services (.env, orientation, storage, supabase, cache)
      final initResult = await AppInitializer.initialize();
      // ── Launch app ────────────────────────────────────────────────
      runApp(
        ProviderScope(
          overrides: [
            ...initResult.providerOverrides,
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
