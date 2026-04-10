import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/styles/AppColors.dart';
import '../../../core/styles/AppTextStyles.dart';

class PortalDrawer extends StatelessWidget {
  final String currentRoute;

  const PortalDrawer({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      elevation: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
              ),
              const SizedBox(height: 40),

              const CircleAvatar(
                radius: 36,
                backgroundImage:
                NetworkImage('https://via.placeholder.com/150'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Institutional Portal',
                style: AppTextStyles.screenTitle,
              ),
              Text(
                'ADMINISTRATOR',
                style: AppTextStyles.description.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 40),

              _buildNavTile(
                context: context,
                icon: Icons.dashboard,
                label: 'Dashboard',
                isSelected: currentRoute == 'dashboard',
                route: '/Dashboard',
              ),
              _buildNavTile(
                context: context,
                icon: Icons.layers,
                label: 'Services',
                isSelected: currentRoute == 'services',
                route: '/services',
              ),
              _buildNavTile(
                context: context,
                icon: Icons.people,
                label: 'Subscribers',
                isSelected: currentRoute == 'subscribers',
                route: null,
              ),
              _buildNavTile(
                context: context,
                icon: Icons.settings,
                label: 'Settings',
                isSelected: currentRoute == 'settings',
                route: null,
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATUS',
                      style: AppTextStyles.description.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.circle, color: AppColors.success, size: 10),
                        SizedBox(width: 8),
                        Text(
                          'Systems Nominal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
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
                    'V1.0.4',
                    style: AppTextStyles.description.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigate only if route exists
  Widget _buildNavTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required String? route,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
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
        onTap: route == null
            ? null
            : () {
          Navigator.of(context).pop();
          context.push(route);
        },
      ),
    );
  }
}