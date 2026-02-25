import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/staff_provider.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffListProvider);
    final today = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // HEADER: Info Tanggal Hari Ini
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Color(0xFF10B981), size: 22),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Absensi Harian Staf",
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                    Text(today,
                        style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: staffAsync.when(
              data: (listStaff) {
                if (listStaff.isEmpty) return const Center(child: Text("Tidak ada data staf"));

                return RefreshIndicator(
                  onRefresh: () => ref.refresh(staffListProvider.future),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: listStaff.length,
                    itemBuilder: (context, index) {
                      final staff = listStaff[index];
                      // Mengambil status absen hari ini dari model
                      final String? statusAbsen = staff.lastAttendance?['status'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(staff.nama,
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF10B981))),
                                  Text(staff.namaJabatan ?? 'Staf',
                                      style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            // TOMBOL AKSI: H (Hadir), I (Izin), S (Sakit), A (Alpa)
                            Row(
                              children: [
                                _buildAbsenButton(ref, staff.id!, "H", statusAbsen == "H" ? Colors.green : Colors.grey[300]!, "Hadir"),
                                const SizedBox(width: 6),
                                _buildAbsenButton(ref, staff.id!, "I", statusAbsen == "I" ? Colors.orange : Colors.grey[300]!, "Izin"),
                                const SizedBox(width: 6),
                                _buildAbsenButton(ref, staff.id!, "S", statusAbsen == "S" ? Colors.blue : Colors.grey[300]!, "Sakit"),
                                const SizedBox(width: 6),
                                _buildAbsenButton(ref, staff.id!, "A", statusAbsen == "A" ? Colors.red : Colors.grey[300]!, "Alpa"),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text("Error: $e")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsenButton(WidgetRef ref, String staffId, String status, Color color, String label) {
    bool isSelected = color != Colors.grey[300];

    return InkWell(
      onTap: () {
        ref.read(staffListProvider.notifier).submitAbsensi(
          staffId: staffId,
          status: status,
        );
      },
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          status,
          style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w900,
              fontSize: 12
          ),
        ),
      ),
    );
  }
}