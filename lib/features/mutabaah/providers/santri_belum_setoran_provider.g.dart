// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'santri_belum_setoran_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$santriBelumSetoranHash() =>
    r'7419f2cdaf3e4416c1b6f427c145ccf4c9448396';

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

/// See also [santriBelumSetoran].
@ProviderFor(santriBelumSetoran)
const santriBelumSetoranProvider = SantriBelumSetoranFamily();

/// See also [santriBelumSetoran].
class SantriBelumSetoranFamily extends Family<AsyncValue<List<SiswaModel>>> {
  /// See also [santriBelumSetoran].
  const SantriBelumSetoranFamily();

  /// See also [santriBelumSetoran].
  SantriBelumSetoranProvider call(
    String guruId,
  ) {
    return SantriBelumSetoranProvider(
      guruId,
    );
  }

  @override
  SantriBelumSetoranProvider getProviderOverride(
    covariant SantriBelumSetoranProvider provider,
  ) {
    return call(
      provider.guruId,
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
  String? get name => r'santriBelumSetoranProvider';
}

/// See also [santriBelumSetoran].
class SantriBelumSetoranProvider
    extends AutoDisposeFutureProvider<List<SiswaModel>> {
  /// See also [santriBelumSetoran].
  SantriBelumSetoranProvider(
    String guruId,
  ) : this._internal(
          (ref) => santriBelumSetoran(
            ref as SantriBelumSetoranRef,
            guruId,
          ),
          from: santriBelumSetoranProvider,
          name: r'santriBelumSetoranProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$santriBelumSetoranHash,
          dependencies: SantriBelumSetoranFamily._dependencies,
          allTransitiveDependencies:
              SantriBelumSetoranFamily._allTransitiveDependencies,
          guruId: guruId,
        );

  SantriBelumSetoranProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guruId,
  }) : super.internal();

  final String guruId;

  @override
  Override overrideWith(
    FutureOr<List<SiswaModel>> Function(SantriBelumSetoranRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SantriBelumSetoranProvider._internal(
        (ref) => create(ref as SantriBelumSetoranRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        guruId: guruId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SiswaModel>> createElement() {
    return _SantriBelumSetoranProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SantriBelumSetoranProvider && other.guruId == guruId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guruId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SantriBelumSetoranRef on AutoDisposeFutureProviderRef<List<SiswaModel>> {
  /// The parameter `guruId` of this provider.
  String get guruId;
}

class _SantriBelumSetoranProviderElement
    extends AutoDisposeFutureProviderElement<List<SiswaModel>>
    with SantriBelumSetoranRef {
  _SantriBelumSetoranProviderElement(super.provider);

  @override
  String get guruId => (origin as SantriBelumSetoranProvider).guruId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
