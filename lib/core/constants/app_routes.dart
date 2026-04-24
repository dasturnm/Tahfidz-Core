// Lokasi: lib/core/constants/app_routes.dart

class AppRouteNames {
  // Auth
  static const String login = '/login';

  // Dashboard
  static const String dashboard = '/';

  // Manajemen Lembaga
  static const String profilLembaga = '/profil-lembaga';
  static const String cabang = '/cabang';
  static const String tahunAjaran = '/tahun-ajaran';
  static const String divisi = '/divisi';
  static const String jabatan = '/jabatan';
  static const String setupLembaga = '/setup-lembaga'; // FIX: Ditambahkan

  // Program
  static const String program = '/akademik/program'; // FIX: Ditambahkan
  static const String programList = '/program/list';
  static const String programKalender = '/program/kalender';

  // Akademik
  static const String kurikulum = '/akademik/kurikulum';
  static const String akademikLevel = '/akademik/level';
  static const String kelas = '/akademik/kelas';
  static const String akademikAgenda = '/akademik/agenda';
  static const String akademikKalender = '/akademik/kalender';
  static const String tasmi = '/akademik/tasmi'; // FIX: Ditambahkan
  static const String katalogSilabus = '/akademik/katalog-silabus'; // TAMBAHAN: Blueprint Akademik
  static const String eRapor = '/akademik/e-rapor'; // TAMBAHAN: Output Akademik
  static const String eSertifikat = '/akademik/e-sertifikat'; // TAMBAHAN: Output Akademik

  // Mutabaah
  static const String mutabaahHub = '/mutabaah';
  static const String mutabaahInput = '/mutabaah/input';
  static const String mutabaahMonitoring = '/mutabaah/monitoring';
  static const String mutabaahRanking = '/mutabaah/ranking';

  // Siswa
  static const String siswa = '/siswa';
  static const String presensiSiswa = '/presensi/siswa'; // TAMBAHAN: Operasional Harian

  // Guru & Staff
  static const String staf = '/staf'; // FIX: Ditambahkan
  static const String guru = '/guru';
  static const String absensi = '/guru/absensi';

  // Keuangan
  static const String keuanganHub = '/keuangan';
  static const String salarySettings = '/keuangan/settings';
  static const String teacherPayroll = '/keuangan/payroll';
  static const String keuanganSpp = '/keuangan/spp';
  static const String keuanganHonor = '/keuangan/honor';

  // Mushaf
  static const String mushaf = '/mushaf'; // FIX: Ditambahkan
  static const String mushafIndex = '/mushaf-index'; // FIX: Ditambahkan
}