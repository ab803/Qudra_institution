import 'package:flutter/material.dart';
import '../responsive/responsive_helper.dart';

class ResponsivePageShell extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;
  final CrossAxisAlignment crossAxisAlignment;
  final bool centerContent;
  final ScrollController? scrollController;

  const ResponsivePageShell({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.centerContent = true,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? ResponsiveHelper.pagePadding(context);
    final effectiveMaxWidth = maxWidth ?? ResponsiveHelper.contentMaxWidth(context);

    final content = Padding(
      padding: effectivePadding,
      child: Align(
        alignment: centerContent ? Alignment.topCenter : Alignment.topLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            children: [child],
          ),
        ),
      ),
    );

    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      child: content,
    );
  }
}