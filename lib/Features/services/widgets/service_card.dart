import 'package:flutter/material.dart';

import '../services/Models/service_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onEdit,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
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
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Transform.scale(
                scale: 0.82,
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

          /// Description
          if (service.description != null &&
              service.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              service.description!.trim(),
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: Colors.grey.shade800,
              ),
            ),
          ],

          const SizedBox(height: 10),

          /// Meta + edit
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _TagChip(
                      text: service.isFree ? 'Free' : 'EGP ${service.price}',
                      dark: true,
                    ),
                    _TagChip(text: '${service.durationMinutes} min'),
                    _TagChip(text: service.locationMode),
                    _TagChip(text: service.bookingType),
                    ...service.supportedDisabilities.map(
                          (e) => _TagChip(text: e, light: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onEdit,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined, size: 16, color: Colors.black),
                      SizedBox(width: 5),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: border,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1,
        ),
      ),
    );
  }
}
