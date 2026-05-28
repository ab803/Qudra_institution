import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';

class ResponsiveHelper {
  // This helper checks if the current width is mobile.
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < ResponsiveBreakpoints.mobile;
  }

  // This helper checks if the current width is tablet.
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ResponsiveBreakpoints.mobile &&
        width < ResponsiveBreakpoints.tablet;
  }

  // This helper checks if the current width is desktop.
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= ResponsiveBreakpoints.tablet;
  }

  // This helper checks if the current width is a wide desktop screen.
  static bool isWideDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= ResponsiveBreakpoints.wideDesktop;
  }

  // This helper returns a responsive page horizontal padding.
  static double pageHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= ResponsiveBreakpoints.desktop) return 32;
    if (width >= ResponsiveBreakpoints.tablet) return 24;
    if (width >= ResponsiveBreakpoints.mobile) return 20;
    return 16;
  }

  // This helper returns a responsive page vertical padding.
  static double pageVerticalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= ResponsiveBreakpoints.desktop) return 28;
    if (width >= ResponsiveBreakpoints.tablet) return 24;
    return 16;
  }

  // This helper returns responsive EdgeInsets for page bodies.
  static EdgeInsets pagePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: pageHorizontalPadding(context),
      vertical: pageVerticalPadding(context),
    );
  }

  // This helper returns a max width that prevents stretched UI on web.
  static double contentMaxWidth(
      BuildContext context, {
        double? desktopMaxWidth,
        double? tabletMaxWidth,
      }) {
    if (isDesktop(context)) {
      return desktopMaxWidth ?? ResponsiveBreakpoints.maxContentWidth;
    }
    if (isTablet(context)) {
      return tabletMaxWidth ?? ResponsiveBreakpoints.maxNarrowContentWidth;
    }
    return double.infinity;
  }

  // This helper returns a max width for form-heavy pages.
  static double formMaxWidth(BuildContext context) {
    if (isDesktop(context)) return ResponsiveBreakpoints.maxFormWidth;
    if (isTablet(context)) return ResponsiveBreakpoints.maxNarrowContentWidth;
    return double.infinity;
  }

  // This helper returns a responsive grid count for cards.
  static int metricsGridCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1400) return 4;
    if (width >= ResponsiveBreakpoints.desktop) return 3;
    if (width >= ResponsiveBreakpoints.tablet) return 2;
    return 1;
  }

  // This helper returns a responsive grid count for management cards.
  static int managementGridCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1500) return 4;
    if (width >= ResponsiveBreakpoints.desktop) return 3;
    if (width >= ResponsiveBreakpoints.tablet) return 2;
    return 1;
  }

  // This helper returns whether hover-oriented desktop interactions should be enabled.
  static bool supportsDesktopInteractions(BuildContext context) {
    return isDesktop(context);
  }
}