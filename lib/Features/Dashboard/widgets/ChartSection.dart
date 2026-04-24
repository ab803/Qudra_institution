import 'package:flutter/material.dart';
import 'package:qudra_institution/core/styles/AppColors.dart';

import '../../../core/Models/dashboard_stats_model.dart';


class ChartSection extends StatefulWidget {
  final List<MonthlyStats> monthlyData;
  const ChartSection({Key? key, required this.monthlyData}) : super(key: key);

  @override
  State<ChartSection> createState() => _ChartSectionState();
}

class _ChartSectionState extends State<ChartSection> {
  bool _isMonthly = true;

  @override
  Widget build(BuildContext context) {
    final data = widget.monthlyData;
    final maxCount = data.map((e) => e.count).fold(1, (a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subscription\nGrowth',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Monthly unique\nbooking users',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _buildToggleBtn('Monthly', _isMonthly),
                    _buildToggleBtn('Yearly', !_isMonthly),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 160,
            child: data.every((m) => m.count == 0)
                ? const Center(
              child: Text(
                'No bookings yet',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((m) {
                final heightFactor =
                (m.count / maxCount).clamp(0.05, 1.0);
                final opacity = 0.15 + (heightFactor * 0.85);
                return _buildBar(m!.month, heightFactor, opacity, m.count);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _isMonthly = text == 'Monthly'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildBar(String label, double heightFactor, double opacity, int count) {
    return Tooltip(
      message: '$count users',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 24,
            height: 130 * heightFactor,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(opacity),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}