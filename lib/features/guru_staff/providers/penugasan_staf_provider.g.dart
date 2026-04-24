// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'penugasan_staf_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$penugasanStafListHash() => r'3280ed185e7b96345f4c5118d03ab954a2c4e66f';

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

abstract class _$PenugasanStafList
    extends BuildlessAutoDisposeAsyncNotifier<List<PenugasanStafModel>> {
  late final String lembagaId;

  FutureOr<List<PenugasanStafModel>> build(
    String lembagaId,
  );
}

/// See also [PenugasanStafList].
@ProviderFor(PenugasanStafList)
const penugasanStafListProvider = PenugasanStafListFamily();

/// See also [PenugasanStafList].
class PenugasanStafListFamily
    extends Family<AsyncValue<List<PenugasanStafModel>>> {
  /// See also [PenugasanStafList].
  const PenugasanStafListFamily();

  /// See also [PenugasanStafList].
  PenugasanStafListProvider call(
    String lembagaId,
  ) {
    return PenugasanStafListProvider(
      lembagaId,
    );
  }

  @override
  PenugasanStafListProvider getProviderOverride(
    covariant PenugasanStafListProvider provider,
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
  String? get name => r'penugasanStafListProvider';
}

/// See also [PenugasanStafList].
class PenugasanStafListProvider extends AutoDisposeAsyncNotifierProviderImpl<
    PenugasanStafList, List<PenugasanStafModel>> {
  /// See also [PenugasanStafList].
  PenugasanStafListProvider(
    String lembagaId,
  ) : this._internal(
          () => PenugasanStafList()..lembagaId = lembagaId,
          from: penugasanStafListProvider,
          name: r'penugasanStafListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$penugasanStafListHash,
          dependencies: PenugasanStafListFamily._dependencies,
          allTransitiveDependencies:
              PenugasanStafListFamily._allTransitiveDependencies,
          lembagaId: lembagaId,
        );

  PenugasanStafListProvider._internal(
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
  FutureOr<List<PenugasanStafModel>> runNotifierBuild(
    covariant PenugasanStafList notifier,
  ) {
    return notifier.build(
      lembagaId,
    );
  }

  @override
  Override overrideWith(PenugasanStafList Function() create) {
    return ProviderOverride(
      origin: this,
      override: PenugasanStafListProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<PenugasanStafList,
      List<PenugasanStafModel>> createElement() {
    return _PenugasanStafListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PenugasanStafListProvider && other.lembagaId == lembagaId;
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
mixin PenugasanStafListRef
    on AutoDisposeAsyncNotifierProviderRef<List<PenugasanStafModel>> {
  /// The parameter `lembagaId` of this provider.
  String get lembagaId;
}

class _PenugasanStafListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PenugasanStafList,
        List<PenugasanStafModel>> with PenugasanStafListRef {
  _PenugasanStafListProviderElement(super.provider);

  @override
  String get lembagaId => (origin as PenugasanStafListProvider).lembagaId;
}

String _$penugasanStafHash() => r'0b27df2b8d5b1456474555e804e26b1ce1fde4f0';

/// See also [PenugasanStaf].
@ProviderFor(PenugasanStaf)
final penugasanStafProvider =
    AutoDisposeNotifierProvider<PenugasanStaf, void>.internal(
  PenugasanStaf.new,
  name: r'penugasanStafProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$penugasanStafHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PenugasanStaf = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
