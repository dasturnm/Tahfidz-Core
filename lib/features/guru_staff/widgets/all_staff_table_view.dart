import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/staff_provider.dart';
// PERBAIKAN: Menyesuaikan path import ke folder screens
import '../screens/staff_form_screen.dart';
import '../screens/staff_assignment_screen.dart';
import '../screens/staff_detail_screen.dart'; // Import layar detail profil

// PERBAIKAN: Nama class disamakan dengan pemanggil di StaffHubScreen
class AllStaffTableView extends ConsumerWidget {
  // PERBAIKAN: Menambahkan parameter agar sesuai dengan panggilan di StaffHubScreen
  final List<dynamic> staffList;
  final Function(dynamic) onActionTap;

  const AllStaffTableView({
    super.key,
    required this.staffList,
    required this.onActionTap,
  });

  // --- 4. GANTI POPUP DENGAN MODAL BOTTOM SHEET (Tetap dipertahankan sebagai cadangan jika perlu) ---
  void _showActionSheet(BuildContext context, dynamic staff) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFE0F2FE), child: Icon(Icons.visibility_outlined, color: Colors.blue)),
                title: const Text("Lihat Detail", style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StaffDetailScreen(staff: staff.toJson())));
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFF0FDF4), child: Icon(Icons.edit_outlined, color: Colors.teal)),
                title: const Text("Edit Biodata", style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StaffFormScreen(staff: staff.toJson())));
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFFFF7ED), child: Icon(Icons.work_history_outlined, color: Colors.orange)),
                title: const Text("Kelola Jabatan", style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StaffAssignmentScreen(staff: staff.toJson())));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // PERBAIKAN: Menghapus watch internal karena data sudah dikirim via constructor
    if (staffList.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(staffListProvider.future),
      child: Container(
        margin: const EdgeInsets.all(16),
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 750, // Memberikan ruang napas bagi kolom-kolom
              child: Column(
                children: [
                  _buildTableHeader(),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: staffList.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.withValues(alpha: 0.05)),
                      itemBuilder: (context, index) {
                        final staff = staffList[index];
                        final bool isIkhwan = staff.jenisKelamin == 'L';
                        final String inisial = staff.nama.isNotEmpty ? staff.nama[0].toUpperCase() : '?';

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              // 1. PERSONIL (Avatar + Nama + ID)
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    _buildAvatar(inisial, isIkhwan),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(staff.nama, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF1E293B))),
                                          Text("ID: ${staff.id?.substring(0, 8).toUpperCase() ?? '-'}", style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 2. JABATAN & DIVISI (Digabung agar ringkas)
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(staff.namaJabatan ?? '-', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                    Text(staff.namaDivisi ?? 'UMUM', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF14B8A6))),
                                  ],
                                ),
                              ),
                              // 3. ROLE & CABANG
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildRoleBadge(staff.role ?? 'guru'),
                                    const SizedBox(height: 4),
                                    Text(staff.namaCabang ?? '-', style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              // 4. STATUS & AKSI
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _buildStatusBadge(staff.isActive),
                                    IconButton(
                                      icon: const Icon(Icons.more_horiz, color: Color(0xFF94A3B8), size: 20),
                                      // PERBAIKAN: Memanggil fungsi aksi dari Hub
                                      onPressed: () => onActionTap(staff),
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
      ),
    );
  }

  // --- WIDGET HELPER TABEL ---

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
      child: Row(
        children: [
          _buildHeaderCell("PERSONIL", 3),
          _buildHeaderCell("JABATAN / DIVISI", 2),
          _buildHeaderCell("ROLE / CABANG", 2),
          _buildHeaderCell("STATUS & AKSI", 2, textAlign: TextAlign.right),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, int flex, {TextAlign textAlign = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Text(label, textAlign: textAlign, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
    );
  }

  Widget _buildAvatar(String inisial, bool isIkhwan) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isIkhwan ? const Color(0xFF0D9488).withValues(alpha: 0.1) : const Color(0xFFFB7185).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(inisial, style: TextStyle(color: isIkhwan ? const Color(0xFF0D9488) : const Color(0xFFFB7185), fontSize: 14, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildRoleBadge(String role) {
    bool isGuru = role.toLowerCase() == 'guru';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isGuru ? Colors.blue.withValues(alpha: 0.1) : Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(isGuru ? "GURU" : "ADMIN", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: isGuru ? Colors.blue : Colors.purple)),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isActive ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA)),
      ),
      child: Text(isActive ? "AKTIF" : "NONAKTIF", style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: isActive ? const Color(0xFF16A34A) : Colors.red)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text("Belum ada data personil", style: TextStyle(color: Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}