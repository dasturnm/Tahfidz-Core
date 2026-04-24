// Lokasi: lib/features/guru_staff/widgets/all_staff_grid_view.dart

import 'package:flutter/material.dart';
import 'package:tahfidz_core/shared/models/profile_model.dart';
import '../screens/staff_detail_screen.dart';

class AllStaffGridView extends StatelessWidget {
  final List<ProfileModel> staffList;
  final Function(ProfileModel) onActionTap;

  const AllStaffGridView({
    super.key,
    required this.staffList,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 250,
      ),
      itemCount: staffList.length,
      itemBuilder: (context, index) {
        final staff = staffList[index];
        final bool isIkhwan = staff.jenisKelamin == 'L';
        final String inisial = staff.nama.isNotEmpty ? staff.nama[0].toUpperCase() : '?';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAvatar(inisial, isIkhwan),
                    _buildStatusDot(staff.isActive),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF1E293B)),
                    ),
                    Text(
                      // FIX: Jabatan sinkron dengan Profile/Penugasan
                      staff.namaJabatan ?? 'Staf',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF14B8A6), fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      staff.namaDivisi ?? '-',
                      style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _buildFooterButtons(context, staff),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(String inisial, bool isIkhwan) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isIkhwan ? const Color(0xFF0D9488).withValues(alpha: 0.1) : const Color(0xFFFB7185).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(inisial, style: TextStyle(color: isIkhwan ? const Color(0xFF0D9488) : const Color(0xFFFB7185), fontSize: 16, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildStatusDot(bool isActive) {
    return CircleAvatar(radius: 4, backgroundColor: isActive ? Colors.green : Colors.red);
  }

  Widget _buildFooterButtons(BuildContext context, ProfileModel staff) {
    return Container(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF1F5F9)))),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => onActionTap(staff),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: const Icon(Icons.more_horiz, size: 18, color: Colors.grey),
              ),
            ),
          ),
          Container(width: 1, height: 20, color: const Color(0xFFF1F5F9)),
          Expanded(
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StaffDetailScreen(staff: staff.toJson()))),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: const Text("PROFIL", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}