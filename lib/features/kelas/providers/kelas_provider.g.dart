// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kelas_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$kelasHash() => r'840ad65eb9bed6508e02dbf8a069dba3a345c7bd';

/// See also [kelas].
@ProviderFor(kelas)
final kelasProvider = AutoDisposeProvider<List<KelasModel>>.internal(
  kelas,
  name: r'kelasProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$kelasHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef KelasRef = AutoDisposeProviderRef<List<KelasModel>>;
String _$kelasSearchHash() => r'6482ecad19a96a6b1d9a50d8d3c2c1ca00601b69';

/// See also [KelasSearch].
@ProviderFor(KelasSearch)
final kelasSearchProvider =
    AutoDisposeNotifierProvider<KelasSearch, String>.internal(
  KelasSearch.new,
  name: r'kelasSearchProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$kelasSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$KelasSearch = AutoDisposeNotifier<String>;
String _$kelasListHash() => r'1c38e94f841e88dad3bc31a09ef479fc025e5baf';

/// See also [KelasList].
@ProviderFor(KelasList)
final kelasListProvider =
    AutoDisposeAsyncNotifierProvider<KelasList, List<KelasModel>>.internal(
  KelasList.new,
  name: r'kelasListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$kelasListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$KelasList = AutoDisposeAsyncNotifier<List<KelasModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
