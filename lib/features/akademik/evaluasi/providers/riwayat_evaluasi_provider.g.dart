// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'riwayat_evaluasi_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$riwayatEvaluasiHash() => r'8e02028554fcd5c5a152fc4e01448b6bb63de1f8';

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

/// Provider ini bertugas mengambil daftar riwayat evaluasi/ujian berdasarkan ID Siswa.
/// Karena menggunakan @riverpod, data akan di-cache dan otomatis diperbarui jika ada perubahan.
///
/// Copied from [riwayatEvaluasi].
@ProviderFor(riwayatEvaluasi)
const riwayatEvaluasiProvider = RiwayatEvaluasiFamily();

/// Provider ini bertugas mengambil daftar riwayat evaluasi/ujian berdasarkan ID Siswa.
/// Karena menggunakan @riverpod, data akan di-cache dan otomatis diperbarui jika ada perubahan.
///
/// Copied from [riwayatEvaluasi].
class RiwayatEvaluasiFamily
    extends Family<AsyncValue<List<EvaluasiRecordModel>>> {
  /// Provider ini bertugas mengambil daftar riwayat evaluasi/ujian berdasarkan ID Siswa.
  /// Karena menggunakan @riverpod, data akan di-cache dan otomatis diperbarui jika ada perubahan.
  ///
  /// Copied from [riwayatEvaluasi].
  const RiwayatEvaluasiFamily();

  /// Provider ini bertugas mengambil daftar riwayat evaluasi/ujian berdasarkan ID Siswa.
  /// Karena menggunakan @riverpod, data akan di-cache dan otomatis diperbarui jika ada perubahan.
  ///
  /// Copied from [riwayatEvaluasi].
  RiwayatEvaluasiProvider call(
    String siswaId,
  ) {
    return RiwayatEvaluasiProvider(
      siswaId,
    );
  }

  @override
  RiwayatEvaluasiProvider getProviderOverride(
    covariant RiwayatEvaluasiProvider provider,
  ) {
    return call(
      provider.siswaId,
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
  String? get name => r'riwayatEvaluasiProvider';
}

/// Provider ini bertugas mengambil daftar riwayat evaluasi/ujian berdasarkan ID Siswa.
/// Karena menggunakan @riverpod, data akan di-cache dan otomatis diperbarui jika ada perubahan.
///
/// Copied from [riwayatEvaluasi].
class RiwayatEvaluasiProvider
    extends AutoDisposeFutureProvider<List<EvaluasiRecordModel>> {
  /// Provider ini bertugas mengambil daftar riwayat evaluasi/ujian berdasarkan ID Siswa.
  /// Karena menggunakan @riverpod, data akan di-cache dan otomatis diperbarui jika ada perubahan.
  ///
  /// Copied from [riwayatEvaluasi].
  RiwayatEvaluasiProvider(
    String siswaId,
  ) : this._internal(
          (ref) => riwayatEvaluasi(
            ref as RiwayatEvaluasiRef,
            siswaId,
          ),
          from: riwayatEvaluasiProvider,
          name: r'riwayatEvaluasiProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$riwayatEvaluasiHash,
          dependencies: RiwayatEvaluasiFamily._dependencies,
          allTransitiveDependencies:
              RiwayatEvaluasiFamily._allTransitiveDependencies,
          siswaId: siswaId,
        );

  RiwayatEvaluasiProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.siswaId,
  }) : super.internal();

  final String siswaId;

  @override
  Override overrideWith(
    FutureOr<List<EvaluasiRecordModel>> Function(RiwayatEvaluasiRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RiwayatEvaluasiProvider._internal(
        (ref) => create(ref as RiwayatEvaluasiRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        siswaId: siswaId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<EvaluasiRecordModel>> createElement() {
    return _RiwayatEvaluasiProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RiwayatEvaluasiProvider && other.siswaId == siswaId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, siswaId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RiwayatEvaluasiRef
    on AutoDisposeFutureProviderRef<List<EvaluasiRecordModel>> {
  /// The parameter `siswaId` of this provider.
  String get siswaId;
}

class _RiwayatEvaluasiProviderElement
    extends AutoDisposeFutureProviderElement<List<EvaluasiRecordModel>>
    with RiwayatEvaluasiRef {
  _RiwayatEvaluasiProviderElement(super.provider);

  @override
  String get siswaId => (origin as RiwayatEvaluasiProvider).siswaId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
