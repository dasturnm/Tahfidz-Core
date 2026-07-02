// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kurikulum_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$kurikulumServiceHash() => r'0a1034cefa97da579b3a86e3b2cc4e6cc336e773';

/// See also [kurikulumService].
@ProviderFor(kurikulumService)
final kurikulumServiceProvider = AutoDisposeProvider<KurikulumService>.internal(
  kurikulumService,
  name: r'kurikulumServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$kurikulumServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef KurikulumServiceRef = AutoDisposeProviderRef<KurikulumService>;
String _$kurikulumByProgramHash() =>
    r'fb23e1bccd9bcf4ba4d0598f331218440b3c45d7';

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

/// See also [kurikulumByProgram].
@ProviderFor(kurikulumByProgram)
const kurikulumByProgramProvider = KurikulumByProgramFamily();

/// See also [kurikulumByProgram].
class KurikulumByProgramFamily
    extends Family<AsyncValue<List<KurikulumModel>>> {
  /// See also [kurikulumByProgram].
  const KurikulumByProgramFamily();

  /// See also [kurikulumByProgram].
  KurikulumByProgramProvider call(
    String? programId,
  ) {
    return KurikulumByProgramProvider(
      programId,
    );
  }

  @override
  KurikulumByProgramProvider getProviderOverride(
    covariant KurikulumByProgramProvider provider,
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
  String? get name => r'kurikulumByProgramProvider';
}

/// See also [kurikulumByProgram].
class KurikulumByProgramProvider
    extends AutoDisposeFutureProvider<List<KurikulumModel>> {
  /// See also [kurikulumByProgram].
  KurikulumByProgramProvider(
    String? programId,
  ) : this._internal(
          (ref) => kurikulumByProgram(
            ref as KurikulumByProgramRef,
            programId,
          ),
          from: kurikulumByProgramProvider,
          name: r'kurikulumByProgramProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$kurikulumByProgramHash,
          dependencies: KurikulumByProgramFamily._dependencies,
          allTransitiveDependencies:
              KurikulumByProgramFamily._allTransitiveDependencies,
          programId: programId,
        );

  KurikulumByProgramProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.programId,
  }) : super.internal();

  final String? programId;

  @override
  Override overrideWith(
    FutureOr<List<KurikulumModel>> Function(KurikulumByProgramRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: KurikulumByProgramProvider._internal(
        (ref) => create(ref as KurikulumByProgramRef),
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
  AutoDisposeFutureProviderElement<List<KurikulumModel>> createElement() {
    return _KurikulumByProgramProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is KurikulumByProgramProvider && other.programId == programId;
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
mixin KurikulumByProgramRef
    on AutoDisposeFutureProviderRef<List<KurikulumModel>> {
  /// The parameter `programId` of this provider.
  String? get programId;
}

class _KurikulumByProgramProviderElement
    extends AutoDisposeFutureProviderElement<List<KurikulumModel>>
    with KurikulumByProgramRef {
  _KurikulumByProgramProviderElement(super.provider);

  @override
  String? get programId => (origin as KurikulumByProgramProvider).programId;
}

String _$levelsByKurikulumHash() => r'7d455fdbec79ad2da102e6721090e414223f3ce6';

/// See also [levelsByKurikulum].
@ProviderFor(levelsByKurikulum)
const levelsByKurikulumProvider = LevelsByKurikulumFamily();

/// See also [levelsByKurikulum].
class LevelsByKurikulumFamily extends Family<AsyncValue<List<LevelModel>>> {
  /// See also [levelsByKurikulum].
  const LevelsByKurikulumFamily();

  /// See also [levelsByKurikulum].
  LevelsByKurikulumProvider call(
    String? kurikulumId,
  ) {
    return LevelsByKurikulumProvider(
      kurikulumId,
    );
  }

  @override
  LevelsByKurikulumProvider getProviderOverride(
    covariant LevelsByKurikulumProvider provider,
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
  String? get name => r'levelsByKurikulumProvider';
}

/// See also [levelsByKurikulum].
class LevelsByKurikulumProvider
    extends AutoDisposeFutureProvider<List<LevelModel>> {
  /// See also [levelsByKurikulum].
  LevelsByKurikulumProvider(
    String? kurikulumId,
  ) : this._internal(
          (ref) => levelsByKurikulum(
            ref as LevelsByKurikulumRef,
            kurikulumId,
          ),
          from: levelsByKurikulumProvider,
          name: r'levelsByKurikulumProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$levelsByKurikulumHash,
          dependencies: LevelsByKurikulumFamily._dependencies,
          allTransitiveDependencies:
              LevelsByKurikulumFamily._allTransitiveDependencies,
          kurikulumId: kurikulumId,
        );

  LevelsByKurikulumProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.kurikulumId,
  }) : super.internal();

  final String? kurikulumId;

  @override
  Override overrideWith(
    FutureOr<List<LevelModel>> Function(LevelsByKurikulumRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LevelsByKurikulumProvider._internal(
        (ref) => create(ref as LevelsByKurikulumRef),
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
  AutoDisposeFutureProviderElement<List<LevelModel>> createElement() {
    return _LevelsByKurikulumProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LevelsByKurikulumProvider &&
        other.kurikulumId == kurikulumId;
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
mixin LevelsByKurikulumRef on AutoDisposeFutureProviderRef<List<LevelModel>> {
  /// The parameter `kurikulumId` of this provider.
  String? get kurikulumId;
}

class _LevelsByKurikulumProviderElement
    extends AutoDisposeFutureProviderElement<List<LevelModel>>
    with LevelsByKurikulumRef {
  _LevelsByKurikulumProviderElement(super.provider);

  @override
  String? get kurikulumId => (origin as LevelsByKurikulumProvider).kurikulumId;
}

String _$modulByLevelHash() => r'26770c750db12e5ca4e2d806719065f04a76ba91';

/// See also [modulByLevel].
@ProviderFor(modulByLevel)
const modulByLevelProvider = ModulByLevelFamily();

/// See also [modulByLevel].
class ModulByLevelFamily extends Family<AsyncValue<List<ModulModel>>> {
  /// See also [modulByLevel].
  const ModulByLevelFamily();

  /// See also [modulByLevel].
  ModulByLevelProvider call(
    String? levelId,
  ) {
    return ModulByLevelProvider(
      levelId,
    );
  }

  @override
  ModulByLevelProvider getProviderOverride(
    covariant ModulByLevelProvider provider,
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
  String? get name => r'modulByLevelProvider';
}

/// See also [modulByLevel].
class ModulByLevelProvider extends AutoDisposeFutureProvider<List<ModulModel>> {
  /// See also [modulByLevel].
  ModulByLevelProvider(
    String? levelId,
  ) : this._internal(
          (ref) => modulByLevel(
            ref as ModulByLevelRef,
            levelId,
          ),
          from: modulByLevelProvider,
          name: r'modulByLevelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$modulByLevelHash,
          dependencies: ModulByLevelFamily._dependencies,
          allTransitiveDependencies:
              ModulByLevelFamily._allTransitiveDependencies,
          levelId: levelId,
        );

  ModulByLevelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.levelId,
  }) : super.internal();

  final String? levelId;

  @override
  Override overrideWith(
    FutureOr<List<ModulModel>> Function(ModulByLevelRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ModulByLevelProvider._internal(
        (ref) => create(ref as ModulByLevelRef),
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
  AutoDisposeFutureProviderElement<List<ModulModel>> createElement() {
    return _ModulByLevelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ModulByLevelProvider && other.levelId == levelId;
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
mixin ModulByLevelRef on AutoDisposeFutureProviderRef<List<ModulModel>> {
  /// The parameter `levelId` of this provider.
  String? get levelId;
}

class _ModulByLevelProviderElement
    extends AutoDisposeFutureProviderElement<List<ModulModel>>
    with ModulByLevelRef {
  _ModulByLevelProviderElement(super.provider);

  @override
  String? get levelId => (origin as ModulByLevelProvider).levelId;
}

String _$kurikulumListHash() => r'af8c2461ee2f05261faf2e3ab550f064004a5413';

abstract class _$KurikulumList
    extends BuildlessAutoDisposeAsyncNotifier<List<KurikulumModel>> {
  late final String lembagaId;
  late final String search;
  late final String status;
  late final String? programId;
  late final String? tahunAjaranId;

  FutureOr<List<KurikulumModel>> build(
    String lembagaId, {
    String search = '',
    String status = 'Semua',
    String? programId,
    String? tahunAjaranId,
  });
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
    String lembagaId, {
    String search = '',
    String status = 'Semua',
    String? programId,
    String? tahunAjaranId,
  }) {
    return KurikulumListProvider(
      lembagaId,
      search: search,
      status: status,
      programId: programId,
      tahunAjaranId: tahunAjaranId,
    );
  }

  @override
  KurikulumListProvider getProviderOverride(
    covariant KurikulumListProvider provider,
  ) {
    return call(
      provider.lembagaId,
      search: provider.search,
      status: provider.status,
      programId: provider.programId,
      tahunAjaranId: provider.tahunAjaranId,
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
    String lembagaId, {
    String search = '',
    String status = 'Semua',
    String? programId,
    String? tahunAjaranId,
  }) : this._internal(
          () => KurikulumList()
            ..lembagaId = lembagaId
            ..search = search
            ..status = status
            ..programId = programId
            ..tahunAjaranId = tahunAjaranId,
          from: kurikulumListProvider,
          name: r'kurikulumListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$kurikulumListHash,
          dependencies: KurikulumListFamily._dependencies,
          allTransitiveDependencies:
              KurikulumListFamily._allTransitiveDependencies,
          lembagaId: lembagaId,
          search: search,
          status: status,
          programId: programId,
          tahunAjaranId: tahunAjaranId,
        );

  KurikulumListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.lembagaId,
    required this.search,
    required this.status,
    required this.programId,
    required this.tahunAjaranId,
  }) : super.internal();

  final String lembagaId;
  final String search;
  final String status;
  final String? programId;
  final String? tahunAjaranId;

  @override
  FutureOr<List<KurikulumModel>> runNotifierBuild(
    covariant KurikulumList notifier,
  ) {
    return notifier.build(
      lembagaId,
      search: search,
      status: status,
      programId: programId,
      tahunAjaranId: tahunAjaranId,
    );
  }

  @override
  Override overrideWith(KurikulumList Function() create) {
    return ProviderOverride(
      origin: this,
      override: KurikulumListProvider._internal(
        () => create()
          ..lembagaId = lembagaId
          ..search = search
          ..status = status
          ..programId = programId
          ..tahunAjaranId = tahunAjaranId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        lembagaId: lembagaId,
        search: search,
        status: status,
        programId: programId,
        tahunAjaranId: tahunAjaranId,
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
    return other is KurikulumListProvider &&
        other.lembagaId == lembagaId &&
        other.search == search &&
        other.status == status &&
        other.programId == programId &&
        other.tahunAjaranId == tahunAjaranId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, lembagaId.hashCode);
    hash = _SystemHash.combine(hash, search.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);
    hash = _SystemHash.combine(hash, programId.hashCode);
    hash = _SystemHash.combine(hash, tahunAjaranId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin KurikulumListRef
    on AutoDisposeAsyncNotifierProviderRef<List<KurikulumModel>> {
  /// The parameter `lembagaId` of this provider.
  String get lembagaId;

  /// The parameter `search` of this provider.
  String get search;

  /// The parameter `status` of this provider.
  String get status;

  /// The parameter `programId` of this provider.
  String? get programId;

  /// The parameter `tahunAjaranId` of this provider.
  String? get tahunAjaranId;
}

class _KurikulumListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<KurikulumList,
        List<KurikulumModel>> with KurikulumListRef {
  _KurikulumListProviderElement(super.provider);

  @override
  String get lembagaId => (origin as KurikulumListProvider).lembagaId;
  @override
  String get search => (origin as KurikulumListProvider).search;
  @override
  String get status => (origin as KurikulumListProvider).status;
  @override
  String? get programId => (origin as KurikulumListProvider).programId;
  @override
  String? get tahunAjaranId => (origin as KurikulumListProvider).tahunAjaranId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
