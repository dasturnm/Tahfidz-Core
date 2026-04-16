// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keuangan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$salarySettingsHash() => r'6d58339ba79ff10e4cc26343ed81d63bbbf011f4';

/// See also [salarySettings].
@ProviderFor(salarySettings)
final salarySettingsProvider =
    AutoDisposeFutureProvider<SalarySettingsModel?>.internal(
  salarySettings,
  name: r'salarySettingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$salarySettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SalarySettingsRef = AutoDisposeFutureProviderRef<SalarySettingsModel?>;
String _$monthlyPayrollHash() => r'38fc8eccf3039680912548058fdaefc2c7e5b395';

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

/// See also [monthlyPayroll].
@ProviderFor(monthlyPayroll)
const monthlyPayrollProvider = MonthlyPayrollFamily();

/// See also [monthlyPayroll].
class MonthlyPayrollFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [monthlyPayroll].
  const MonthlyPayrollFamily();

  /// See also [monthlyPayroll].
  MonthlyPayrollProvider call({
    required String guruId,
    required DateTime month,
  }) {
    return MonthlyPayrollProvider(
      guruId: guruId,
      month: month,
    );
  }

  @override
  MonthlyPayrollProvider getProviderOverride(
    covariant MonthlyPayrollProvider provider,
  ) {
    return call(
      guruId: provider.guruId,
      month: provider.month,
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
  String? get name => r'monthlyPayrollProvider';
}

/// See also [monthlyPayroll].
class MonthlyPayrollProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [monthlyPayroll].
  MonthlyPayrollProvider({
    required String guruId,
    required DateTime month,
  }) : this._internal(
          (ref) => monthlyPayroll(
            ref as MonthlyPayrollRef,
            guruId: guruId,
            month: month,
          ),
          from: monthlyPayrollProvider,
          name: r'monthlyPayrollProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$monthlyPayrollHash,
          dependencies: MonthlyPayrollFamily._dependencies,
          allTransitiveDependencies:
              MonthlyPayrollFamily._allTransitiveDependencies,
          guruId: guruId,
          month: month,
        );

  MonthlyPayrollProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guruId,
    required this.month,
  }) : super.internal();

  final String guruId;
  final DateTime month;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(MonthlyPayrollRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlyPayrollProvider._internal(
        (ref) => create(ref as MonthlyPayrollRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        guruId: guruId,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _MonthlyPayrollProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyPayrollProvider &&
        other.guruId == guruId &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guruId.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MonthlyPayrollRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `guruId` of this provider.
  String get guruId;

  /// The parameter `month` of this provider.
  DateTime get month;
}

class _MonthlyPayrollProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with MonthlyPayrollRef {
  _MonthlyPayrollProviderElement(super.provider);

  @override
  String get guruId => (origin as MonthlyPayrollProvider).guruId;
  @override
  DateTime get month => (origin as MonthlyPayrollProvider).month;
}

String _$keuanganNotifierHash() => r'4cc4ff3e69d79e1084fd018f2d167b268981e8d4';

/// See also [KeuanganNotifier].
@ProviderFor(KeuanganNotifier)
final keuanganNotifierProvider =
    AutoDisposeNotifierProvider<KeuanganNotifier, AsyncValue<void>>.internal(
  KeuanganNotifier.new,
  name: r'keuanganNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$keuanganNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$KeuanganNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
