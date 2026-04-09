import 'package:flutter/material.dart';
import '../../core/styles/AppColors.dart';
import '../../core/styles/AppTextStyles.dart';
import '../Dashboard/widgets/PortalDrawer.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // Toggle states
  bool pushNotifications = true;
  bool emailAlerts = false;
  bool highContrast = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // ← add

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const PortalDrawer(currentRoute: '/settings'),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading:IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary), // ← menu instead of back
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),

        title: const Text('Settings', style: AppTextStyles.appBarTitle),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // ───────── Account Section ─────────
          const _SectionHeader(title: 'Account'),
          _buildSettingsGroup([
            _SettingsTile(icon: Icons.person, title: 'Profile', onTap: () {}),
            _SettingsTile(icon: Icons.lock, title: 'Password', onTap: () {}),
            _SettingsTile(icon: Icons.credit_card, title: 'Subscriptions', onTap: () {}),
          ]),

          // ───────── Notifications Section ─────────
          const _SectionHeader(title: 'Notifications'),
          _buildSettingsGroup([
            _SettingsTile(
              icon: Icons.notifications,
              title: 'Push Notifications',
              subtitle: 'Alerts on your device',
              trailing: Switch(
                value: pushNotifications,
                onChanged: (v) => setState(() => pushNotifications = v),
                activeColor: Colors.black,
              ),
            ),
            _SettingsTile(
              icon: Icons.email,
              title: 'Email Alerts',
              subtitle: 'Weekly summaries and updates',
              trailing: Switch(
                value: emailAlerts,
                onChanged: (v) => setState(() => emailAlerts = v),
                activeColor: Colors.black,
              ),
            ),
          ]),

          // ───────── Accessibility Section ─────────
          const _SectionHeader(title: 'Accessibility'),
          _buildSettingsGroup([
            _SettingsTile(
              icon: Icons.contrast,
              title: 'High Contrast Mode',
              trailing: Switch(
                value: highContrast,
                onChanged: (v) => setState(() => highContrast = v),
                activeColor: Colors.black,
              ),
            ),
            _SettingsTile(icon: Icons.record_voice_over, title: 'Screen Reader Setup', onTap: () {}),
            _SettingsTile(
              icon: Icons.text_fields,
              title: 'Font Size',
              subtitle: 'Medium (Default)',
              onTap: () {},
            ),
          ]),

          // ───────── Support & About Section ─────────
          const _SectionHeader(title: 'Support & About'),
          _buildSettingsGroup([
            _SettingsTile(icon: Icons.help, title: 'Help Center', trailing: const Icon(Icons.open_in_new, size: 20), onTap: () {}),
            _SettingsTile(icon: Icons.security, title: 'Privacy Policy', onTap: () {}),
            _SettingsTile(icon: Icons.description, title: 'Terms of Service', onTap: () {}),
          ]),

          const SizedBox(height: 32),

          // ───────── Logout Button ─────────
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),

          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Qudra Version 2.4.1',
              style: TextStyle(color: AppColors.textLight, fontSize: 13),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Wrapper for grouping tiles in white containers
  Widget _buildSettingsGroup(List<Widget> tiles) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: tiles),
    );
  }
}

// ───────── Custom Section Header ─────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
      ),
    );
  }
}

// ───────── Reusable Settings Tile ─────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.black, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: subtitle != null ? Text(subtitle!, style: AppTextStyles.description) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.black54),
    );
  }
}