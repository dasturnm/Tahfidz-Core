// Lokasi: lib/features/mutabaah/providers/delegasi_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahfidz_core/core/providers/app_context_provider.dart';
import '../models/delegasi_model.dart';
import '../services/delegasi_service.dart';

// Service Provider
final delegasiServiceProvider = Provider((ref) => DelegasiService());

// Provider untuk daftar delegasi yang saya terima (sebagai pengganti)
final incomingDelegationsProvider = FutureProvider<List<DelegasiModel>>((ref) async {
  final myId = ref.watch(appContextProvider).profile?.id;
  if (myId == null) return [];
  return ref.read(delegasiServiceProvider).fetchIncomingDelegations(ref, myId);
});

// Provider untuk daftar delegasi yang saya berikan (sebagai guru tetap)
final outgoingDelegationsProvider = FutureProvider<List<DelegasiModel>>((ref) async {
  final myId = ref.watch(appContextProvider).profile?.id;
  if (myId == null) return [];
  return ref.read(delegasiServiceProvider).fetchOutgoingDelegations(ref, myId);
});

// Notifier untuk manajemen delegasi (Create/Revoke)
final delegasiActionProvider = StateNotifierProvider<DelegasiNotifier, AsyncValue<void>>((ref) {
  return DelegasiNotifier(ref);
});

class DelegasiNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  DelegasiNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> createDelegasi(DelegasiModel delegasi) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(delegasiServiceProvider).createDelegasi(delegasi);
      _ref.invalidate(outgoingDelegationsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> revokeDelegasi(String id) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(delegasiServiceProvider).revokeDelegasi(id);
      _ref.invalidate(outgoingDelegationsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}