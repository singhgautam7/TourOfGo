// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$compileNotifierHash() => r'317053ac2254d205e9778dd319062c94e8cb50c6';

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

abstract class _$CompileNotifier
    extends BuildlessAutoDisposeNotifier<AsyncValue<CompileResponse?>> {
  late final String chapterKey;
  late final int lessonIndex;

  AsyncValue<CompileResponse?> build(String chapterKey, int lessonIndex);
}

/// See also [CompileNotifier].
@ProviderFor(CompileNotifier)
const compileNotifierProvider = CompileNotifierFamily();

/// See also [CompileNotifier].
class CompileNotifierFamily extends Family<AsyncValue<CompileResponse?>> {
  /// See also [CompileNotifier].
  const CompileNotifierFamily();

  /// See also [CompileNotifier].
  CompileNotifierProvider call(String chapterKey, int lessonIndex) {
    return CompileNotifierProvider(chapterKey, lessonIndex);
  }

  @override
  CompileNotifierProvider getProviderOverride(
    covariant CompileNotifierProvider provider,
  ) {
    return call(provider.chapterKey, provider.lessonIndex);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'compileNotifierProvider';
}

/// See also [CompileNotifier].
class CompileNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<
          CompileNotifier,
          AsyncValue<CompileResponse?>
        > {
  /// See also [CompileNotifier].
  CompileNotifierProvider(String chapterKey, int lessonIndex)
    : this._internal(
        () => CompileNotifier()
          ..chapterKey = chapterKey
          ..lessonIndex = lessonIndex,
        from: compileNotifierProvider,
        name: r'compileNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$compileNotifierHash,
        dependencies: CompileNotifierFamily._dependencies,
        allTransitiveDependencies:
            CompileNotifierFamily._allTransitiveDependencies,
        chapterKey: chapterKey,
        lessonIndex: lessonIndex,
      );

  CompileNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chapterKey,
    required this.lessonIndex,
  }) : super.internal();

  final String chapterKey;
  final int lessonIndex;

  @override
  AsyncValue<CompileResponse?> runNotifierBuild(
    covariant CompileNotifier notifier,
  ) {
    return notifier.build(chapterKey, lessonIndex);
  }

  @override
  Override overrideWith(CompileNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: CompileNotifierProvider._internal(
        () => create()
          ..chapterKey = chapterKey
          ..lessonIndex = lessonIndex,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chapterKey: chapterKey,
        lessonIndex: lessonIndex,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    CompileNotifier,
    AsyncValue<CompileResponse?>
  >
  createElement() {
    return _CompileNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CompileNotifierProvider &&
        other.chapterKey == chapterKey &&
        other.lessonIndex == lessonIndex;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chapterKey.hashCode);
    hash = _SystemHash.combine(hash, lessonIndex.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CompileNotifierRef
    on AutoDisposeNotifierProviderRef<AsyncValue<CompileResponse?>> {
  /// The parameter `chapterKey` of this provider.
  String get chapterKey;

  /// The parameter `lessonIndex` of this provider.
  int get lessonIndex;
}

class _CompileNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          CompileNotifier,
          AsyncValue<CompileResponse?>
        >
    with CompileNotifierRef {
  _CompileNotifierProviderElement(super.provider);

  @override
  String get chapterKey => (origin as CompileNotifierProvider).chapterKey;
  @override
  int get lessonIndex => (origin as CompileNotifierProvider).lessonIndex;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
