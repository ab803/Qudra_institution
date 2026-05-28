import 'package:flutter/material.dart';
import '../styles/AppTextStyles.dart';
import '../responsive/responsive_helper.dart';

class PortalPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? overline;

  const PortalPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.overline,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overline != null && overline!.trim().isNotEmpty) ...[
          Text(
            overline!.toUpperCase(),
            style: AppTextStyles.overline,
          ),
          const SizedBox(height: 8),
        ],
        Text(
          title,
          style: isMobile
              ? AppTextStyles.screenTitle
              : AppTextStyles.pageTitle,
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: AppTextStyles.pageDescription,
          ),
        ],
      ],
    );

    if (isMobile || trailing == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          if (trailing != null) ...[
            const SizedBox(height: 16),
            trailing!,
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: titleBlock),
        const SizedBox(width: 20),
        trailing!,
      ],
    );
  }
}