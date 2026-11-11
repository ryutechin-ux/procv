import 'package:flutter/material.dart';

/// Responsive breakpoints and utilities
class Responsive {
  Responsive._();

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double wideBreakpoint = 1536;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < desktopBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  static bool isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= wideBreakpoint;

  static double sidebarWidth(BuildContext context) {
    if (isMobile(context)) return 0;
    if (isTablet(context)) return 72;
    return 260;
  }

  static bool showExpandedSidebar(BuildContext context) =>
      isDesktop(context);

  static bool showCollapsedSidebar(BuildContext context) =>
      isTablet(context);

  static int dashboardCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    if (isWide(context)) return 4;
    return 3;
  }

  static double contentPadding(BuildContext context) {
    if (isMobile(context)) return 16;
    if (isTablet(context)) return 24;
    return 32;
  }

  static double cardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return width - 32;
    if (width < desktopBreakpoint) return (width - 72 - 64) / 2;
    return (width - 260 - 128) / 3;
  }
}

/// Responsive layout builder widget
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Responsive.desktopBreakpoint) {
          return desktop;
        } else if (constraints.maxWidth >= Responsive.mobileBreakpoint) {
          return tablet ?? desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}

