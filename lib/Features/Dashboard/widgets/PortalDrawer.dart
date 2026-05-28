import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/Models/institutionModel.dart';
import '../../../core/responsive/responsive_breakpoints.dart';
import '../../../core/styles/AppColors.dart';
import '../../../core/styles/AppTextStyles.dart';
import '../../../core/supabase/institutionservice.dart';
import '../helper.dart';

class PortalDrawer extends StatefulWidget {
  final String currentRoute;
  final bool showAsDrawer;

  const PortalDrawer({
    super.key,
    required this.currentRoute,
    this.showAsDrawer = true,
  });

  @override
  State<PortalDrawer> createState() => _PortalDrawerState();
}

class _PortalDrawerState extends State<PortalDrawer> {
  final InstitutionService _service = InstitutionService();
  InstitutionModel? _profile;
  bool _loadingProfile = true;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _service.getCurrentProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _loadingProfile = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    try {
      await _service.logout();
      if (mounted) context.go('/institutionLogin');
    } catch (e) {
      if (mounted) {
        setState(() => _loggingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  void _closeDrawerIfNeeded() {
    if (widget.showAsDrawer && Navigator.of(context).canPop()) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleNavigation({
    required String route,
    required bool isSelected,
    bool requiresSubscription = false,
  }) async {
    final router = GoRouter.of(context);

    if (isSelected) {
      _closeDrawerIfNeeded();
      return;
    }

    if (requiresSubscription) {
      final allowed = await checkSubscription(context);
      if (!mounted) return;
      _closeDrawerIfNeeded();
      if (allowed) router.go(route);
      return;
    }

    _closeDrawerIfNeeded();
    router.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _loadingProfile
                ? const Center(child: CircularProgressIndicator())
                : _buildProfileCard(),
            const SizedBox(height: 32),
            _buildNavTile(
              context,
              icon: Icons.dashboard,
              label: 'Dashboard',
              route: '/Dashboard',
            ),
            _buildNavTile(
              context,
              icon: Icons.layers,
              label: 'Services',
              route: '/services',
              requiresSubscription: true,
            ),
            _buildNavTile(
              context,
              icon: Icons.people,
              label: 'Subscribers',
              route: '/subscribers',
            ),
            _buildNavTile(
              context,
              icon: Icons.person_outline,
              label: 'Profile',
              route: '/profile',
            ),
            const Spacer(),
            _buildLogoutButton(),
            const SizedBox(height: 16),
            _buildFooter(),
          ],
        ),
      ),
    );

    if (widget.showAsDrawer) {
      return Drawer(
        backgroundColor: AppColors.background,
        elevation: 0,
        child: content,
      );
    }

    return Container(
      width: ResponsiveBreakpoints.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground,
        border: Border(
          right: BorderSide(color: AppColors.divider),
        ),
      ),
      child: content,
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFC5CE4E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.account_balance,
            size: 24,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Portal',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'DEPLOYMENT',
          style: AppTextStyles.description.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'V1.0.0',
          style: AppTextStyles.description.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    final name = _profile?.name ?? 'Institution';
    final email = _profile?.email ?? '—';
    final type = _profile?.institutionType ?? '—';
    final phone = _profile?.phone ?? '—';

    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.isNotEmpty
        ? name[0].toUpperCase()
        : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.black,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC5CEFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        type.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          _buildProfileDetail(Icons.email_outlined, email),
          const SizedBox(height: 8),
          _buildProfileDetail(Icons.phone_outlined, phone),
        ],
      ),
    );
  }

  Widget _buildProfileDetail(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _loggingOut ? null : _logout,
        icon: _loggingOut
            ? const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(Icons.logout, color: Colors.white, size: 18),
        label: Text(
          _loggingOut ? 'Logging out...' : 'Logout',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildNavTile(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String route,
        bool requiresSubscription = false,
      }) {
    final bool isSelected = widget.currentRoute == route;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: !widget.showAsDrawer,
        leading: Icon(
          icon,
          color: isSelected ? AppColors.white : AppColors.textSecondary,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 16,
          ),
        ),
        trailing: requiresSubscription
            ? Icon(
          Icons.lock_outline,
          size: 16,
          color: isSelected ? AppColors.white : AppColors.textSecondary,
        )
            : null,
        onTap: () => _handleNavigation(
          route: route,
          isSelected: isSelected,
          requiresSubscription: requiresSubscription,
        ),
      ),
    );
  }
}