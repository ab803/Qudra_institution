import 'package:flutter/material.dart';
import '../responsive/responsive_helper.dart';

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final int? wideDesktopColumns;
  final double childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.wideDesktopColumns,
    this.childAspectRatio = 1.55,
  });

  @override
  Widget build(BuildContext context) {
    final columns = _columnsFor(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: children.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => children[index],
    );
  }

  int _columnsFor(BuildContext context) {
    if (ResponsiveHelper.isWideDesktop(context)) {
      return wideDesktopColumns ?? desktopColumns ?? 4;
    }

    if (ResponsiveHelper.isDesktop(context)) {
      return desktopColumns ?? 3;
    }

    if (ResponsiveHelper.isTablet(context)) {
      return tabletColumns ?? 2;
    }

    return mobileColumns ?? 1;
  }
}