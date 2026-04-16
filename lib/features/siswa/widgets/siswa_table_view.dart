// Lokasi: lib/features/siswa/widgets/siswa_table_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/siswa_provider.dart';
import '../screens/siswa_form_screen.dart'; // Dibutuhkan untuk navigasi edit

class SiswaTableView extends ConsumerStatefulWidget {
  const SiswaTableView({super.key});

  @override
  ConsumerState<SiswaTableView> createState() => _SiswaTableViewState();
}

class _SiswaTableViewState extends ConsumerState<SiswaTableView> {
  // FIX: Blok initState dihapus untuk mencegah looping state (Skipped 208 frames).
  // AsyncNotifier (siswaListProvider) sudah otomatis memanggil build() saat pertama kali di-watch.

  @override
  Widget build(BuildContext context) {
    // FIX: Menggunakan siswaListProvider (AsyncValue) untuk reaktivitas modern
    final state = ref.watch(siswaListProvider);
    final siswaList = state.value ?? [];

    if (state.isLoading && siswaList.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)));
    }

    if (siswaList.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        // MEMBUAT TABEL BISA DIGESER KE SAMPING (HORIZONTAL SCROLL)
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 650, // Ukuran lebar total tabel agar kolom punya ruang napas
            child: Column(
              children: [
                // HEADER TABEL (Sesuai Gambar 1)
                _buildTableHeader(),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),

                // ISI TABEL
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    // FIX: Menggunakan list data dari AsyncValue
                    itemCount: siswaList.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.withValues(alpha: 0.05)),
                    itemBuilder: (context, index) {
                      final siswa = siswaList[index];
                      bool isLakiLaki = siswa.jenisKelamin == 'L';
                      String inisial = siswa.namaLengkap.isNotEmpty ? siswa.namaLengkap[0].toUpperCase() : '?';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            // A. SISWA - Flex 3
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  _buildAvatar(inisial, isLakiLaki),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(siswa.namaLengkap,
                                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF1E293B)),
                                            maxLines: 1, overflow: TextOverflow.ellipsis),
                                        Text("NIS: ${siswa.nisn ?? '-'}  •  ${isLakiLaki ? 'IKHWAN' : 'AKHWAT'}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // B. KELAS / LEVEL - Flex 2
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(siswa.kelas?.name ?? 'Tanpa Kelas',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const Text("LEVEL 1 (JUZ 30)",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF14B8A6))),
                                ],
                              ),
                            ),

                            // C. PROGRESS HAFALAN - Flex 2
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('${siswa.totalJuzHafalan.toStringAsFixed(1)} ',
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                                      const Text('Juz', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                                      const Spacer(),
                                      if (siswa.lastSurah != null)
                                        Expanded(
                                          child: Text('Last: ${siswa.lastSurah}:${siswa.lastAyat}',
                                              textAlign: TextAlign.right,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 7, fontStyle: FontStyle.italic, color: Color(0xFF94A3B8))),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: (siswa.totalJuzHafalan / 30).clamp(0.0, 1.0),
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    color: const Color(0xFF0D9488),
                                    minHeight: 4,
                                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            // D. STATUS & AKSI - Flex 2
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _buildStatusBadge(siswa.status),
                                  PopupMenuButton<String>(
                                    padding: const EdgeInsets.all(0),
                                    icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8), size: 20),
                                    onSelected: (value) {
                                      if (value == 'wa') {
                                        // Logic WhatsApp
                                      } else if (value == 'edit') {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => SiswaFormScreen(existingSiswa: siswa)));
                                      } else if (value == 'detail') {
                                        // Logic Detail
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'wa',
                                        child: Row(
                                          children: [
                                            Icon(Icons.chat_bubble_outline_rounded, color: Colors.green, size: 18),
                                            SizedBox(width: 10),
                                            Text("WhatsApp", style: TextStyle(fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_outlined, color: Colors.grey, size: 18),
                                            SizedBox(width: 10),
                                            Text("Edit Data", style: TextStyle(fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'detail',
                                        child: Row(
                                          children: [
                                            Icon(Icons.info_outline_rounded, color: Color(0xFF6366F1), size: 18),
                                            SizedBox(width: 10),
                                            Text("Detail", style: TextStyle(fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HEADER TABEL ---
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
      child: Row(
        children: [
          _buildHeaderCell("SISWA", 3),
          _buildHeaderCell("KELAS / LEVEL", 2),
          _buildHeaderCell("PROGRESS HAFALAN", 2),
          _buildHeaderCell("STATUS & AKSI", 2, textAlign: TextAlign.right),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, int flex, {TextAlign textAlign = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: textAlign,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.5),
      ),
    );
  }

  // --- WIDGET KOMPONEN ---

  Widget _buildAvatar(String inisial, bool isLaki) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isLaki ? const Color(0xFF0D9488) : const Color(0xFFFB7185),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(inisial, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isAktif = status.toLowerCase() == 'aktif';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isAktif ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isAktif ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0)),
      ),
      child: Text(status.toUpperCase(),
          style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: isAktif ? const Color(0xFF16A34A) : const Color(0xFF94A3B8))),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off_rounded, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text('BELUM ADA DATA SISWA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
        ],
      ),
    );
  }
}