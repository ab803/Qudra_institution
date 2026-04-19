import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_institution/Features/Dashboard/widgets/ChartSection.dart';
import 'package:qudra_institution/Features/Dashboard/widgets/MetricCard.dart';
import 'package:qudra_institution/Features/Dashboard/widgets/PromoBanner.dart';
import 'package:qudra_institution/Features/Dashboard/widgets/QuickActionButton.dart';
import 'package:qudra_institution/Features/Dashboard/widgets/PortalDrawer.dart';
import '../../core/styles/AppColors.dart';
import '../../core/styles/AppTextStyles.dart';

class Dashboardview extends StatefulWidget {
  const Dashboardview({super.key});

  @override
  State<Dashboardview> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<Dashboardview> {
  // 1. Create the GlobalKey to control the Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 2. Assign the key to the Scaffold
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      // 3. Add the PortalDrawer here
      drawer: const PortalDrawer(currentRoute: 'dashboard'),
      body: SingleChildScrollView(
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

              const MetricCard(
                title: 'TOTAL SUBSCRIBERS',
                value: '12,842',
                statusText: '+14% this month',
                statusIcon: Icons.trending_up,
                statusColor: AppColors.success,
                isWhiteCard: true,
              ),
              const SizedBox(height: 16),
              const MetricCard(
                title: 'ACTIVE SERVICES',
                value: '48',
                statusText: 'All systems operational',
                statusIcon: Icons.check_circle,
                statusColor: AppColors.textPrimary,
                isWhiteCard: false,
              ),
              const SizedBox(height: 16),
              const MetricCard(
                title: 'PENDING REQUESTS',
                value: '156',
                statusText: '24 urgent actions',
                statusIcon: Icons.error,
                statusColor: AppColors.error,
                isWhiteCard: false,
              ),
              const SizedBox(height: 32),

              const ChartSection(),
              const SizedBox(height: 32),

              const Text('Quick Actions', style: AppTextStyles.screenTitle),
              const SizedBox(height: 16),
              QuickActionButton(
                title: 'Manage Subscription',
                icon: Icons.stars,
                bgColor: AppColors.textPrimary,
                textColor: AppColors.white,
                onPressed: () {
                  context.go('/subscription');
                },
              ),
              const SizedBox(height: 12),


              QuickActionButton(
                title: 'Manage Services',
                icon: Icons.layers,
                bgColor: AppColors.textPrimary,
                textColor: AppColors.white,
                onPressed: () => context.push('/services'),
              ),
              const SizedBox(height: 12),


              QuickActionButton(
                title: 'Add Service',
                icon: Icons.add,
                bgColor: AppColors.textPrimary,
                textColor: AppColors.white,
                onPressed: () => context.push('/services/add'),
              ),
              const SizedBox(height: 12),


              QuickActionButton(
                title: 'View Bookings',
                icon: Icons.book_online,
                bgColor: AppColors.textPrimary,
                textColor: AppColors.white,
                onPressed: () => context.push('/bookings'),
              ),

              const SizedBox(height: 12),
              const SizedBox(height: 12),
              QuickActionButton(
                title: 'Message Subscribers',
                icon: Icons.send,
                bgColor: AppColors.border,
                textColor: AppColors.textPrimary,
                onPressed: () {},
              ),
              const SizedBox(height: 32),
              const PromoBanner(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          // 4. Use the key to open the drawer
          _scaffoldKey.currentState?.openDrawer();
        },
        icon: const Icon(Icons.menu, color: AppColors.textPrimary),
      ),
      title: const Text('QUDRA', style: AppTextStyles.appBarTitle),
      centerTitle: true,
      actions: [
        const Icon(Icons.notifications_none, color: AppColors.textPrimary),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.secondary,
          child: Icon(Icons.person, color: AppColors.white, size: 20),
        ),
        const SizedBox(width: 24),
      ],
    );
  }
}