import 'package:flutter/material.dart';
import '../../../core/styles/AppTextStyles.dart';

class InstitutionTagline extends StatelessWidget {
  final Animation<Offset> slide;
  final Animation<double> opacity;

  const InstitutionTagline({
    super.key,
    required this.slide,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SlideTransition(
      position: slide,
      child: FadeTransition(
        opacity: opacity,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              'Empowering institutions to serve better',
              style: AppTextStyles.subtitle.copyWith(
                color: theme.textTheme.bodyMedium?.color,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}