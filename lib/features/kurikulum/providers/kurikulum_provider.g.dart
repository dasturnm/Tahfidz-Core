// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kurikulum_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$kurikulumListHash() => r'12ba8b0b7cca77308d2b68abedf4a58ebe699c2d';

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

abstract class _$KurikulumList
    extends BuildlessAutoDisposeAsyncNotifier<List<KurikulumModel>> {
  late final String programId;

  FutureOr<List<KurikulumModel>> build(
    String programId,
  );
}

/// See also [KurikulumList].
@ProviderFor(KurikulumList)
const kurikulumListProvider = KurikulumListFamily();

/// See also [KurikulumList].
class KurikulumListFamily extends Family<AsyncValue<List<KurikulumModel>>> {
  /// See also [KurikulumList].
  const KurikulumListFamily();

  /// See also [KurikulumList].
  KurikulumListProvider call(
    String programId,
  ) {
    return KurikulumListProvider(
      programId,
    );
  }

  @override
  KurikulumListProvider getProviderOverride(
    covariant KurikulumListProvider provider,
  ) {
    return call(
      provider.programId,
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
  String? get name => r'kurikulumListProvider';
}

/// See also [KurikulumList].
class KurikulumListProvider extends AutoDisposeAsyncNotifierProviderImpl<
    KurikulumList, List<KurikulumModel>> {
  /// See also [KurikulumList].
  KurikulumListProvider(
    String programId,
  ) : this._internal(
          () => KurikulumList()..programId = programId,
          from: kurikulumListProvider,
          name: r'kurikulumListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$kurikulumListHash,
          dependencies: KurikulumListFamily._dependencies,
          allTransitiveDependencies:
              KurikulumListFamily._allTransitiveDependencies,
          programId: programId,
        );

  KurikulumListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.programId,
  }) : super.internal();

  final String programId;

  @override
  FutureOr<List<KurikulumModel>> runNotifierBuild(
    covariant KurikulumList notifier,
  ) {
    return notifier.build(
      programId,
    );
  }

  @override
  Override overrideWith(KurikulumList Function() create) {
    return ProviderOverride(
      origin: this,
      override: KurikulumListProvider._internal(
        () => create()..programId = programId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        programId: programId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<KurikulumList, List<KurikulumModel>>
      createElement() {
    return _KurikulumListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is KurikulumListProvider && other.programId == programId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, programId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin KurikulumListRef
    on AutoDisposeAsyncNotifierProviderRef<List<KurikulumModel>> {
  /// The parameter `programId` of this provider.
  String get programId;
}

class _KurikulumListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<KurikulumList,
        List<KurikulumModel>> with KurikulumListRef {
  _KurikulumListProviderElement(super.provider);

  @override
  String get programId => (origin as KurikulumListProvider).programId;
}

String _$levelListHash() => r'9246cb457255a6ef427d43d08e9c2c8bfb162381';

abstract class _$LevelList
    extends BuildlessAutoDisposeAsyncNotifier<List<LevelModel>> {
  late final String kurikulumId;

  FutureOr<List<LevelModel>> build(
    String kurikulumId,
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
    String kurikulumId,
  ) {
    return LevelListProvider(
      kurikulumId,
    );
  }

  @override
  LevelListProvider getProviderOverride(
    covariant LevelListProvider provider,
  ) {
    return call(
      provider.kurikulumId,
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
    String kurikulumId,
  ) : this._internal(
          () => LevelList()..kurikulumId = kurikulumId,
          from: levelListProvider,
          name: r'levelListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$levelListHash,
          dependencies: LevelListFamily._dependencies,
          allTransitiveDependencies: LevelListFamily._allTransitiveDependencies,
          kurikulumId: kurikulumId,
        );

  LevelListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.kurikulumId,
  }) : super.internal();

  final String kurikulumId;

  @override
  FutureOr<List<LevelModel>> runNotifierBuild(
    covariant LevelList notifier,
  ) {
    return notifier.build(
      kurikulumId,
    );
  }

  @override
  Override overrideWith(LevelList Function() create) {
    return ProviderOverride(
      origin: this,
      override: LevelListProvider._internal(
        () => create()..kurikulumId = kurikulumId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        kurikulumId: kurikulumId,
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
    return other is LevelListProvider && other.kurikulumId == kurikulumId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, kurikulumId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LevelListRef on AutoDisposeAsyncNotifierProviderRef<List<LevelModel>> {
  /// The parameter `kurikulumId` of this provider.
  String get kurikulumId;
}

class _LevelListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<LevelList, List<LevelModel>>
    with LevelListRef {
  _LevelListProviderElement(super.provider);

  @override
  String get kurikulumId => (origin as LevelListProvider).kurikulumId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
