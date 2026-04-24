// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'siswa_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredKelasHash() => r'e2e72f6c628b0e997dc06b80bae556b4137d9156';

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

/// See also [filteredKelas].
@ProviderFor(filteredKelas)
const filteredKelasProvider = FilteredKelasFamily();

/// See also [filteredKelas].
class FilteredKelasFamily extends Family<List<KelasModel>> {
  /// See also [filteredKelas].
  const FilteredKelasFamily();

  /// See also [filteredKelas].
  FilteredKelasProvider call(
    String? programId,
  ) {
    return FilteredKelasProvider(
      programId,
    );
  }

  @override
  FilteredKelasProvider getProviderOverride(
    covariant FilteredKelasProvider provider,
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
  String? get name => r'filteredKelasProvider';
}

/// See also [filteredKelas].
class FilteredKelasProvider extends AutoDisposeProvider<List<KelasModel>> {
  /// See also [filteredKelas].
  FilteredKelasProvider(
    String? programId,
  ) : this._internal(
          (ref) => filteredKelas(
            ref as FilteredKelasRef,
            programId,
          ),
          from: filteredKelasProvider,
          name: r'filteredKelasProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredKelasHash,
          dependencies: FilteredKelasFamily._dependencies,
          allTransitiveDependencies:
              FilteredKelasFamily._allTransitiveDependencies,
          programId: programId,
        );

  FilteredKelasProvider._internal(
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
    List<KelasModel> Function(FilteredKelasRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredKelasProvider._internal(
        (ref) => create(ref as FilteredKelasRef),
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
  AutoDisposeProviderElement<List<KelasModel>> createElement() {
    return _FilteredKelasProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredKelasProvider && other.programId == programId;
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
mixin FilteredKelasRef on AutoDisposeProviderRef<List<KelasModel>> {
  /// The parameter `programId` of this provider.
  String? get programId;
}

class _FilteredKelasProviderElement
    extends AutoDisposeProviderElement<List<KelasModel>> with FilteredKelasRef {
  _FilteredKelasProviderElement(super.provider);

  @override
  String? get programId => (origin as FilteredKelasProvider).programId;
}

String _$siswaSearchHash() => r'ccfb62a75de8d4d634a880fa97f23fefe2f4fd75';

/// See also [SiswaSearch].
@ProviderFor(SiswaSearch)
final siswaSearchProvider =
    AutoDisposeNotifierProvider<SiswaSearch, String>.internal(
  SiswaSearch.new,
  name: r'siswaSearchProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$siswaSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SiswaSearch = AutoDisposeNotifier<String>;
String _$siswaListHash() => r'fba84edce0a7b27f6b215d2189e107a53b01588f';

/// See also [SiswaList].
@ProviderFor(SiswaList)
final siswaListProvider =
    AutoDisposeAsyncNotifierProvider<SiswaList, List<SiswaModel>>.internal(
  SiswaList.new,
  name: r'siswaListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$siswaListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SiswaList = AutoDisposeAsyncNotifier<List<SiswaModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
