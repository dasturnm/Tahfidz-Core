// Lokasi: lib/features/siswa/widgets/attendance_print_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../kelas/providers/class_provider.dart';
import '../providers/student_provider.dart';

class AttendancePrintDialog extends ConsumerStatefulWidget {
  const AttendancePrintDialog({super.key});

  @override
  ConsumerState<AttendancePrintDialog> createState() => _AttendancePrintDialogState();
}

class _AttendancePrintDialogState extends ConsumerState<AttendancePrintDialog> {
  String? _selectedClassId;
  // Menjadikan final karena tidak ada fungsi pengubah bulan di UI saat ini
  final DateTime _selectedMonth = DateTime.now();

  Future<void> _generatePdf() async {
    if (_selectedClassId == null) return;

    final pdf = pw.Document();
    final className = ref.read(classProvider).classes.firstWhere((c) => c.id == _selectedClassId).name;
    final students = ref.read(studentProvider).getStudentsInClass(_selectedClassId!);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("ABSENSI KELAS: $className", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text("Periode: ${_selectedMonth.month}/${_selectedMonth.year}"),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['No', 'Nama Santri', ...List.generate(31, (index) => (index + 1).toString())],
                data: List.generate(students.length, (index) {
                  return [
                    (index + 1).toString(),
                    students[index].namaLengkap,
                    ...List.generate(31, (index) => "")
                  ];
                }),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
                cellStyle: const pw.TextStyle(fontSize: 7),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final classes = ref.watch(classProvider).classes;

    return AlertDialog(
      title: const Text("Cetak Absensi", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: "Pilih Kelas"),
            items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
            onChanged: (val) => setState(() => _selectedClassId = val),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: _selectedClassId == null ? null : _generatePdf,
          child: const Text("CETAK PDF"),
        ),
      ],
    );
  }
}