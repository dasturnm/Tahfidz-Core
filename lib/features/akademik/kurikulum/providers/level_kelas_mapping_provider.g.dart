// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_kelas_mapping_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$levelKelasMappingHash() => r'eb54a941680a95e9b5a066f68100003d7a45687e';

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
