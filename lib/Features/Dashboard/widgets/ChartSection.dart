import 'package:flutter/material.dart';
import 'package:qudra_institution/core/styles/AppColors.dart';
import 'package:qudra_institution/core/styles/AppTextStyles.dart';
import '../../../core/Models/dashboard_stats_model.dart';
import '../../../core/responsive/responsive_helper.dart';

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
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final maxCount = data.map((e) => e.count).fold(1, (a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 28 : 22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 14,
            children: [
              const SizedBox(
                width: 230,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subscription Growth',
                      style: AppTextStyles.sectionTitle,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Monthly unique booking users',
                      style: AppTextStyles.pageDescription,
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleBtn('Monthly', _isMonthly),
                    _buildToggleBtn('Yearly', !_isMonthly),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          SizedBox(
            height: isDesktop ? 210 : 180,
            child: data.every((m) => m.count == 0)
                ? const Center(
              child: Text(
                'No bookings yet',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
                : LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth =
                (constraints.maxWidth / data.length).clamp(32.0, 72.0);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: data.map((m) {
                    final heightFactor =
                    (m.count / maxCount).clamp(0.05, 1.0);
                    final opacity = 0.15 + (heightFactor * 0.85);

                    return SizedBox(
                      width: itemWidth,
                      child: _buildBar(
                        m.month,
                        heightFactor,
                        opacity,
                        m.count,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _isMonthly = text == 'Monthly'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
            )
          ]
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

  Widget _buildBar(
      String label,
      double heightFactor,
      double opacity,
      int count,
      ) {
    return Tooltip(
      message: '$count users',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: heightFactor,
                child: Container(
                  width: 26,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(opacity),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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