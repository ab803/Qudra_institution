import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_institution/Features/Dashboard/repo/DashboardRepository.dart';
import 'package:qudra_institution/Features/Dashboard/viewModel/dashboard_cubit.dart';
import 'package:qudra_institution/Features/Dashboard/viewModel/dashboard_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qudra_institution/Features/Dashboard/widgets/ChartSection.dart';
import 'package:qudra_institution/Features/Dashboard/widgets/MetricCard.dart';
import 'package:qudra_institution/Features/Dashboard/widgets/QuickActionButton.dart';
import '../../core/styles/AppColors.dart';
import '../../core/styles/AppTextStyles.dart';
import '../../core/responsive/responsive_helper.dart';
import '../../core/widgets/portal_page_header.dart';
import '../../core/widgets/portal_responsive_scaffold.dart';
import '../../core/widgets/responsive_grid.dart';
import '../../core/widgets/responsive_page_shell.dart';
import 'helper.dart';

class Dashboardview extends StatelessWidget {
  const Dashboardview({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the logged-in institution's ID from Supabase auth metadata
    final institutionId = Supabase.instance.client.auth.currentUser!.id;

    return BlocProvider(
      create: (_) => DashboardCubit(
        DashboardRepository(Supabase.instance.client),
      )..loadStats(institutionId),
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return PortalResponsiveScaffold(
      currentRoute: '/Dashboard',
      title: 'QUDRA',
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return _DashboardErrorState(
              onRetry: () {
                final id = Supabase.instance.client.auth.currentUser!.id;
                context.read<DashboardCubit>().loadStats(id, forceRefresh: true);
              },
            );
          }

          final stats = (state as DashboardLoaded).stats;
          final isDesktop = ResponsiveHelper.isDesktop(context);

          return ResponsivePageShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PortalPageHeader(
                  overline: 'Institution Portal',
                  title: 'Overview',
                  subtitle: 'System status and institutional metrics for Qudra Admin.',
                  trailing: isDesktop
                      ? SizedBox(
                    width: 260,
                    child: QuickActionButton(
                      title: 'Manage Subscription',
                      icon: Icons.stars_rounded,
                      bgColor: AppColors.textPrimary,
                      textColor: AppColors.white,
                      onPressed: () => context.go('/subscription'),
                    ),
                  )
                      : null,
                ),
                const SizedBox(height: 28),
                ResponsiveGrid(
                  mobileColumns: 1,
                  tabletColumns: 2,
                  desktopColumns: 2,
                  wideDesktopColumns: 2,
                  childAspectRatio: isDesktop ? 2.25 : 1.75,
                  children: [
                    MetricCard(
                      title: 'TOTAL SUBSCRIBERS',
                      value: stats.totalSubscribers.toString(),
                      statusText: 'Unique users who booked',
                      statusIcon: Icons.people_alt_rounded,
                      statusColor: AppColors.success,
                      isWhiteCard: true,
                    ),
                    MetricCard(
                      title: 'ACTIVE SERVICES',
                      value: stats.activeServices.toString(),
                      statusText: 'Available now',
                      statusIcon: Icons.check_circle,
                      statusColor: AppColors.textPrimary,
                      isWhiteCard: false,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: ChartSection(monthlyData: stats.monthlyGrowth),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 4,
                        child: _QuickActionsPanel(),
                      ),
                    ],
                  )
                else ...[
                  ChartSection(monthlyData: stats.monthlyGrowth),
                  const SizedBox(height: 24),
                  _QuickActionsPanel(),
                ],
                const SizedBox(height: 24),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuickActionsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 6),
          const Text(
            'Jump into the most important institution workflows.',
            style: AppTextStyles.pageDescription,
          ),
          const SizedBox(height: 18),
          if (isDesktop)
            Column(
              children: _actions(context)
                  .map(
                    (action) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: action,
                ),
              )
                  .toList(),
            )
          else
            ..._actions(context).map(
                  (action) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: action,
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _actions(BuildContext context) {
    return [
      QuickActionButton(
        title: 'Manage Subscription',
        icon: Icons.stars_rounded,
        bgColor: AppColors.textPrimary,
        textColor: AppColors.white,
        onPressed: () => context.go('/subscription'),
      ),
      QuickActionButton(
        title: 'Manage Services',
        icon: Icons.layers_rounded,
        bgColor: AppColors.textPrimary,
        textColor: AppColors.white,
        onPressed: () async {
          final allowed = await checkSubscription(context);
          if (allowed && context.mounted) context.go('/services');
        },
      ),
      QuickActionButton(
        title: 'Add Service',
        icon: Icons.add_rounded,
        bgColor: AppColors.textPrimary,
        textColor: AppColors.white,
        onPressed: () async {
          final allowed = await checkSubscription(context);
          if (allowed && context.mounted) context.go('/services/add');
        },
      ),
      QuickActionButton(
        title: 'View Subscribers',
        icon: Icons.people_rounded,
        bgColor: AppColors.textPrimary,
        textColor: AppColors.white,
        onPressed: () => context.go('/subscribers'),
      ),
    ];
  }
}

class _DashboardErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _DashboardErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 42),
            const SizedBox(height: 12),
            const Text(
              'Failed to load stats',
              style: AppTextStyles.sectionTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please retry loading your dashboard metrics.',
              style: AppTextStyles.description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.white,
                elevation: 0,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}