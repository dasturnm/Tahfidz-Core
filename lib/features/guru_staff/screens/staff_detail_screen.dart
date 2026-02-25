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
    // Sinkronisasi Nama: Mencoba key 'nama' (dari provider) atau 'nama_lengkap' (raw)
    final String displayName = widget.staff['nama'] ?? widget.staff['nama_lengkap'] ?? 'Tanpa Nama';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
            child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF10B981))
            ),
          ),
          const SizedBox(height: 16),
          Text(displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          Text(
              "NIP: ${widget.staff['id']?.toString().substring(0,8).toUpperCase() ?? '-'}",
              style: const TextStyle(color: Colors.grey, fontSize: 12)
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(Icons.phone, "Kontak", widget.staff['no_hp'] ?? '-'),
              _buildInfoItem(Icons.email, "Email", widget.staff['email'] ?? '-'),
              _buildInfoItem(Icons.calendar_month, "Masuk", widget.staff['tanggal_bergabung'] ?? '-'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
            child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (context) => StaffAssignmentScreen(staff: widget.staff),
        )),
        icon: const Icon(Icons.swap_horiz, color: Colors.white),
        label: const Text("KELOLA JABATAN (MUTASI/RANGKAP)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F172A),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}