import 'package:flutter/material.dart';
import 'package:tahfidz_core/core/constants/app_colors.dart';
import 'package:tahfidz_core/core/constants/app_sizes.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.r12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            // Sesuai standar Flutter 3.22+: wajib pakai alpha:
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.r12),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSizes.s16),
            child: child,
          ),
        ),
      ),
    );
  }
}