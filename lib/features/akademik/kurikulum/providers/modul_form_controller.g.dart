// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modul_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$modulFormControllerHash() =>
    r'e45098221dd49c97c23f50ccabf6c9f2f8253eee';

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

abstract class _$ModulFormController
    extends BuildlessAutoDisposeNotifier<ModulFormState> {
  late final LevelModel level;
  late final ModulModel? initialModul;

  ModulFormState build(
    LevelModel level,
    ModulModel? initialModul,
  );
}

/// See also [ModulFormController].
@ProviderFor(ModulFormController)
const modulFormControllerProvider = ModulFormControllerFamily();

/// See also [ModulFormController].
class ModulFormControllerFamily extends Family<ModulFormState> {
  /// See also [ModulFormController].
  const ModulFormControllerFamily();

  /// See also [ModulFormController].
  ModulFormControllerProvider call(
    LevelModel level,
    ModulModel? initialModul,
  ) {
    return ModulFormControllerProvider(
      level,
      initialModul,
    );
  }

  @override
  ModulFormControllerProvider getProviderOverride(
    covariant ModulFormControllerProvider provider,
  ) {
    return call(
      provider.level,
      provider.initialModul,
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
  String? get name => r'modulFormControllerProvider';
}

/// See also [ModulFormController].
class ModulFormControllerProvider extends AutoDisposeNotifierProviderImpl<
    ModulFormController, ModulFormState> {
  /// See also [ModulFormController].
  ModulFormControllerProvider(
    LevelModel level,
    ModulModel? initialModul,
  ) : this._internal(
          () => ModulFormController()
            ..level = level
            ..initialModul = initialModul,
          from: modulFormControllerProvider,
          name: r'modulFormControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$modulFormControllerHash,
          dependencies: ModulFormControllerFamily._dependencies,
          allTransitiveDependencies:
              ModulFormControllerFamily._allTransitiveDependencies,
          level: level,
          initialModul: initialModul,
        );

  ModulFormControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.level,
    required this.initialModul,
  }) : super.internal();

  final LevelModel level;
  final ModulModel? initialModul;

  @override
  ModulFormState runNotifierBuild(
    covariant ModulFormController notifier,
  ) {
    return notifier.build(
      level,
      initialModul,
    );
  }

  @override
  Override overrideWith(ModulFormController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ModulFormControllerProvider._internal(
        () => create()
          ..level = level
          ..initialModul = initialModul,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        level: level,
        initialModul: initialModul,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ModulFormController, ModulFormState>
      createElement() {
    return _ModulFormControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ModulFormControllerProvider &&
        other.level == level &&
        other.initialModul == initialModul;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, level.hashCode);
    hash = _SystemHash.combine(hash, initialModul.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ModulFormControllerRef on AutoDisposeNotifierProviderRef<ModulFormState> {
  /// The parameter `level` of this provider.
  LevelModel get level;

  /// The parameter `initialModul` of this provider.
  ModulModel? get initialModul;
}

class _ModulFormControllerProviderElement
    extends AutoDisposeNotifierProviderElement<ModulFormController,
        ModulFormState> with ModulFormControllerRef {
  _ModulFormControllerProviderElement(super.provider);

  @override
  LevelModel get level => (origin as ModulFormControllerProvider).level;
  @override
  ModulModel? get initialModul =>
      (origin as ModulFormControllerProvider).initialModul;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
