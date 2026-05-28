import 'package:flutter/material.dart';
import '../../../core/responsive/responsive_helper.dart';
import '../../../core/styles/AppColors.dart';
import '../../../core/styles/AppTextStyles.dart';
import '../services/Models/service_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  // This helper formats the service price label.
  String _formatPrice() {
    if (service.isFree) return 'Free';
    return 'EGP ${service.price.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isVeryNarrow = constraints.maxWidth < 340;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [
              BoxShadow(
                color: AppColors.softShadow,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                isMobile: isMobile,
                isVeryNarrow: isVeryNarrow,
              ),
              if (service.description != null &&
                  service.description!.trim().isNotEmpty) ...[
                SizedBox(height: isMobile ? 10 : 12),
                Text(
                  service.description!.trim(),
                  maxLines: isMobile ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSoft,
                    height: 1.35,
                    fontSize: isMobile ? 13.5 : 14,
                  ),
                ),
              ],
              SizedBox(height: isMobile ? 14 : 16),
              _buildTags(isMobile: isMobile),
              SizedBox(height: isMobile ? 14 : 16),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.black.withOpacity(0.05),
              ),
              SizedBox(height: isMobile ? 12 : 14),
              _buildActions(
                isMobile: isMobile,
                isVeryNarrow: isVeryNarrow,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader({
    required bool isMobile,
    required bool isVeryNarrow,
  }) {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          service.name,
          maxLines: isMobile ? 2 : 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.cardTitle.copyWith(
            fontSize: isMobile ? 16 : 17,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          service.category,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption.copyWith(
            fontSize: isMobile ? 12.5 : 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    final statusBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _StatusBadge(isActive: service.isActive),
        const SizedBox(height: 4),
        Transform.scale(
          scale: isMobile ? 0.70 : 0.82,
          child: Switch(
            value: service.isActive,
            onChanged: (_) => onToggleStatus(),
            activeColor: Colors.white,
            activeTrackColor: Colors.black,
            inactiveThumbColor: Colors.black,
            inactiveTrackColor: Colors.grey.shade300,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );

    if (isVeryNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: statusBlock,
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: titleBlock),
        const SizedBox(width: 10),
        statusBlock,
      ],
    );
  }

  Widget _buildTags({required bool isMobile}) {
    return Wrap(
      spacing: isMobile ? 7 : 8,
      runSpacing: isMobile ? 7 : 8,
      children: [
        _TagChip(text: _formatPrice(), dark: true, compact: isMobile),
        _TagChip(text: '${service.durationMinutes} min', compact: isMobile),
        _TagChip(
          text: service.locationMode.replaceAll('_', ' '),
          compact: isMobile,
        ),
        _TagChip(
          text: service.bookingType.replaceAll('_', ' '),
          compact: isMobile,
        ),
        ...service.supportedDisabilities.map(
              (item) => _TagChip(text: item, light: true, compact: isMobile),
        ),
      ],
    );
  }

  Widget _buildActions({
    required bool isMobile,
    required bool isVeryNarrow,
  }) {
    if (isVeryNarrow) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: onEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.edit_outlined, size: 17),
              label: const Text(
                'Edit',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: onDelete,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD32F2F),
                side: const BorderSide(color: Color(0xFFFFCDD2)),
                backgroundColor: const Color(0xFFFFF5F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: isMobile ? 42 : 44,
            child: ElevatedButton.icon(
              onPressed: onEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(Icons.edit_outlined, size: isMobile ? 17 : 18),
              label: const Text(
                'Edit',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: isMobile ? 48 : 52,
          height: isMobile ? 42 : 44,
          child: OutlinedButton(
            onPressed: onDelete,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD32F2F),
              side: const BorderSide(color: Color(0xFFFFCDD2)),
              backgroundColor: const Color(0xFFFFF5F5),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              size: isMobile ? 19 : 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.success : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
          height: 1,
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String text;
  final bool light;
  final bool dark;
  final bool compact;

  const _TagChip({
    required this.text,
    this.light = false,
    this.dark = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Border? border;

    if (dark) {
      bgColor = Colors.black;
      textColor = Colors.white;
      border = null;
    } else if (light) {
      bgColor = Colors.grey.shade100;
      textColor = Colors.grey.shade800;
      border = Border.all(color: Colors.grey.shade300);
    } else {
      bgColor = const Color(0xFFF5F5F5);
      textColor = Colors.black87;
      border = Border.all(color: Colors.black.withOpacity(0.05));
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 135 : 180),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 9 : 10,
          vertical: compact ? 6 : 7,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: border,
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: TextStyle(
            fontSize: compact ? 11.2 : 11.8,
            fontWeight: FontWeight.w600,
            color: textColor,
            height: 1,
          ),
        ),
      ),
    );
  }
}
