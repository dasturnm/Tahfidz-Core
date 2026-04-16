// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kurikulum_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$kurikulumListHash() => r'af8c2461ee2f05261faf2e3ab550f064004a5413';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
