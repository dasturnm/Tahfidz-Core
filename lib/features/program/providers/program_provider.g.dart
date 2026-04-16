// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$programHariEfektifHash() =>
    r'24a9baf1ae07d6e95d080db8b6c2f358776572ca';

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

/// --- UTILITAS ESTIMASI (Poin 3 Blueprint) ---
/// Mengambil daftar hari efektif program secara reaktif untuk kalkulasi estimasi tanggal selesai.
///
/// Copied from [programHariEfektif].
@ProviderFor(programHariEfektif)
const programHariEfektifProvider = ProgramHariEfektifFamily();

/// --- UTILITAS ESTIMASI (Poin 3 Blueprint) ---
/// Mengambil daftar hari efektif program secara reaktif untuk kalkulasi estimasi tanggal selesai.
///
/// Copied from [programHariEfektif].
class ProgramHariEfektifFamily extends Family<List<String>> {
  /// --- UTILITAS ESTIMASI (Poin 3 Blueprint) ---
  /// Mengambil daftar hari efektif program secara reaktif untuk kalkulasi estimasi tanggal selesai.
  ///
  /// Copied from [programHariEfektif].
  const ProgramHariEfektifFamily();

  /// --- UTILITAS ESTIMASI (Poin 3 Blueprint) ---
  /// Mengambil daftar hari efektif program secara reaktif untuk kalkulasi estimasi tanggal selesai.
  ///
  /// Copied from [programHariEfektif].
  ProgramHariEfektifProvider call(
    String programId,
  ) {
    return ProgramHariEfektifProvider(
      programId,
    );
  }

  @override
  ProgramHariEfektifProvider getProviderOverride(
    covariant ProgramHariEfektifProvider provider,
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
  String? get name => r'programHariEfektifProvider';
}

/// --- UTILITAS ESTIMASI (Poin 3 Blueprint) ---
/// Mengambil daftar hari efektif program secara reaktif untuk kalkulasi estimasi tanggal selesai.
///
/// Copied from [programHariEfektif].
class ProgramHariEfektifProvider extends AutoDisposeProvider<List<String>> {
  /// --- UTILITAS ESTIMASI (Poin 3 Blueprint) ---
  /// Mengambil daftar hari efektif program secara reaktif untuk kalkulasi estimasi tanggal selesai.
  ///
  /// Copied from [programHariEfektif].
  ProgramHariEfektifProvider(
    String programId,
  ) : this._internal(
          (ref) => programHariEfektif(
            ref as ProgramHariEfektifRef,
            programId,
          ),
          from: programHariEfektifProvider,
          name: r'programHariEfektifProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$programHariEfektifHash,
          dependencies: ProgramHariEfektifFamily._dependencies,
          allTransitiveDependencies:
              ProgramHariEfektifFamily._allTransitiveDependencies,
          programId: programId,
        );

  ProgramHariEfektifProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.programId,
  }) : super.internal();

  final String programId;

  @override
  Override overrideWith(
    List<String> Function(ProgramHariEfektifRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProgramHariEfektifProvider._internal(
        (ref) => create(ref as ProgramHariEfektifRef),
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
  AutoDisposeProviderElement<List<String>> createElement() {
    return _ProgramHariEfektifProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramHariEfektifProvider && other.programId == programId;
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
mixin ProgramHariEfektifRef on AutoDisposeProviderRef<List<String>> {
  /// The parameter `programId` of this provider.
  String get programId;
}

class _ProgramHariEfektifProviderElement
    extends AutoDisposeProviderElement<List<String>>
    with ProgramHariEfektifRef {
  _ProgramHariEfektifProviderElement(super.provider);

  @override
  String get programId => (origin as ProgramHariEfektifProvider).programId;
}

String _$programNotifierHash() => r'1d3373a52406875c4ab909943f1c43625e2d968d';

/// See also [ProgramNotifier].
@ProviderFor(ProgramNotifier)
final programNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ProgramNotifier, List<ProgramModel>>.internal(
  ProgramNotifier.new,
  name: r'programNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$programNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProgramNotifier = AutoDisposeAsyncNotifier<List<ProgramModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
