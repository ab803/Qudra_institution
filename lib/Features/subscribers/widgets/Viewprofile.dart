import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_institution/Features/Dashboard/widgets/PortalDrawer.dart';
import '../../../core/Models/subscriberModel.dart';
import '../../../core/styles/AppColors.dart';
import '../../../core/styles/AppTextStyles.dart';


class ViewProfileView extends StatefulWidget {
  final SubscriberModel subscriber;

  const ViewProfileView({super.key, required this.subscriber});

  @override
  State<ViewProfileView> createState() => _ViewProfileViewState();
}

class _ViewProfileViewState extends State<ViewProfileView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  SubscriberModel get s => widget.subscriber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,

      drawer: const PortalDrawer(currentRoute: '/subscribers'),
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 24),
          _buildHeroCard(),
          const SizedBox(height: 20),
          _buildInfoCard(
            title: 'CONTACT',
            items: [
              _InfoItem(icon: Icons.email_outlined, label: 'Email', value: s.email),
              _InfoItem(icon: Icons.phone_outlined, label: 'Phone', value: s.phone),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'PERSONAL',
            items: [
              _InfoItem(icon: Icons.accessible_outlined, label: 'Disability Type', value: s.disabilityType),
              _InfoItem(icon: Icons.person_outline, label: 'Gender', value: s.gender),
              _InfoItem(icon: Icons.cake_outlined, label: 'Age', value: s.age?.toString()),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'SUBSCRIPTION',
            items: [
              _InfoItem(
                icon: Icons.calendar_today_outlined,
                label: 'Joined',
                value: s.subscribedAt != null ? _formatDate(s.subscribedAt!) : null,
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── Hero Card ─────────────────────────────────────────────────────────────

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: const Color(0xFF2A2A2A),
            child: Text(
              s.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            s.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (s.disabilityType != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFC5CEFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                s.disabilityType!.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Info Card ─────────────────────────────────────────────────────────────

  Widget _buildInfoCard({
    required String title,
    required List<_InfoItem> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => _buildInfoRow(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(_InfoItem item) {
    final value = item.value?.isNotEmpty == true ? item.value! : '—';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => context.go("/subscribers"),
      ),
      title: const Text('Qudra', style: AppTextStyles.appBarTitle),
      centerTitle: true,
      actions: const [
        CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin'),
        ),
        SizedBox(width: 24),
      ],
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InfoItem {
  final IconData icon;
  final String label;
  final String? value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}