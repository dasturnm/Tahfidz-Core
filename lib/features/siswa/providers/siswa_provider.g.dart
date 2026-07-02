// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'siswa_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredSiswaHash() => r'd19784524ea45341598276990296eed64d892f2a';

/// See also [filteredSiswa].
@ProviderFor(filteredSiswa)
final filteredSiswaProvider = AutoDisposeProvider<List<SiswaModel>>.internal(
  filteredSiswa,
  name: r'filteredSiswaProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredSiswaHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredSiswaRef = AutoDisposeProviderRef<List<SiswaModel>>;
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
String _$siswaFilterCabangHash() => r'5269ab108005f000e4937482e11a1209b19b870e';

/// See also [SiswaFilterCabang].
@ProviderFor(SiswaFilterCabang)
final siswaFilterCabangProvider =
    AutoDisposeNotifierProvider<SiswaFilterCabang, String?>.internal(
  SiswaFilterCabang.new,
  name: r'siswaFilterCabangProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$siswaFilterCabangHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SiswaFilterCabang = AutoDisposeNotifier<String?>;
String _$siswaFilterProgramHash() =>
    r'86c6aa1ac7ba0a022a955605690b26c3f1efe73e';

/// See also [SiswaFilterProgram].
@ProviderFor(SiswaFilterProgram)
final siswaFilterProgramProvider =
    AutoDisposeNotifierProvider<SiswaFilterProgram, String?>.internal(
  SiswaFilterProgram.new,
  name: r'siswaFilterProgramProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$siswaFilterProgramHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SiswaFilterProgram = AutoDisposeNotifier<String?>;
String _$siswaFilterKurikulumHash() =>
    r'a6c4ef55cf85e85327f6500212660cc14af67f0a';

/// See also [SiswaFilterKurikulum].
@ProviderFor(SiswaFilterKurikulum)
final siswaFilterKurikulumProvider =
    AutoDisposeNotifierProvider<SiswaFilterKurikulum, String?>.internal(
  SiswaFilterKurikulum.new,
  name: r'siswaFilterKurikulumProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$siswaFilterKurikulumHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SiswaFilterKurikulum = AutoDisposeNotifier<String?>;
String _$siswaFilterLevelHash() => r'e10ac9d9d73a5126c40433ce6da556f55eda8d14';

/// See also [SiswaFilterLevel].
@ProviderFor(SiswaFilterLevel)
final siswaFilterLevelProvider =
    AutoDisposeNotifierProvider<SiswaFilterLevel, String?>.internal(
  SiswaFilterLevel.new,
  name: r'siswaFilterLevelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$siswaFilterLevelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SiswaFilterLevel = AutoDisposeNotifier<String?>;
String _$siswaListHash() => r'4833992d766f3c42176b42e02ea40599d66ebcf1';

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
