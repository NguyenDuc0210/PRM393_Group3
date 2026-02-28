import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/theme_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: themeMode == ThemeMode.dark,
            onChanged: (bool value) {
              ref.read(themeNotifierProvider.notifier).toggleTheme();
            },
          ),
          const Divider(),
          _buildSectionTitle(context, 'Account'),
          _buildSettingsItem(
            context,
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () { /* TODO: Navigate to profile edit screen */ },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () { /* TODO: Navigate to password change screen */ },
          ),
          const Divider(),
          _buildSectionTitle(context, 'General'),
          _buildSettingsItem(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () { /* TODO: Navigate to notification settings screen */ },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.language_outlined,
            title: 'Language',
            onTap: () { /* TODO: Navigate to language selection screen */ },
          ),
          const Divider(),
          _buildSettingsItem(
            context,
            icon: Icons.info_outline,
            title: 'About',
            onTap: () { /* TODO: Show about dialog or screen */ },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
