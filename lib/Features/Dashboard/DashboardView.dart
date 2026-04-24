import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_institution/Features/Dashboard/repo/DashboardRepository.dart';
import 'package:qudra_institution/Features/Dashboard/viewModel/dashboard_cubit.dart';
import 'package:qudra_institution/Features/Dashboard/viewModel/dashboard_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qudra_institution/Features/Dashboard/widgets/ChartSection.dart';
import 'package:qudra_institution/Features/Dashboard/widgets/MetricCard.dart';
import 'package:qudra_institution/Features/Dashboard/widgets/QuickActionButton.dart';
import 'package:qudra_institution/Features/Dashboard/widgets/PortalDrawer.dart';
import '../../core/styles/AppColors.dart';
import '../../core/styles/AppTextStyles.dart';
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

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      drawer: const PortalDrawer(currentRoute: 'dashboard'),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Failed to load stats',
                      style: AppTextStyles.description),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      final id =
                          Supabase.instance.client.auth.currentUser!.id;
                      context.read<DashboardCubit>().loadStats(id);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final stats = (state as DashboardLoaded).stats;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text('Overview', style: AppTextStyles.largeTitle),
                  const SizedBox(height: 8),
                  Text(
                    'System status and institutional metrics\nfor Qudra Admin.',
                    style: AppTextStyles.description.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 32),

                  // ── Real data from Supabase ──
                  MetricCard(
                    title: 'TOTAL SUBSCRIBERS',
                    value: stats.totalSubscribers.toString(),
                    statusText: 'Unique users who booked',
                    statusIcon: Icons.people_alt_rounded,
                    statusColor: AppColors.success,
                    isWhiteCard: true,
                  ),
                  const SizedBox(height: 16),
                  MetricCard(
                    title: 'ACTIVE SERVICES',
                    value: stats.activeServices.toString(),
                    statusText: 'Available now',
                    statusIcon: Icons.check_circle,
                    statusColor: AppColors.textPrimary,
                    isWhiteCard: false,
                  ),
                  const SizedBox(height: 32),

                  // ── Chart with real monthly data ──
                  ChartSection(monthlyData: stats.monthlyGrowth),
                  const SizedBox(height: 32),

                  const Text('Quick Actions', style: AppTextStyles.screenTitle),
                  const SizedBox(height: 16),

                  QuickActionButton(
                    title: 'Manage Subscription',
                    icon: Icons.stars,
                    bgColor: AppColors.textPrimary,
                    textColor: AppColors.white,
                    onPressed: () => context.go('/subscription'),
                  ),
                  const SizedBox(height: 12),
                  QuickActionButton(
                    title: 'Manage Services',
                    icon: Icons.layers,
                    bgColor: AppColors.textPrimary,
                    textColor: AppColors.white,
                    onPressed: () async {
                      final allowed = await checkSubscription(context);
                      if (allowed && context.mounted) context.go('/services');
                    },
                  ),
                  const SizedBox(height: 12),
                  QuickActionButton(
                    title: 'Add Service',
                    icon: Icons.add,
                    bgColor: AppColors.textPrimary,
                    textColor: AppColors.white,
                    onPressed: () async {
                      final allowed = await checkSubscription(context);
                      if (allowed && context.mounted) context.go('/services/add');
                    },
                  ),
                  const SizedBox(height: 12),
                  QuickActionButton(
                    title: 'View Bookings',
                    icon: Icons.book_online,
                    bgColor: AppColors.textPrimary,
                    textColor: AppColors.white,
                    onPressed: () async {
                      final allowed = await checkSubscription(context);
                      if (allowed && context.mounted) context.go('/bookings');
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        icon: const Icon(Icons.menu, color: AppColors.textPrimary),
      ),
      title: const Text('QUDRA', style: AppTextStyles.appBarTitle),
      centerTitle: true,
    );
  }
}