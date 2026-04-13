// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HostNotifier)
final hostProvider = HostNotifierProvider._();

final class HostNotifierProvider
    extends $NotifierProvider<HostNotifier, HostState> {
  HostNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'hostProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$hostNotifierHash();

  @$internal
  @override
  HostNotifier create() => HostNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HostState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HostState>(value),
    );
  }
}

String _$hostNotifierHash() => r'3f440f9d1aee2e4641291d3870a4f216976ad0ae';

abstract class _$HostNotifier extends $Notifier<HostState> {
  HostState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HostState, HostState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<HostState, HostState>, HostState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
