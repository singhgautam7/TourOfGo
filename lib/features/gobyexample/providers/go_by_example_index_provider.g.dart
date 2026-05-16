// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'go_by_example_index_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$goByExampleIndexNotifierHash() =>
    r'a43fbc59b931a3a0e18f344488f1fa30a516e128';

/// Offline-first index of all Go by Example entries.
///
/// Copied from [GoByExampleIndexNotifier].
@ProviderFor(GoByExampleIndexNotifier)
final goByExampleIndexNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      GoByExampleIndexNotifier,
      List<GoExampleIndex>
    >.internal(
      GoByExampleIndexNotifier.new,
      name: r'goByExampleIndexNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$goByExampleIndexNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GoByExampleIndexNotifier =
    AutoDisposeAsyncNotifier<List<GoExampleIndex>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
