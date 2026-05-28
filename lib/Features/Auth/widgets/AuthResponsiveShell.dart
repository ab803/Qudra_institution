import 'package:flutter/material.dart';
import '../../../core/responsive/responsive_helper.dart';
import '../../../core/styles/AppColors.dart';
import '../../../core/styles/AppTextStyles.dart';

class AuthResponsiveShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;
  final Widget? logo;
  final String sideTitle;
  final String sideSubtitle;

  const AuthResponsiveShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
    this.logo,
    this.sideTitle = 'Qudra Institution Portal',
    this.sideSubtitle =
    'Manage services, subscribers, and institutional operations from one professional dashboard.',
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  minWidth: constraints.maxWidth,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 20,
                    vertical: isDesktop ? 28 : 20,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 1040 : 520,
                      ),
                      child: isDesktop
                          ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _buildSidePanel(),
                          ),
                          const SizedBox(width: 28),
                          Expanded(
                            flex: 4,
                            child: _buildFormCard(context),
                          ),
                        ],
                      )
                          : _buildFormCard(context),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSidePanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (logo != null) ...[
            SizedBox(
              width: 170,
              height: 110,
              child: FittedBox(
                fit: BoxFit.contain,
                child: logo!,
              ),
            ),
            const SizedBox(height: 30),
          ],
          const Text(
            'INSTITUTION ACCESS',
            style: TextStyle(
              color: Color(0xFFC5CE4E),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            sideTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              height: 1.12,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            sideSubtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 34),
          _buildFeatureRow(Icons.dashboard_customize_outlined, 'Responsive web portal'),
          const SizedBox(height: 14),
          _buildFeatureRow(Icons.layers_outlined, 'Services management'),
          const SizedBox(height: 14),
          _buildFeatureRow(Icons.people_outline, 'Subscribers insights'),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isDesktop && logo != null) ...[
          SizedBox(
            width: 180,
            height: 110,
            child: FittedBox(
              fit: BoxFit.contain,
              child: logo!,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isDesktop ? 28 : 22),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [
              BoxShadow(
                color: AppColors.softShadow,
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.sectionTitle),
              const SizedBox(height: 8),
              Text(subtitle, style: AppTextStyles.pageDescription),
              const SizedBox(height: 24),
              child,
            ],
          ),
        ),
        if (footer != null) ...[
          const SizedBox(height: 22),
          footer!,
        ],
      ],
    );
  }
}