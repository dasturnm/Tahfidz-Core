// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modul_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$modulListHash() => r'1e317264964afcdc8ab44cb517bceebb319013ec';

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

abstract class _$ModulList
    extends BuildlessAutoDisposeAsyncNotifier<List<ModulModel>> {
  late final String levelId;

  FutureOr<List<ModulModel>> build(
    String levelId,
  );
}

/// See also [ModulList].
@ProviderFor(ModulList)
const modulListProvider = ModulListFamily();

/// See also [ModulList].
class ModulListFamily extends Family<AsyncValue<List<ModulModel>>> {
  /// See also [ModulList].
  const ModulListFamily();

  /// See also [ModulList].
  ModulListProvider call(
    String levelId,
  ) {
    return ModulListProvider(
      levelId,
    );
  }

  @override
  ModulListProvider getProviderOverride(
    covariant ModulListProvider provider,
  ) {
    return call(
      provider.levelId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'modulListProvider';
}

/// See also [ModulList].
class ModulListProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ModulList, List<ModulModel>> {
  /// See also [ModulList].
  ModulListProvider(
    String levelId,
  ) : this._internal(
          () => ModulList()..levelId = levelId,
          from: modulListProvider,
          name: r'modulListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$modulListHash,
          dependencies: ModulListFamily._dependencies,
          allTransitiveDependencies: ModulListFamily._allTransitiveDependencies,
          levelId: levelId,
        );

  ModulListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.levelId,
  }) : super.internal();

  final String levelId;

  @override
  FutureOr<List<ModulModel>> runNotifierBuild(
    covariant ModulList notifier,
  ) {
    return notifier.build(
      levelId,
    );
  }

  @override
  Override overrideWith(ModulList Function() create) {
    return ProviderOverride(
      origin: this,
      override: ModulListProvider._internal(
        () => create()..levelId = levelId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        levelId: levelId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ModulList, List<ModulModel>>
      createElement() {
    return _ModulListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ModulListProvider && other.levelId == levelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, levelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ModulListRef on AutoDisposeAsyncNotifierProviderRef<List<ModulModel>> {
  /// The parameter `levelId` of this provider.
  String get levelId;
}

class _ModulListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ModulList, List<ModulModel>>
    with ModulListRef {
  _ModulListProviderElement(super.provider);

  @override
  String get levelId => (origin as ModulListProvider).levelId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
