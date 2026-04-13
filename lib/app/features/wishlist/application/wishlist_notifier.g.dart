// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WishlistNotifier)
final wishlistProvider = WishlistNotifierProvider._();

final class WishlistNotifierProvider
    extends $NotifierProvider<WishlistNotifier, List<ListingEntity>> {
  WishlistNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'wishlistProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$wishlistNotifierHash();

  @$internal
  @override
  WishlistNotifier create() => WishlistNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ListingEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ListingEntity>>(value),
    );
  }
}

String _$wishlistNotifierHash() => r'bfb17db3d800697af288f48f4a52e2968f86aaff';

abstract class _$WishlistNotifier extends $Notifier<List<ListingEntity>> {
  List<ListingEntity> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<ListingEntity>, List<ListingEntity>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<ListingEntity>, List<ListingEntity>>,
        List<ListingEntity>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
