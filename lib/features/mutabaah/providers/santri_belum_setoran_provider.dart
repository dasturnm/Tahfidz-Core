import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../siswa/models/siswa_model.dart';
import '../../siswa/services/siswa_service.dart';
import 'mutabaah_provider.dart'; // TAMBAHAN: Import ini wajib agar mutabaahServiceProvider dikenali

part 'santri_belum_setoran_provider.g.dart';

@riverpod
Future<List<SiswaModel>> santriBelumSetoran(SantriBelumSetoranRef ref, String guruId) async {
  // 1. Ambil daftar seluruh siswa yang dibimbing oleh guru ini
  final semuaSiswa = await ref.read(siswaServiceProvider).fetchSiswaByGuru(ref, guruId);

  // 2. Ambil daftar ID siswa yang sudah setoran hari ini dari service
  // Pastikan nama provider ini sesuai dengan hasil generate build_runner
  final setoranHariIniIds = await ref.read(mutabaahServiceProvider).getSiswaIdsSudahSetoranHariIni(DateTime.now());

  // 3. Filter: Siswa yang belum ada di daftar setoran hari ini
  return semuaSiswa.where((siswa) => !setoranHariIniIds.contains(siswa.id)).toList();
}