// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kurikulum_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$kurikulumListHash() => r'8b9777549ca157f0b277e2ecf63e2ab938bce748';

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

String _$jenjangListHash() => r'3909e69ce04417f8ab4aea4f57751445c36417ee';

abstract class _$JenjangList
    extends BuildlessAutoDisposeAsyncNotifier<List<JenjangModel>> {
  late final String kurikulumId;

  FutureOr<List<JenjangModel>> build(
    String kurikulumId,
  );
}

/// See also [JenjangList].
@ProviderFor(JenjangList)
const jenjangListProvider = JenjangListFamily();

/// See also [JenjangList].
class JenjangListFamily extends Family<AsyncValue<List<JenjangModel>>> {
  /// See also [JenjangList].
  const JenjangListFamily();

  /// See also [JenjangList].
  JenjangListProvider call(
    String kurikulumId,
  ) {
    return JenjangListProvider(
      kurikulumId,
    );
  }

  @override
  JenjangListProvider getProviderOverride(
    covariant JenjangListProvider provider,
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
  String? get name => r'jenjangListProvider';
}

/// See also [JenjangList].
class JenjangListProvider extends AutoDisposeAsyncNotifierProviderImpl<
    JenjangList, List<JenjangModel>> {
  /// See also [JenjangList].
  JenjangListProvider(
    String kurikulumId,
  ) : this._internal(
          () => JenjangList()..kurikulumId = kurikulumId,
          from: jenjangListProvider,
          name: r'jenjangListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$jenjangListHash,
          dependencies: JenjangListFamily._dependencies,
          allTransitiveDependencies:
              JenjangListFamily._allTransitiveDependencies,
          kurikulumId: kurikulumId,
        );

  JenjangListProvider._internal(
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
  FutureOr<List<JenjangModel>> runNotifierBuild(
    covariant JenjangList notifier,
  ) {
    return notifier.build(
      kurikulumId,
    );
  }

  @override
  Override overrideWith(JenjangList Function() create) {
    return ProviderOverride(
      origin: this,
      override: JenjangListProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<JenjangList, List<JenjangModel>>
      createElement() {
    return _JenjangListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is JenjangListProvider && other.kurikulumId == kurikulumId;
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
mixin JenjangListRef
    on AutoDisposeAsyncNotifierProviderRef<List<JenjangModel>> {
  /// The parameter `kurikulumId` of this provider.
  String get kurikulumId;
}

class _JenjangListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<JenjangList,
        List<JenjangModel>> with JenjangListRef {
  _JenjangListProviderElement(super.provider);

  @override
  String get kurikulumId => (origin as JenjangListProvider).kurikulumId;
}

String _$levelListHash() => r'cc710a3bfa42a8918f8da1e2d16f659751e5f0d6';

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

String _$modulListHash() => r'3f864f50e81c23b0dc5424366f530c9b212713cb';

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

String _$levelKelasMappingHash() => r'ca5285b197c540eb09d554e971299e5f482f8264';

abstract class _$LevelKelasMapping
    extends BuildlessAutoDisposeAsyncNotifier<List<Map<String, dynamic>>> {
  late final String levelId;

  FutureOr<List<Map<String, dynamic>>> build(
    String levelId,
  );
}

/// See also [LevelKelasMapping].
@ProviderFor(LevelKelasMapping)
const levelKelasMappingProvider = LevelKelasMappingFamily();

/// See also [LevelKelasMapping].
class LevelKelasMappingFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [LevelKelasMapping].
  const LevelKelasMappingFamily();

  /// See also [LevelKelasMapping].
  LevelKelasMappingProvider call(
    String levelId,
  ) {
    return LevelKelasMappingProvider(
      levelId,
    );
  }

  @override
  LevelKelasMappingProvider getProviderOverride(
    covariant LevelKelasMappingProvider provider,
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
  String? get name => r'levelKelasMappingProvider';
}

/// See also [LevelKelasMapping].
class LevelKelasMappingProvider extends AutoDisposeAsyncNotifierProviderImpl<
    LevelKelasMapping, List<Map<String, dynamic>>> {
  /// See also [LevelKelasMapping].
  LevelKelasMappingProvider(
    String levelId,
  ) : this._internal(
          () => LevelKelasMapping()..levelId = levelId,
          from: levelKelasMappingProvider,
          name: r'levelKelasMappingProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$levelKelasMappingHash,
          dependencies: LevelKelasMappingFamily._dependencies,
          allTransitiveDependencies:
              LevelKelasMappingFamily._allTransitiveDependencies,
          levelId: levelId,
        );

  LevelKelasMappingProvider._internal(
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
  FutureOr<List<Map<String, dynamic>>> runNotifierBuild(
    covariant LevelKelasMapping notifier,
  ) {
    return notifier.build(
      levelId,
    );
  }

  @override
  Override overrideWith(LevelKelasMapping Function() create) {
    return ProviderOverride(
      origin: this,
      override: LevelKelasMappingProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<LevelKelasMapping,
      List<Map<String, dynamic>>> createElement() {
    return _LevelKelasMappingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LevelKelasMappingProvider && other.levelId == levelId;
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
mixin LevelKelasMappingRef
    on AutoDisposeAsyncNotifierProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `levelId` of this provider.
  String get levelId;
}

class _LevelKelasMappingProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<LevelKelasMapping,
        List<Map<String, dynamic>>> with LevelKelasMappingRef {
  _LevelKelasMappingProviderElement(super.provider);

  @override
  String get levelId => (origin as LevelKelasMappingProvider).levelId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
