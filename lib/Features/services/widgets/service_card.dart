import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.black.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // This block renders the header with service title and status switch.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      service.category,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    service.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: service.isActive
                          ? Colors.green.shade700
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Transform.scale(
                    scale: 0.88,
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
              ),
            ],
          ),

          // This block renders the optional description.
          if (service.description != null &&
              service.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              service.description!.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: Colors.grey.shade800,
              ),
            ),
          ],

          const SizedBox(height: 14),

          // This block renders service metadata chips only.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TagChip(
                text: _formatPrice(),
                dark: true,
              ),
              _TagChip(text: '${service.durationMinutes} min'),
              _TagChip(text: service.locationMode.replaceAll('_', ' ')),
              _TagChip(text: service.bookingType.replaceAll('_', ' ')),
              ...service.supportedDisabilities.map(
                    (item) => _TagChip(
                  text: item,
                  light: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // This divider separates metadata from actions for a cleaner layout.
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.black.withOpacity(0.05),
          ),

          const SizedBox(height: 14),

          // This block renders the action buttons in a dedicated row.
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
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
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      'Edit',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 52,
                height: 44,
                child: OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD32F2F),
                    side: const BorderSide(
                      color: Color(0xFFFFCDD2),
                    ),
                    backgroundColor: const Color(0xFFFFF5F5),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
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

class _TagChip extends StatelessWidget {
  final String text;
  final bool light;
  final bool dark;

  const _TagChip({
    required this.text,
    this.light = false,
    this.dark = false,
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: border,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.8,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1,
        ),
      ),
    );
  }
}
