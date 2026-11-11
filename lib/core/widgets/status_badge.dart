import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_text_styles.dart';

/// Status badge widget that shows colored pill for CV statuses
class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.statusBackgroundColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        CvStatus.displayName(status),
        style: (fontSize != null
                ? AppTextStyles.labelSmall.copyWith(fontSize: fontSize)
                : AppTextStyles.labelSmall)
            .copyWith(
          color: AppColors.statusColor(status),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

