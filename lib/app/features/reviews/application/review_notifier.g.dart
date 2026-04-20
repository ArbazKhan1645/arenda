// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReviewNotifier)
final reviewProvider = ReviewNotifierProvider._();

final class ReviewNotifierProvider
    extends $NotifierProvider<ReviewNotifier, ReviewState> {
  ReviewNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewNotifierHash();

  @$internal
  @override
  ReviewNotifier create() => ReviewNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewState>(value),
    );
  }
}

String _$reviewNotifierHash() => r'62278394b5537418cde15640e50e0a1d3cb099a9';

abstract class _$ReviewNotifier extends $Notifier<ReviewState> {
  ReviewState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ReviewState, ReviewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReviewState, ReviewState>,
              ReviewState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
