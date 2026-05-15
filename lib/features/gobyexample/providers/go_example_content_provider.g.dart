// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'go_example_content_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$goExampleContentNotifierHash() =>
    r'2be6e784793e8eb098b381ef26791048713b80dc';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$GoExampleContentNotifier
    extends BuildlessAutoDisposeAsyncNotifier<GoExample?> {
  late final String slug;

  FutureOr<GoExample?> build(String slug);
}

/// Per-slug example content. Returns `null` when nothing is cached for that
/// slug yet (i.e. user hasn't downloaded it). Call [fetchContent] to download.
///
/// Copied from [GoExampleContentNotifier].
@ProviderFor(GoExampleContentNotifier)
const goExampleContentNotifierProvider = GoExampleContentNotifierFamily();

/// Per-slug example content. Returns `null` when nothing is cached for that
/// slug yet (i.e. user hasn't downloaded it). Call [fetchContent] to download.
///
/// Copied from [GoExampleContentNotifier].
class GoExampleContentNotifierFamily extends Family<AsyncValue<GoExample?>> {
  /// Per-slug example content. Returns `null` when nothing is cached for that
  /// slug yet (i.e. user hasn't downloaded it). Call [fetchContent] to download.
  ///
  /// Copied from [GoExampleContentNotifier].
  const GoExampleContentNotifierFamily();

  /// Per-slug example content. Returns `null` when nothing is cached for that
  /// slug yet (i.e. user hasn't downloaded it). Call [fetchContent] to download.
  ///
  /// Copied from [GoExampleContentNotifier].
  GoExampleContentNotifierProvider call(String slug) {
    return GoExampleContentNotifierProvider(slug);
  }

  @override
  GoExampleContentNotifierProvider getProviderOverride(
    covariant GoExampleContentNotifierProvider provider,
  ) {
    return call(provider.slug);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'goExampleContentNotifierProvider';
}

/// Per-slug example content. Returns `null` when nothing is cached for that
/// slug yet (i.e. user hasn't downloaded it). Call [fetchContent] to download.
///
/// Copied from [GoExampleContentNotifier].
class GoExampleContentNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          GoExampleContentNotifier,
          GoExample?
        > {
  /// Per-slug example content. Returns `null` when nothing is cached for that
  /// slug yet (i.e. user hasn't downloaded it). Call [fetchContent] to download.
  ///
  /// Copied from [GoExampleContentNotifier].
  GoExampleContentNotifierProvider(String slug)
    : this._internal(
        () => GoExampleContentNotifier()..slug = slug,
        from: goExampleContentNotifierProvider,
        name: r'goExampleContentNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$goExampleContentNotifierHash,
        dependencies: GoExampleContentNotifierFamily._dependencies,
        allTransitiveDependencies:
            GoExampleContentNotifierFamily._allTransitiveDependencies,
        slug: slug,
      );

  GoExampleContentNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.slug,
  }) : super.internal();

  final String slug;

  @override
  FutureOr<GoExample?> runNotifierBuild(
    covariant GoExampleContentNotifier notifier,
  ) {
    return notifier.build(slug);
  }

  @override
  Override overrideWith(GoExampleContentNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: GoExampleContentNotifierProvider._internal(
        () => create()..slug = slug,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        slug: slug,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<GoExampleContentNotifier, GoExample?>
  createElement() {
    return _GoExampleContentNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GoExampleContentNotifierProvider && other.slug == slug;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, slug.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GoExampleContentNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<GoExample?> {
  /// The parameter `slug` of this provider.
  String get slug;
}

class _GoExampleContentNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          GoExampleContentNotifier,
          GoExample?
        >
    with GoExampleContentNotifierRef {
  _GoExampleContentNotifierProviderElement(super.provider);

  @override
  String get slug => (origin as GoExampleContentNotifierProvider).slug;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
