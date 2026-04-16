// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$levelListHash() => r'036e8c56a9240b35a682cd5a8306d3581c3df983';

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

abstract class _$LevelList
    extends BuildlessAutoDisposeAsyncNotifier<List<LevelModel>> {
  late final String jenjangId;

  FutureOr<List<LevelModel>> build(
    String jenjangId,
  );
}

/// See also [LevelList].
@ProviderFor(LevelList)
const levelListProvider = LevelListFamily();

/// See also [LevelList].
class LevelListFamily extends Family<AsyncValue<List<LevelModel>>> {
  /// See also [LevelList].
  const LevelListFamily();

  /// See also [LevelList].
  LevelListProvider call(
    String jenjangId,
  ) {
    return LevelListProvider(
      jenjangId,
    );
  }

  @override
  LevelListProvider getProviderOverride(
    covariant LevelListProvider provider,
  ) {
    return call(
      provider.jenjangId,
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
  String? get name => r'levelListProvider';
}

/// See also [LevelList].
class LevelListProvider
    extends AutoDisposeAsyncNotifierProviderImpl<LevelList, List<LevelModel>> {
  /// See also [LevelList].
  LevelListProvider(
    String jenjangId,
  ) : this._internal(
          () => LevelList()..jenjangId = jenjangId,
          from: levelListProvider,
          name: r'levelListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$levelListHash,
          dependencies: LevelListFamily._dependencies,
          allTransitiveDependencies: LevelListFamily._allTransitiveDependencies,
          jenjangId: jenjangId,
        );

  LevelListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.jenjangId,
  }) : super.internal();

  final String jenjangId;

  @override
  FutureOr<List<LevelModel>> runNotifierBuild(
    covariant LevelList notifier,
  ) {
    return notifier.build(
      jenjangId,
    );
  }

  @override
  Override overrideWith(LevelList Function() create) {
    return ProviderOverride(
      origin: this,
      override: LevelListProvider._internal(
        () => create()..jenjangId = jenjangId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        jenjangId: jenjangId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<LevelList, List<LevelModel>>
      createElement() {
    return _LevelListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LevelListProvider && other.jenjangId == jenjangId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, jenjangId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LevelListRef on AutoDisposeAsyncNotifierProviderRef<List<LevelModel>> {
  /// The parameter `jenjangId` of this provider.
  String get jenjangId;
}

class _LevelListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<LevelList, List<LevelModel>>
    with LevelListRef {
  _LevelListProviderElement(super.provider);

  @override
  String get jenjangId => (origin as LevelListProvider).jenjangId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
