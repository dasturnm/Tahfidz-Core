import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/staff_provider.dart';
import 'staff_form_screen.dart';
import 'staff_assignment_screen.dart';
import '../widgets/assignment_timeline.dart';

class StaffDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> staff;
  const StaffDetailScreen({super.key, required this.staff});

  @override
  ConsumerState<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends ConsumerState<StaffDetailScreen> {
  List<Map<String, dynamic>>? _history;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await ref.read(staffListProvider.notifier).fetchHistory(widget.staff['id']);
      if (mounted) setState(() { _history = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Profil Lengkap", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => StaffFormScreen(staff: widget.staff),
            )),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildSectionTitle("RIWAYAT PENUGASAN"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AssignmentTimeline(history: _history ?? []),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildHeader() {
    // Sinkronisasi Nama
    final String displayName = widget.staff['nama'] ?? widget.staff['nama_lengkap'] ?? 'Tanpa Nama';
    final bool isIkhwan = widget.staff['jenis_kelamin'] == 'L';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 2. AVATAR DINAMIS (Poin 2 & 3 Modern Desain)
          CircleAvatar(
            radius: 40,
            backgroundColor: isIkhwan ? const Color(0xFF0D9488).withValues(alpha: 0.1) : const Color(0xFFFB7185).withValues(alpha: 0.1),
            child: Text(
                (() {
                  final names = displayName.trim().split(' ').where((n) => n.isNotEmpty).toList();
                  if (names.isEmpty) return '?';
                  return names.length >= 2 ? (names[0][0] + names[1][0]).toUpperCase() : names[0][0].toUpperCase();
                })(),
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: isIkhwan ? const Color(0xFF0D9488) : const Color(0xFFFB7185)
                )
            ),
          ),
          const SizedBox(height: 16),
          Text(displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          // 1. HIERARKI TEKS NIP
          Text(
              "NIP: ${widget.staff['nip'] ?? (widget.staff['id']?.toString().length ?? 0) >= 8 ? widget.staff['id']?.toString().substring(0,8).toUpperCase() : widget.staff['id'] ?? '-'}",
              style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // FIX: Menggunakan key 'kontak' sesuai model terbaru
              _buildInfoItem(Icons.phone_android_rounded, "Kontak", widget.staff['kontak'] ?? '-'),
              _buildInfoItem(Icons.email_outlined, "Email", widget.staff['email'] ?? '-'),
              _buildInfoItem(Icons.calendar_today_rounded, "Masuk", widget.staff['tanggal_bergabung'] ?? '-'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF334155))),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (context) => StaffAssignmentScreen(staff: widget.staff),
        )),
        icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
        label: const Text("KELOLA JABATAN (MUTASI/RANGKAP)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F172A),
          minimumSize: const Size(double.infinity, 54),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}