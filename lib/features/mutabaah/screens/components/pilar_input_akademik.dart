// Lokasi: lib/features/mutabaah/screens/components/pilar_input_akademik.dart
// ignore_for_file: invalid_use_of_protected_member
part of '../mutabaah_input_screen.dart';

extension PilarInputAkademik on _ModulInputScreenState {
  Widget _buildAkademikForm(ModulModel modul, Color color) {
    if (modul.useRatingScale) {
      return MutabaahRatingPicker(
        currentValue: int.tryParse(_nilaiControllers[modul.id!]!.text) ?? 0,
        onRatingSelected: (val) => setState(() => _nilaiControllers[modul.id!]!.text = val.toString()),
      );
    }
    return _pilarInput(label: "INPUT NILAI (0-100)", controller: _nilaiControllers[modul.id!]!, hint: "Contoh: 85");
  }
}