// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'go_by_example_download_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$goByExampleDownloadNotifierHash() =>
    r'c158253eb53f13bda63445a40aca8465c40ce6e5';

/// Orchestrates the bulk "Download All Examples" flow.
///
/// Downloads are sequential to avoid hammering gobyexample.com. A
/// `cancelled` flag is checked between examples for clean cancellation.
///
/// Copied from [GoByExampleDownloadNotifier].
@ProviderFor(GoByExampleDownloadNotifier)
final goByExampleDownloadNotifierProvider =
    AutoDisposeNotifierProvider<
      GoByExampleDownloadNotifier,
      DownloadState
    >.internal(
      GoByExampleDownloadNotifier.new,
      name: r'goByExampleDownloadNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$goByExampleDownloadNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GoByExampleDownloadNotifier = AutoDisposeNotifier<DownloadState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
