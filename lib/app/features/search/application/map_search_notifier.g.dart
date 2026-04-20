// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_search_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MapSearchNotifier)
final mapSearchProvider = MapSearchNotifierProvider._();

final class MapSearchNotifierProvider
    extends $NotifierProvider<MapSearchNotifier, MapSearchState> {
  MapSearchNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapSearchNotifierHash();

  @$internal
  @override
  MapSearchNotifier create() => MapSearchNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapSearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapSearchState>(value),
    );
  }
}

String _$mapSearchNotifierHash() => r'3e887571c8c6fd70055f5a68b167cb576f5cd920';

abstract class _$MapSearchNotifier extends $Notifier<MapSearchState> {
  MapSearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MapSearchState, MapSearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MapSearchState, MapSearchState>,
              MapSearchState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
