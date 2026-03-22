import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_context_provider.dart';

class AppContextHelper {

  /// 🔒 WAJIB: lembagaId
  static String getLembagaId(Ref ref) {
    final state = ref.read(appContextProvider);

    if (state.lembaga == null) {
      throw Exception('Lembaga belum dipilih / belum dibuat');
    }

    return state.lembaga!.id!;
  }

  /// 🔒 cabangId
  static String? getCabangId(Ref ref) {
    final state = ref.read(appContextProvider);
    return state.currentCabang?.id;
  }

  /// 🔒 tahun ajaran
  static String? getTahunAjaranId(Ref ref) {
    final state = ref.read(appContextProvider);
    return state.currentTahunAjaran?.id;
  }

  /// 🔒 program
  static String? getProgramId(Ref ref) {
    final state = ref.read(appContextProvider);
    return state.programId;
  }

  /// 🔒 available cabang
  static List getAvailableCabang(Ref ref) {
    final state = ref.read(appContextProvider);
    return state.availableCabang;
  }

  /// 🔒 loading
  static bool isLoading(Ref ref) {
    final state = ref.read(appContextProvider);
    return state.isLoading;
  }
}