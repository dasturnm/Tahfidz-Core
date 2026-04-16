// Lokasi: lib/features/keuangan/screens/salary_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_context_provider.dart';
import '../models/salary_settings_model.dart';
import '../providers/keuangan_provider.dart';

class SalarySettingsScreen extends ConsumerStatefulWidget {
  const SalarySettingsScreen({super.key});

  @override
  ConsumerState<SalarySettingsScreen> createState() => _SalarySettingsScreenState();
}

class _SalarySettingsScreenState extends ConsumerState<SalarySettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _baseSalaryController = TextEditingController();
  final _perStudentController = TextEditingController();
  final _subAmountController = TextEditingController();
  final _deductionController = TextEditingController();

  String _subMode = 'per_student';
  bool _isDeducted = false;

  @override
  void initState() {
    super.initState();
    // Memasukkan data awal setelah frame pertama dirender
    Future.microtask(() => _loadCurrentSettings());
  }

  void _loadCurrentSettings() async {
    final settings = await ref.read(salarySettingsProvider.future);
    if (settings != null) {
      setState(() {
        _baseSalaryController.text = settings.baseSalary.toString();
        _perStudentController.text = settings.perStudentBonus.toString();
        _subAmountController.text = settings.substituteBonusAmount.toString();
        _deductionController.text = settings.deductionAmount.toString();
        _subMode = settings.substituteBonusMode;
        _isDeducted = settings.isOriginalTeacherDeducted;
      });
    }
  }

  @override
  void dispose() {
    _baseSalaryController.dispose();
    _perStudentController.dispose();
    _subAmountController.dispose();
    _deductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(keuanganNotifierProvider);
    const Color emerald = Color(0xFF10B981);
    const Color slate = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Pengaturan Gaji", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: slate,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("GAJI POKOK & BONUS REGULER"),
              _buildCard([
                _buildTextField(
                  controller: _baseSalaryController,
                  label: "Gaji Pokok Bulanan",
                  icon: Icons.account_balance_wallet_outlined,
                  prefix: "Rp ",
                ),
                const Divider(height: 32),
                _buildTextField(
                  controller: _perStudentController,
                  label: "Bonus per Kepala Siswa (Reguler)",
                  helper: "Dihitung unik per hari per siswa",
                  icon: Icons.person_add_alt_1_outlined,
                  prefix: "Rp ",
                ),
              ]),

              const SizedBox(height: 32),
              _buildSectionTitle("KEBIJAKAN GURU PENGGANTI (DELEGASI)"),
              _buildCard([
                const Text("Mode Bonus Pengganti", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                DropdownButton<String>(
                  value: _subMode,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'per_student', child: Text("Dihitung per Siswa")),
                    DropdownMenuItem(value: 'fixed', child: Text("Tetap (Per Hari)")),
                  ],
                  onChanged: (val) => setState(() => _subMode = val!),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _subAmountController,
                  label: "Nominal Bonus Pengganti",
                  icon: Icons.payments_outlined, // FIX: Mengganti icon yang tidak valid
                  prefix: "Rp ",
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Potong Gaji Guru Tetap?", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Jika kelas didelegasikan ke orang lain", style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isDeducted,
                      onChanged: (val) => setState(() => _isDeducted = val),
                      activeThumbColor: emerald,
                    ),
                  ],
                ),
                if (_isDeducted) ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _deductionController,
                    label: "Nominal Potongan per Siswa",
                    icon: Icons.money_off_csred_outlined,
                    prefix: "Rp ",
                  ),
                ],
              ]),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: actionState.isLoading ? null : _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: slate,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: actionState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SIMPAN PERUBAHAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey, letterSpacing: 1.1)),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? prefix,
    String? helper,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569))),
        if (helper != null) Text(helper, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: prefix,
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
        ),
      ],
    );
  }

  void _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final lembagaId = ref.read(appContextProvider).lembaga?.id ?? '';
    final settings = SalarySettingsModel(
      lembagaId: lembagaId,
      baseSalary: double.parse(_baseSalaryController.text),
      perStudentBonus: double.parse(_perStudentController.text),
      substituteBonusMode: _subMode,
      substituteBonusAmount: double.parse(_subAmountController.text),
      isOriginalTeacherDeducted: _isDeducted,
      deductionAmount: double.parse(_deductionController.text),
      updatedAt: DateTime.now(),
    );

    await ref.read(keuanganNotifierProvider.notifier).updateSettings(settings);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pengaturan berhasil disimpan!"), backgroundColor: Colors.green),
      );
    }
  }
}