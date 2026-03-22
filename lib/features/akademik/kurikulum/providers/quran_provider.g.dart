// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$quranSurahListHash() => r'd48cc81a2ca7ba7aca2849fa7813e877ff331cb8';

/// See also [quranSurahList].
@ProviderFor(quranSurahList)
final quranSurahListProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
  quranSurahList,
  name: r'quranSurahListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$quranSurahListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QuranSurahListRef
    = AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$getMushafBoundsHash() => r'6fc1c2113ba70ba096c61ba41088b06e08c15cdc';

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

/// See also [getMushafBounds].
@ProviderFor(getMushafBounds)
const getMushafBoundsProvider = GetMushafBoundsFamily();

/// See also [getMushafBounds].
class GetMushafBoundsFamily extends Family<AsyncValue<Map<String, String>>> {
  /// See also [getMushafBounds].
  const GetMushafBoundsFamily();

  /// See also [getMushafBounds].
  GetMushafBoundsProvider call({
    int? halaman,
    int? juz,
  }) {
    return GetMushafBoundsProvider(
      halaman: halaman,
      juz: juz,
    );
  }

  @override
  GetMushafBoundsProvider getProviderOverride(
    covariant GetMushafBoundsProvider provider,
  ) {
    return call(
      halaman: provider.halaman,
      juz: provider.juz,
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
  String? get name => r'getMushafBoundsProvider';
}

/// See also [getMushafBounds].
class GetMushafBoundsProvider
    extends AutoDisposeFutureProvider<Map<String, String>> {
  /// See also [getMushafBounds].
  GetMushafBoundsProvider({
    int? halaman,
    int? juz,
  }) : this._internal(
          (ref) => getMushafBounds(
            ref as GetMushafBoundsRef,
            halaman: halaman,
            juz: juz,
          ),
          from: getMushafBoundsProvider,
          name: r'getMushafBoundsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getMushafBoundsHash,
          dependencies: GetMushafBoundsFamily._dependencies,
          allTransitiveDependencies:
              GetMushafBoundsFamily._allTransitiveDependencies,
          halaman: halaman,
          juz: juz,
        );

  GetMushafBoundsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.halaman,
    required this.juz,
  }) : super.internal();

  final int? halaman;
  final int? juz;

  @override
  Override overrideWith(
    FutureOr<Map<String, String>> Function(GetMushafBoundsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetMushafBoundsProvider._internal(
        (ref) => create(ref as GetMushafBoundsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        halaman: halaman,
        juz: juz,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, String>> createElement() {
    return _GetMushafBoundsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetMushafBoundsProvider &&
        other.halaman == halaman &&
        other.juz == juz;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, halaman.hashCode);
    hash = _SystemHash.combine(hash, juz.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GetMushafBoundsRef on AutoDisposeFutureProviderRef<Map<String, String>> {
  /// The parameter `halaman` of this provider.
  int? get halaman;

  /// The parameter `juz` of this provider.
  int? get juz;
}

class _GetMushafBoundsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, String>>
    with GetMushafBoundsRef {
  _GetMushafBoundsProviderElement(super.provider);

  @override
  int? get halaman => (origin as GetMushafBoundsProvider).halaman;
  @override
  int? get juz => (origin as GetMushafBoundsProvider).juz;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
