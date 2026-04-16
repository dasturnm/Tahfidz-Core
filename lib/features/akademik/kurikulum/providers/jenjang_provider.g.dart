// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jenjang_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$jenjangListHash() => r'af11627759602ac7632b4cfccec7fe47ce5286d2';

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

abstract class _$JenjangList
    extends BuildlessAutoDisposeAsyncNotifier<List<JenjangModel>> {
  late final String kurikulumId;

  FutureOr<List<JenjangModel>> build(
    String kurikulumId,
  );
}

/// See also [JenjangList].
@ProviderFor(JenjangList)
const jenjangListProvider = JenjangListFamily();

/// See also [JenjangList].
class JenjangListFamily extends Family<AsyncValue<List<JenjangModel>>> {
  /// See also [JenjangList].
  const JenjangListFamily();

  /// See also [JenjangList].
  JenjangListProvider call(
    String kurikulumId,
  ) {
    return JenjangListProvider(
      kurikulumId,
    );
  }

  @override
  JenjangListProvider getProviderOverride(
    covariant JenjangListProvider provider,
  ) {
    return call(
      provider.kurikulumId,
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
  String? get name => r'jenjangListProvider';
}

/// See also [JenjangList].
class JenjangListProvider extends AutoDisposeAsyncNotifierProviderImpl<
    JenjangList, List<JenjangModel>> {
  /// See also [JenjangList].
  JenjangListProvider(
    String kurikulumId,
  ) : this._internal(
          () => JenjangList()..kurikulumId = kurikulumId,
          from: jenjangListProvider,
          name: r'jenjangListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$jenjangListHash,
          dependencies: JenjangListFamily._dependencies,
          allTransitiveDependencies:
              JenjangListFamily._allTransitiveDependencies,
          kurikulumId: kurikulumId,
        );

  JenjangListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.kurikulumId,
  }) : super.internal();

  final String kurikulumId;

  @override
  FutureOr<List<JenjangModel>> runNotifierBuild(
    covariant JenjangList notifier,
  ) {
    return notifier.build(
      kurikulumId,
    );
  }

  @override
  Override overrideWith(JenjangList Function() create) {
    return ProviderOverride(
      origin: this,
      override: JenjangListProvider._internal(
        () => create()..kurikulumId = kurikulumId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        kurikulumId: kurikulumId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<JenjangList, List<JenjangModel>>
      createElement() {
    return _JenjangListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is JenjangListProvider && other.kurikulumId == kurikulumId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, kurikulumId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin JenjangListRef
    on AutoDisposeAsyncNotifierProviderRef<List<JenjangModel>> {
  /// The parameter `kurikulumId` of this provider.
  String get kurikulumId;
}

class _JenjangListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<JenjangList,
        List<JenjangModel>> with JenjangListRef {
  _JenjangListProviderElement(super.provider);

  @override
  String get kurikulumId => (origin as JenjangListProvider).kurikulumId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
