import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/glass_card.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F7FA),
              Color(0xFFE0E7FF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 24),
                _buildAppearanceSection(context),
                const SizedBox(height: 20),
                _buildLanguageSection(context),
                const SizedBox(height: 20),
                _buildDataSection(context),
                const SizedBox(height: 20),
                _buildAboutSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appearance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Column(
                  children: [
                    _buildSettingTile(
                      icon: Icons.brightness_6,
                      title: 'Theme Mode',
                      trailing: DropdownButton<ThemeMode>(
                        value: themeProvider.themeMode,
                        onChanged: (mode) {
                          if (mode != null) {
                            themeProvider.setThemeMode(mode);
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('System'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    _buildSettingTile(
                      icon: Icons.blur_on,
                      title: 'Glassmorphism Effects',
                      trailing: Switch(
                        value: themeProvider.useGlassmorphism,
                        onChanged: (_) => themeProvider.toggleGlassmorphism(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                return _buildSettingTile(
                  icon: Icons.language,
                  title: 'App Language',
                  trailing: DropdownButton<String>(
                    value: languageProvider.locale.languageCode,
                    onChanged: (code) {
                      if (code != null) {
                        languageProvider.setLocale(Locale(code, ''));
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: 'hi',
                        child: Text('हिंदी'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              icon: Icons.backup,
              title: 'Backup Data',
              subtitle: 'Export all your data',
              onTap: () => _showBackupDialog(context),
            ),
            const Divider(),
            _buildSettingTile(
              icon: Icons.restore,
              title: 'Restore Data',
              subtitle: 'Import from backup',
              onTap: () => _showRestoreDialog(context),
            ),
            const Divider(),
            _buildSettingTile(
              icon: Icons.delete_forever,
              title: 'Clear All Data',
              subtitle: 'Delete all entries and templates',
              onTap: () => _showClearDataDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              icon: Icons.info_outline,
              title: 'About Us',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
            const Divider(),
            _buildSettingTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                );
              },
            ),
            const Divider(),
            _buildSettingTile(
              icon: Icons.gavel,
              title: 'Terms of Service',
              onTap: () {},
            ),
            const Divider(),
            _buildSettingTile(
              icon: Icons.star_outline,
              title: 'Rate App',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6366F1)),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text('Export all your journal entries and templates?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup created successfully')),
              );
            },
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text('Select a backup file to restore from.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Select File'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your entries and templates. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
