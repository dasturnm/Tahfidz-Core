// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agenda_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$agendaNotifierHash() => r'01572e0c3d0050589f523888baf521c58c6c730c';

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

abstract class _$AgendaNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<AgendaModel>> {
  late final String? tahunAjaranId;
  late final String? programId;

  FutureOr<List<AgendaModel>> build({
    String? tahunAjaranId,
    String? programId,
  });
}

/// See also [AgendaNotifier].
@ProviderFor(AgendaNotifier)
const agendaNotifierProvider = AgendaNotifierFamily();

/// See also [AgendaNotifier].
class AgendaNotifierFamily extends Family<AsyncValue<List<AgendaModel>>> {
  /// See also [AgendaNotifier].
  const AgendaNotifierFamily();

  /// See also [AgendaNotifier].
  AgendaNotifierProvider call({
    String? tahunAjaranId,
    String? programId,
  }) {
    return AgendaNotifierProvider(
      tahunAjaranId: tahunAjaranId,
      programId: programId,
    );
  }

  @override
  AgendaNotifierProvider getProviderOverride(
    covariant AgendaNotifierProvider provider,
  ) {
    return call(
      tahunAjaranId: provider.tahunAjaranId,
      programId: provider.programId,
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
  String? get name => r'agendaNotifierProvider';
}

/// See also [AgendaNotifier].
class AgendaNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    AgendaNotifier, List<AgendaModel>> {
  /// See also [AgendaNotifier].
  AgendaNotifierProvider({
    String? tahunAjaranId,
    String? programId,
  }) : this._internal(
          () => AgendaNotifier()
            ..tahunAjaranId = tahunAjaranId
            ..programId = programId,
          from: agendaNotifierProvider,
          name: r'agendaNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$agendaNotifierHash,
          dependencies: AgendaNotifierFamily._dependencies,
          allTransitiveDependencies:
              AgendaNotifierFamily._allTransitiveDependencies,
          tahunAjaranId: tahunAjaranId,
          programId: programId,
        );

  AgendaNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tahunAjaranId,
    required this.programId,
  }) : super.internal();

  final String? tahunAjaranId;
  final String? programId;

  @override
  FutureOr<List<AgendaModel>> runNotifierBuild(
    covariant AgendaNotifier notifier,
  ) {
    return notifier.build(
      tahunAjaranId: tahunAjaranId,
      programId: programId,
    );
  }

  @override
  Override overrideWith(AgendaNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: AgendaNotifierProvider._internal(
        () => create()
          ..tahunAjaranId = tahunAjaranId
          ..programId = programId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tahunAjaranId: tahunAjaranId,
        programId: programId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<AgendaNotifier, List<AgendaModel>>
      createElement() {
    return _AgendaNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AgendaNotifierProvider &&
        other.tahunAjaranId == tahunAjaranId &&
        other.programId == programId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tahunAjaranId.hashCode);
    hash = _SystemHash.combine(hash, programId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AgendaNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<AgendaModel>> {
  /// The parameter `tahunAjaranId` of this provider.
  String? get tahunAjaranId;

  /// The parameter `programId` of this provider.
  String? get programId;
}

class _AgendaNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<AgendaNotifier,
        List<AgendaModel>> with AgendaNotifierRef {
  _AgendaNotifierProviderElement(super.provider);

  @override
  String? get tahunAjaranId => (origin as AgendaNotifierProvider).tahunAjaranId;
  @override
  String? get programId => (origin as AgendaNotifierProvider).programId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
