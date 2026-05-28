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
        color: isWhiteCard ? AppColors.white : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: isWhiteCard
            ? const [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          )
        ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.overline.copyWith(
                    fontSize: 12,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTextStyles.largeTitle.copyWith(
                fontSize: 38,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyStrong.copyWith(
                    fontSize: 13,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}