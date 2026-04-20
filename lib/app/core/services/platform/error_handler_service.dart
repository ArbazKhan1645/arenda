import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ERROR RECORD — normalized error envelope
// ─────────────────────────────────────────────────────────────────────────────

enum ErrorSource { flutter, zone, platform, riverpod }

class AppError {
  final Object error;
  final StackTrace? stackTrace;
  final ErrorSource source;
  final DateTime timestamp;

  AppError({required this.error, required this.source, this.stackTrace})
    : timestamp = DateTime.now();

  @override
  String toString() =>
      '[${source.name.toUpperCase()}] $error\n${stackTrace ?? ''}';
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERFACE
// ─────────────────────────────────────────────────────────────────────────────

abstract class IErrorHandlerService {
  /// Register Flutter, Platform, and Riverpod error hooks
  void register();

  /// The zone error handler — pass to RunZoneGuarded's onError
  void onZoneError(Object error, StackTrace stack);

  /// Manually report an error (from try/catch in app code)
  void report(Object error, StackTrace? stack, {ErrorSource source});
}

// ─────────────────────────────────────────────────────────────────────────────
// IMPLEMENTATION
// ─────────────────────────────────────────────────────────────────────────────

class ErrorHandlerService implements IErrorHandlerService {
  // Previous Flutter error handler — we chain so we don't swallow widget errors
  FlutterExceptionHandler? _previousFlutterHandler;

  @override
  void register() {
    _registerFlutterErrors();
    _registerPlatformErrors();
    // Riverpod errors → pass RiverpodErrorObserver to ProviderScope(observers:[]) in main.dart
  }

  // ── Flutter framework errors (widget build, layout, etc.) ─────────────────

  void _registerFlutterErrors() {
    _previousFlutterHandler = FlutterError.onError;

    FlutterError.onError = (FlutterErrorDetails details) {
      // 1. Always call the previous handler first (prints in debug, etc.)
      _previousFlutterHandler?.call(details);

      // 2. In release: report to your crash service
      if (!kDebugMode) {
        report(details.exception, details.stack, source: ErrorSource.flutter);
      }
    };

    debugPrint('[ErrorHandlerService] ✓ FlutterError.onError registered');
  }

  // ── Platform / async errors outside Flutter (e.g. dart:io, isolates) ──────

  void _registerPlatformErrors() {
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      report(error, stack, source: ErrorSource.platform);

      // Return true = error handled, false = rethrow
      return true;
    };

    debugPrint('[ErrorHandlerService] ✓ PlatformDispatcher.onError registered');
  }

  // ── Zone error (called from runZoneGuarded's onError) ─────────────────────

  @override
  void onZoneError(Object error, StackTrace stack) {
    report(error, stack);
  }

  // ── Unified report method ─────────────────────────────────────────────────

  @override
  void report(
    Object error,
    StackTrace? stack, {
    ErrorSource source = ErrorSource.zone,
  }) {
    final appError = AppError(error: error, stackTrace: stack, source: source);

    _log(appError);
    _sendToCrashService(appError);
  }

  void _log(AppError appError) {
    // Always log in debug; in release only log non-noise errors
    if (kDebugMode) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('[${appError.source.name.toUpperCase()} ERROR]');
      debugPrint('Time   : ${appError.timestamp.toIso8601String()}');
      debugPrint('Error  : ${appError.error}');
      if (appError.stackTrace != null) {
        debugPrint('Stack  :\n${appError.stackTrace}');
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  void _sendToCrashService(AppError appError) {
    // 🔌 Plug in your crash reporting here:
    //
    // ── Sentry ────────────────────────────────────────────────────────────────
    // await Sentry.captureException(
    //   appError.error,
    //   stackTrace: appError.stackTrace,
    // );
    //
    // ── Firebase Crashlytics ──────────────────────────────────────────────────
    // await FirebaseCrashlytics.instance.recordError(
    //   appError.error,
    //   appError.stackTrace,
    //   fatal: appError.source == ErrorSource.zone,
    // );
    //
    // ── Supabase custom crash log table ───────────────────────────────────────
    // Supabase.instance.client.from('crash_logs').insert({
    //   'error'     : appError.error.toString(),
    //   'stack'     : appError.stackTrace?.toString(),
    //   'source'    : appError.source.name,
    //   'timestamp' : appError.timestamp.toIso8601String(),
    // });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RIVERPOD OBSERVER — hooks into provider errors
// ─────────────────────────────────────────────────────────────────────────────

/// Public observer — pass to [ProviderScope.observers] in main.dart
final class RiverpodErrorObserver extends ProviderObserver {
  final ErrorHandlerService _handler;

  const RiverpodErrorObserver(this._handler);

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    final providerName = context.provider.name ?? context.provider.runtimeType;

    _handler.report(
      'Provider [$providerName] threw: $error',
      stackTrace,
      source: ErrorSource.riverpod,
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// BOOTSTRAP HELPER — called in main() before runApp
// ─────────────────────────────────────────────────────────────────────────────

/// Creates the service and registers all hooks.
/// Riverpod errors: pass [RiverpodErrorObserver] to ProviderScope(observers:[]) in main.dart.
ErrorHandlerService createAndRegisterErrorHandler() {
  final handler = ErrorHandlerService();
  handler.register();
  return handler;
}

// ─────────────────────────────────────────────────────────────────────────────
// RIVERPOD PROVIDER
// ─────────────────────────────────────────────────────────────────────────────

final errorHandlerServiceProvider = Provider<IErrorHandlerService>((ref) {
  throw UnimplementedError(
    'errorHandlerServiceProvider must be overridden in ProviderScope.',
  );
});
