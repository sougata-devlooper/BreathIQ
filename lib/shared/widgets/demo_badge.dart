import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class DemoBadge extends StatelessWidget {
  final String label;

  const DemoBadge({
    super.key,
    this.label = "🔶 Demo Data — Not real-time",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.butterYellow.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class FreshnessBadge extends StatelessWidget {
  final int ageMinutes;
  final VoidCallback? onRefresh;

  const FreshnessBadge({
    super.key,
    required this.ageMinutes,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final text = ageMinutes <= 1 ? "Just now" : "Updated $ageMinutes min ago";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onRefresh != null) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: onRefresh,
              child: const Icon(Icons.refresh, size: 12, color: AppColors.textSecondary),
            )
          ]
        ],
      ),
    );
  }
}
