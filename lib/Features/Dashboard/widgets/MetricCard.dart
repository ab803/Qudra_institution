  import 'package:flutter/material.dart';
  import '../../../core/styles/AppColors.dart';
  import '../../../core/styles/AppTextStyles.dart';


  class MetricCard extends StatelessWidget {
    final String title;
    final String value;
    final String statusText;
    final IconData statusIcon;
    final Color statusColor;
    final bool isWhiteCard;

    const MetricCard({
      super.key,
      required this.title,
      required this.value,
      required this.statusText,
      required this.statusIcon,
      required this.statusColor,
      required this.isWhiteCard,
    });

    @override
    Widget build(BuildContext context) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isWhiteCard ? AppColors.white : const Color(0xFFF0F1F3), // Kept the light grey for contrast
          borderRadius: BorderRadius.circular(20),
          boxShadow: isWhiteCard
              ? [
            const BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: Offset(0, 10),
            )
          ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.fieldLabel.copyWith(
                fontSize: 12,
                letterSpacing: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.largeTitle,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: AppTextStyles.fieldLabel.copyWith(
                    fontSize: 13,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }