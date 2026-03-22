import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kurikulum_model.dart';
import 'modul_form_screen.dart';

class ModulDetailScreen extends ConsumerStatefulWidget {
  final LevelModel level;
  final ModulModel modul;

  const ModulDetailScreen({super.key, required this.level, required this.modul});

  @override
  ConsumerState<ModulDetailScreen> createState() => _ModulDetailScreenState();
}

class _ModulDetailScreenState extends ConsumerState<ModulDetailScreen> {
  final Color _emerald = const Color(0xFF10B981);
  final Color _slate = const Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Detail Modul Belajar"),
        backgroundColor: Colors.white,
        foregroundColor: _slate,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildBreadcrumbHeader(context),
          Expanded(
            child: _buildModulContent(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEdit(context),
        backgroundColor: _slate,
        icon: const Icon(Icons.edit_outlined, color: Colors.white),
        label: const Text("Edit Konfigurasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBreadcrumbHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "LEVEL ${widget.level.namaLevel.toUpperCase()}",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: _emerald,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.modul.namaModul,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _slate),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBadge(widget.modul.tipe, _emerald),
              const SizedBox(width: 8),
              _buildBadge("${widget.modul.targetPertemuan} Pertemuan", const Color(0xFF64748B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModulContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: "SILABUS & MATERI",
            icon: Icons.description_outlined,
            content: widget.modul.silabus ?? "Belum ada deskripsi silabus untuk modul ini.",
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            title: "PARAMETER PENGUKURAN (METRIK)",
            icon: Icons.straighten_rounded,
            child: Column(
              children: [
                _buildDetailRow("Jenis Metrik", widget.modul.jenisMetrik),
                _buildDetailRow("Mulai Dari", widget.modul.mulaiKoordinat ?? "-"),
                _buildDetailRow("Hingga", widget.modul.akhirKoordinat ?? "-"),
                _buildDetailRow("KKM Lulus", "${widget.modul.kkm.toInt()}%"),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (widget.modul.isSystemGenerated)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _emerald.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _emerald.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: _emerald),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Modul ini terhubung otomatis dengan Data Mushaf.",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF065F46)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, String? content, Widget? child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 16),
          if (content != null)
            Text(content, style: TextStyle(fontSize: 15, color: _slate, height: 1.5, fontWeight: FontWeight.w500)),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: _slate, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModulFormScreen(level: widget.level, modul: widget.modul),
      ),
    );
  }
}