// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kurikulum_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$kurikulumListHash() => r'c8ce67544014dccfb04ce3e849ab748fda5a2325';

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

String _$jenjangListHash() => r'8621e4813ea1aab39190deeb695f32c032bb067b';

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

String _$levelListHash() => r'e76be626930a82c48e67f685c6bad30d7fa73c0d';

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

String _$modulListHash() => r'c9034b3a5f841e085fb8954d1cf9d62c75fa4779';

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

String _$targetMetrikListHash() => r'f424ee33e7edb13e4c48fd676af6c1448b8487ed';

abstract class _$TargetMetrikList
    extends BuildlessAutoDisposeAsyncNotifier<List<TargetMetrikModel>> {
  late final String modulId;

  FutureOr<List<TargetMetrikModel>> build(
    String modulId,
  );
}

/// See also [TargetMetrikList].
@ProviderFor(TargetMetrikList)
const targetMetrikListProvider = TargetMetrikListFamily();

/// See also [TargetMetrikList].
class TargetMetrikListFamily
    extends Family<AsyncValue<List<TargetMetrikModel>>> {
  /// See also [TargetMetrikList].
  const TargetMetrikListFamily();

  /// See also [TargetMetrikList].
  TargetMetrikListProvider call(
    String modulId,
  ) {
    return TargetMetrikListProvider(
      modulId,
    );
  }

  @override
  TargetMetrikListProvider getProviderOverride(
    covariant TargetMetrikListProvider provider,
  ) {
    return call(
      provider.modulId,
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
  String? get name => r'targetMetrikListProvider';
}

/// See also [TargetMetrikList].
class TargetMetrikListProvider extends AutoDisposeAsyncNotifierProviderImpl<
    TargetMetrikList, List<TargetMetrikModel>> {
  /// See also [TargetMetrikList].
  TargetMetrikListProvider(
    String modulId,
  ) : this._internal(
          () => TargetMetrikList()..modulId = modulId,
          from: targetMetrikListProvider,
          name: r'targetMetrikListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$targetMetrikListHash,
          dependencies: TargetMetrikListFamily._dependencies,
          allTransitiveDependencies:
              TargetMetrikListFamily._allTransitiveDependencies,
          modulId: modulId,
        );

  TargetMetrikListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.modulId,
  }) : super.internal();

  final String modulId;

  @override
  FutureOr<List<TargetMetrikModel>> runNotifierBuild(
    covariant TargetMetrikList notifier,
  ) {
    return notifier.build(
      modulId,
    );
  }

  @override
  Override overrideWith(TargetMetrikList Function() create) {
    return ProviderOverride(
      origin: this,
      override: TargetMetrikListProvider._internal(
        () => create()..modulId = modulId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        modulId: modulId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<TargetMetrikList,
      List<TargetMetrikModel>> createElement() {
    return _TargetMetrikListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TargetMetrikListProvider && other.modulId == modulId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, modulId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TargetMetrikListRef
    on AutoDisposeAsyncNotifierProviderRef<List<TargetMetrikModel>> {
  /// The parameter `modulId` of this provider.
  String get modulId;
}

class _TargetMetrikListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<TargetMetrikList,
        List<TargetMetrikModel>> with TargetMetrikListRef {
  _TargetMetrikListProviderElement(super.provider);

  @override
  String get modulId => (origin as TargetMetrikListProvider).modulId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
