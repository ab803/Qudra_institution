import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/Models/institutionModel.dart';
import '../../../core/styles/AppColors.dart';
import '../../../core/styles/AppTextStyles.dart';
import '../../../core/supabase/institutionservice.dart';
import '../../Dashboard/widgets/PortalDrawer.dart';

class InstitutionProfileView extends StatefulWidget {
  const InstitutionProfileView({super.key});

  @override
  State<InstitutionProfileView> createState() => _InstitutionProfileViewState();
}

class _InstitutionProfileViewState extends State<InstitutionProfileView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final InstitutionService _service = InstitutionService();

  InstitutionModel? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // This loads the current institution profile for the profile screen.
  Future<void> _loadProfile() async {
    try {
      final profile = await _service.getCurrentProfile();
      if (!mounted) return;

      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // This opens the subscription screen directly from the profile page.
  void _openSubscription() {
    context.go('/subscription');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const PortalDrawer(currentRoute: '/profile'),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildErrorState()
            : _profile == null
            ? _buildEmptyState()
            : ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 16),
            _buildHeroCard(_profile!),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'CONTACT',
              children: [
                _buildInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: _profile!.email,
                ),
                _buildInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: _profile!.phone ?? '—',
                ),
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: _profile!.address ?? '—',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'INSTITUTION',
              children: [
                _buildInfoRow(
                  icon: Icons.business_outlined,
                  label: 'Institution Type',
                  value: _profile!.institutionType,
                ),
                _buildInfoRow(
                  icon: Icons.link_outlined,
                  label: 'Location Link',
                  value: _profile!.location,
                ),
                _buildInfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Created At',
                  value: _formatDate(_profile!.createdAt),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'ACCOUNT STATUS',
              children: [
                _buildInfoRow(
                  icon: Icons.verified_outlined,
                  label: 'Approval Status',
                  value: _profile!.status,
                ),
                _buildInfoRow(
                  icon: Icons.stars_outlined,
                  label: 'Subscription',
                  value: _profile!.subscribed
                      ? 'Active'
                      : 'Inactive',
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openSubscription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.stars_outlined),
                label: const Text('Manage Subscription'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.go('/Dashboard'),
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
      ),
      title: const Text('Profile', style: AppTextStyles.appBarTitle),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildHeroCard(InstitutionModel profile) {
    final parts = profile.name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : profile.name.isNotEmpty
        ? profile.name[0].toUpperCase()
        : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFF242424),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildHeroBadge(profile.institutionType),
              _buildHeroBadge(profile.status.toUpperCase()),
              _buildHeroBadge(
                profile.subscribed ? 'SUBSCRIBED' : 'NOT SUBSCRIBED',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFC5CEFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
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
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
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
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 44),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Failed to load profile.',
              textAlign: TextAlign.center,
              style: AppTextStyles.description,
            ),
            const SizedBox(height: 12),
            TextButton(
              // This retries loading the current institution profile.
              onPressed: _loadProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.person_outline, color: Colors.grey, size: 44),
            SizedBox(height: 12),
            Text(
              'No institution profile found.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
  }
}
