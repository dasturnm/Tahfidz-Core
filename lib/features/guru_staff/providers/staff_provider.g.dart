// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$staffSearchHash() => r'e93a7d5305fbe4e921535d71501c456d3368c2a5';

/// See also [StaffSearch].
@ProviderFor(StaffSearch)
final staffSearchProvider =
    AutoDisposeNotifierProvider<StaffSearch, String>.internal(
  StaffSearch.new,
  name: r'staffSearchProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$staffSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StaffSearch = AutoDisposeNotifier<String>;
String _$staffListHash() => r'50e2a3628a70ee19584eb30212d42652953e6a86';

/// See also [StaffList].
@ProviderFor(StaffList)
final staffListProvider =
    AutoDisposeAsyncNotifierProvider<StaffList, List<ProfileModel>>.internal(
  StaffList.new,
  name: r'staffListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$staffListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StaffList = AutoDisposeAsyncNotifier<List<ProfileModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
