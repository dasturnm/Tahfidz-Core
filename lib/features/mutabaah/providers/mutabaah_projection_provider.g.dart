// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mutabaah_projection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mutabaahProjectionHash() =>
    r'2783f6c0d3c7f58c2e4ab3801f1f097d6ee41501';

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

/// Provider untuk mengambil proyeksi akademik (Sisa pertemuan & estimasi kelulusan)
/// Menggunakan parameter [siswaId] dan [modul]
///
/// Copied from [mutabaahProjection].
@ProviderFor(mutabaahProjection)
const mutabaahProjectionProvider = MutabaahProjectionFamily();

/// Provider untuk mengambil proyeksi akademik (Sisa pertemuan & estimasi kelulusan)
/// Menggunakan parameter [siswaId] dan [modul]
///
/// Copied from [mutabaahProjection].
class MutabaahProjectionFamily
    extends Family<AsyncValue<MutabaahProjectionModel>> {
  /// Provider untuk mengambil proyeksi akademik (Sisa pertemuan & estimasi kelulusan)
  /// Menggunakan parameter [siswaId] dan [modul]
  ///
  /// Copied from [mutabaahProjection].
  const MutabaahProjectionFamily();

  /// Provider untuk mengambil proyeksi akademik (Sisa pertemuan & estimasi kelulusan)
  /// Menggunakan parameter [siswaId] dan [modul]
  ///
  /// Copied from [mutabaahProjection].
  MutabaahProjectionProvider call(
    String siswaId,
    ModulModel modul,
  ) {
    return MutabaahProjectionProvider(
      siswaId,
      modul,
    );
  }

  @override
  MutabaahProjectionProvider getProviderOverride(
    covariant MutabaahProjectionProvider provider,
  ) {
    return call(
      provider.siswaId,
      provider.modul,
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
  String? get name => r'mutabaahProjectionProvider';
}

/// Provider untuk mengambil proyeksi akademik (Sisa pertemuan & estimasi kelulusan)
/// Menggunakan parameter [siswaId] dan [modul]
///
/// Copied from [mutabaahProjection].
class MutabaahProjectionProvider
    extends AutoDisposeFutureProvider<MutabaahProjectionModel> {
  /// Provider untuk mengambil proyeksi akademik (Sisa pertemuan & estimasi kelulusan)
  /// Menggunakan parameter [siswaId] dan [modul]
  ///
  /// Copied from [mutabaahProjection].
  MutabaahProjectionProvider(
    String siswaId,
    ModulModel modul,
  ) : this._internal(
          (ref) => mutabaahProjection(
            ref as MutabaahProjectionRef,
            siswaId,
            modul,
          ),
          from: mutabaahProjectionProvider,
          name: r'mutabaahProjectionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mutabaahProjectionHash,
          dependencies: MutabaahProjectionFamily._dependencies,
          allTransitiveDependencies:
              MutabaahProjectionFamily._allTransitiveDependencies,
          siswaId: siswaId,
          modul: modul,
        );

  MutabaahProjectionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.siswaId,
    required this.modul,
  }) : super.internal();

  final String siswaId;
  final ModulModel modul;

  @override
  Override overrideWith(
    FutureOr<MutabaahProjectionModel> Function(MutabaahProjectionRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MutabaahProjectionProvider._internal(
        (ref) => create(ref as MutabaahProjectionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        siswaId: siswaId,
        modul: modul,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MutabaahProjectionModel> createElement() {
    return _MutabaahProjectionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MutabaahProjectionProvider &&
        other.siswaId == siswaId &&
        other.modul == modul;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, siswaId.hashCode);
    hash = _SystemHash.combine(hash, modul.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MutabaahProjectionRef
    on AutoDisposeFutureProviderRef<MutabaahProjectionModel> {
  /// The parameter `siswaId` of this provider.
  String get siswaId;

  /// The parameter `modul` of this provider.
  ModulModel get modul;
}

class _MutabaahProjectionProviderElement
    extends AutoDisposeFutureProviderElement<MutabaahProjectionModel>
    with MutabaahProjectionRef {
  _MutabaahProjectionProviderElement(super.provider);

  @override
  String get siswaId => (origin as MutabaahProjectionProvider).siswaId;
  @override
  ModulModel get modul => (origin as MutabaahProjectionProvider).modul;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
