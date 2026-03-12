// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lembaga_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cabangListHash() => r'b62815f1f5aa6e3f0710f750b60b4c4d8ca18842';

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

abstract class _$CabangList
    extends BuildlessAutoDisposeAsyncNotifier<List<CabangModel>> {
  late final String lembagaId;

  FutureOr<List<CabangModel>> build(
    String lembagaId,
  );
}

/// See also [CabangList].
@ProviderFor(CabangList)
const cabangListProvider = CabangListFamily();

/// See also [CabangList].
class CabangListFamily extends Family<AsyncValue<List<CabangModel>>> {
  /// See also [CabangList].
  const CabangListFamily();

  /// See also [CabangList].
  CabangListProvider call(
    String lembagaId,
  ) {
    return CabangListProvider(
      lembagaId,
    );
  }

  @override
  CabangListProvider getProviderOverride(
    covariant CabangListProvider provider,
  ) {
    return call(
      provider.lembagaId,
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
  String? get name => r'cabangListProvider';
}

/// See also [CabangList].
class CabangListProvider extends AutoDisposeAsyncNotifierProviderImpl<
    CabangList, List<CabangModel>> {
  /// See also [CabangList].
  CabangListProvider(
    String lembagaId,
  ) : this._internal(
          () => CabangList()..lembagaId = lembagaId,
          from: cabangListProvider,
          name: r'cabangListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$cabangListHash,
          dependencies: CabangListFamily._dependencies,
          allTransitiveDependencies:
              CabangListFamily._allTransitiveDependencies,
          lembagaId: lembagaId,
        );

  CabangListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.lembagaId,
  }) : super.internal();

  final String lembagaId;

  @override
  FutureOr<List<CabangModel>> runNotifierBuild(
    covariant CabangList notifier,
  ) {
    return notifier.build(
      lembagaId,
    );
  }

  @override
  Override overrideWith(CabangList Function() create) {
    return ProviderOverride(
      origin: this,
      override: CabangListProvider._internal(
        () => create()..lembagaId = lembagaId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        lembagaId: lembagaId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<CabangList, List<CabangModel>>
      createElement() {
    return _CabangListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CabangListProvider && other.lembagaId == lembagaId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, lembagaId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CabangListRef on AutoDisposeAsyncNotifierProviderRef<List<CabangModel>> {
  /// The parameter `lembagaId` of this provider.
  String get lembagaId;
}

class _CabangListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<CabangList,
        List<CabangModel>> with CabangListRef {
  _CabangListProviderElement(super.provider);

  @override
  String get lembagaId => (origin as CabangListProvider).lembagaId;
}

String _$divisiListHash() => r'd27a93e5740bdc05efaed655be4f5b8ce6eb23ce';

abstract class _$DivisiList
    extends BuildlessAutoDisposeAsyncNotifier<List<DivisiModel>> {
  late final String lembagaId;

  FutureOr<List<DivisiModel>> build(
    String lembagaId,
  );
}

/// See also [DivisiList].
@ProviderFor(DivisiList)
const divisiListProvider = DivisiListFamily();

/// See also [DivisiList].
class DivisiListFamily extends Family<AsyncValue<List<DivisiModel>>> {
  /// See also [DivisiList].
  const DivisiListFamily();

  /// See also [DivisiList].
  DivisiListProvider call(
    String lembagaId,
  ) {
    return DivisiListProvider(
      lembagaId,
    );
  }

  @override
  DivisiListProvider getProviderOverride(
    covariant DivisiListProvider provider,
  ) {
    return call(
      provider.lembagaId,
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
  String? get name => r'divisiListProvider';
}

/// See also [DivisiList].
class DivisiListProvider extends AutoDisposeAsyncNotifierProviderImpl<
    DivisiList, List<DivisiModel>> {
  /// See also [DivisiList].
  DivisiListProvider(
    String lembagaId,
  ) : this._internal(
          () => DivisiList()..lembagaId = lembagaId,
          from: divisiListProvider,
          name: r'divisiListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$divisiListHash,
          dependencies: DivisiListFamily._dependencies,
          allTransitiveDependencies:
              DivisiListFamily._allTransitiveDependencies,
          lembagaId: lembagaId,
        );

  DivisiListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.lembagaId,
  }) : super.internal();

  final String lembagaId;

  @override
  FutureOr<List<DivisiModel>> runNotifierBuild(
    covariant DivisiList notifier,
  ) {
    return notifier.build(
      lembagaId,
    );
  }

  @override
  Override overrideWith(DivisiList Function() create) {
    return ProviderOverride(
      origin: this,
      override: DivisiListProvider._internal(
        () => create()..lembagaId = lembagaId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        lembagaId: lembagaId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DivisiList, List<DivisiModel>>
      createElement() {
    return _DivisiListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DivisiListProvider && other.lembagaId == lembagaId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, lembagaId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DivisiListRef on AutoDisposeAsyncNotifierProviderRef<List<DivisiModel>> {
  /// The parameter `lembagaId` of this provider.
  String get lembagaId;
}

class _DivisiListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<DivisiList,
        List<DivisiModel>> with DivisiListRef {
  _DivisiListProviderElement(super.provider);

  @override
  String get lembagaId => (origin as DivisiListProvider).lembagaId;
}

String _$jabatanListHash() => r'c35ba4a75da5e25524a9dda1b002940ccad0ad92';

abstract class _$JabatanList
    extends BuildlessAutoDisposeAsyncNotifier<List<JabatanModel>> {
  late final String lembagaId;

  FutureOr<List<JabatanModel>> build(
    String lembagaId,
  );
}

/// See also [JabatanList].
@ProviderFor(JabatanList)
const jabatanListProvider = JabatanListFamily();

/// See also [JabatanList].
class JabatanListFamily extends Family<AsyncValue<List<JabatanModel>>> {
  /// See also [JabatanList].
  const JabatanListFamily();

  /// See also [JabatanList].
  JabatanListProvider call(
    String lembagaId,
  ) {
    return JabatanListProvider(
      lembagaId,
    );
  }

  @override
  JabatanListProvider getProviderOverride(
    covariant JabatanListProvider provider,
  ) {
    return call(
      provider.lembagaId,
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
  String? get name => r'jabatanListProvider';
}

/// See also [JabatanList].
class JabatanListProvider extends AutoDisposeAsyncNotifierProviderImpl<
    JabatanList, List<JabatanModel>> {
  /// See also [JabatanList].
  JabatanListProvider(
    String lembagaId,
  ) : this._internal(
          () => JabatanList()..lembagaId = lembagaId,
          from: jabatanListProvider,
          name: r'jabatanListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$jabatanListHash,
          dependencies: JabatanListFamily._dependencies,
          allTransitiveDependencies:
              JabatanListFamily._allTransitiveDependencies,
          lembagaId: lembagaId,
        );

  JabatanListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.lembagaId,
  }) : super.internal();

  final String lembagaId;

  @override
  FutureOr<List<JabatanModel>> runNotifierBuild(
    covariant JabatanList notifier,
  ) {
    return notifier.build(
      lembagaId,
    );
  }

  @override
  Override overrideWith(JabatanList Function() create) {
    return ProviderOverride(
      origin: this,
      override: JabatanListProvider._internal(
        () => create()..lembagaId = lembagaId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        lembagaId: lembagaId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<JabatanList, List<JabatanModel>>
      createElement() {
    return _JabatanListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is JabatanListProvider && other.lembagaId == lembagaId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, lembagaId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin JabatanListRef
    on AutoDisposeAsyncNotifierProviderRef<List<JabatanModel>> {
  /// The parameter `lembagaId` of this provider.
  String get lembagaId;
}

class _JabatanListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<JabatanList,
        List<JabatanModel>> with JabatanListRef {
  _JabatanListProviderElement(super.provider);

  @override
  String get lembagaId => (origin as JabatanListProvider).lembagaId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
