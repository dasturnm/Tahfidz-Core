// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kalender_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calendarNotifierHash() => r'f28d5203f63c3f921d88f8749c1abf08cdb1057b';

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

abstract class _$CalendarNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<AgendaModel>> {
  late final DateTime month;

  FutureOr<List<AgendaModel>> build(
    DateTime month,
  );
}

/// See also [CalendarNotifier].
@ProviderFor(CalendarNotifier)
const calendarNotifierProvider = CalendarNotifierFamily();

/// See also [CalendarNotifier].
class CalendarNotifierFamily extends Family<AsyncValue<List<AgendaModel>>> {
  /// See also [CalendarNotifier].
  const CalendarNotifierFamily();

  /// See also [CalendarNotifier].
  CalendarNotifierProvider call(
    DateTime month,
  ) {
    return CalendarNotifierProvider(
      month,
    );
  }

  @override
  CalendarNotifierProvider getProviderOverride(
    covariant CalendarNotifierProvider provider,
  ) {
    return call(
      provider.month,
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
  String? get name => r'calendarNotifierProvider';
}

/// See also [CalendarNotifier].
class CalendarNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    CalendarNotifier, List<AgendaModel>> {
  /// See also [CalendarNotifier].
  CalendarNotifierProvider(
    DateTime month,
  ) : this._internal(
          () => CalendarNotifier()..month = month,
          from: calendarNotifierProvider,
          name: r'calendarNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$calendarNotifierHash,
          dependencies: CalendarNotifierFamily._dependencies,
          allTransitiveDependencies:
              CalendarNotifierFamily._allTransitiveDependencies,
          month: month,
        );

  CalendarNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.month,
  }) : super.internal();

  final DateTime month;

  @override
  FutureOr<List<AgendaModel>> runNotifierBuild(
    covariant CalendarNotifier notifier,
  ) {
    return notifier.build(
      month,
    );
  }

  @override
  Override overrideWith(CalendarNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: CalendarNotifierProvider._internal(
        () => create()..month = month,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<CalendarNotifier, List<AgendaModel>>
      createElement() {
    return _CalendarNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarNotifierProvider && other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CalendarNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<AgendaModel>> {
  /// The parameter `month` of this provider.
  DateTime get month;
}

class _CalendarNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<CalendarNotifier,
        List<AgendaModel>> with CalendarNotifierRef {
  _CalendarNotifierProviderElement(super.provider);

  @override
  DateTime get month => (origin as CalendarNotifierProvider).month;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
