import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Features/Dashboard/widgets/PortalDrawer.dart';
import '../responsive/responsive_helper.dart';
import '../styles/AppColors.dart';
import '../styles/AppTextStyles.dart';


class PortalResponsiveScaffold extends StatefulWidget {
  final String currentRoute;
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final bool showMobileAppBar;

  const PortalResponsiveScaffold({
    super.key,
    required this.currentRoute,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.showMobileAppBar = true,
  });

  @override
  State<PortalResponsiveScaffold> createState() => _PortalResponsiveScaffoldState();
}

class _PortalResponsiveScaffoldState extends State<PortalResponsiveScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            PortalDrawer(
              currentRoute: widget.currentRoute,
              showAsDrawer: false,
            ),
            Expanded(
              child: widget.body,
            ),
          ],
        ),
        floatingActionButton: widget.floatingActionButton,
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: PortalDrawer(currentRoute: widget.currentRoute),
      appBar: widget.showMobileAppBar
          ? AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
        ),
        title: Text(widget.title, style: AppTextStyles.appBarTitle),
        centerTitle: true,
        actions: widget.actions,
      )
          : null,
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}