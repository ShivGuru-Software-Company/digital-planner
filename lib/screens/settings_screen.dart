import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FA), Color(0xFFE0E7FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Settings Options
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [_buildSettingsCard()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
      ),
      child: Column(
        children: [
          // App Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.settings, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          // Title
          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Manage your app preferences',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.info_outline,
            title: 'About Us',
            subtitle: 'Learn more about Digital Planner',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.policy_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy and terms',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.share_outlined,
            title: 'Share App',
            subtitle: 'Tell your friends about Digital Planner',
            onTap: _shareApp,
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.alarm_outlined,
            title: 'Test Alarm',
            subtitle: 'Test alarm functionality',
            onTap: _testAlarm,
          ),
          _buildDivider(),
          // _buildSettingsItem(
          //   icon: Icons.notifications_outlined,
          //   title: 'Notification Permissions',
          //   subtitle: 'Check notification settings',
          //   onTap: _checkNotificationPermissions,
          // ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF6366F1), size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFF9CA3AF),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withOpacity(0.1),
      indent: 72,
      endIndent: 20,
    );
  }

  void _shareApp() {
    Share.share(
      'Check out Digital Planner - Your Personal Planning Companion!\n\n'
      'A comprehensive offline digital planner and journal application with advanced features.\n\n'
      'Features:\n'
      '📅 Multiple template types (Daily, Weekly, Monthly, Yearly)\n'
      '📝 Rich text editing and drawing capabilities\n'
      '🔔 Smart alarms and notifications\n'
      '� Save to gallery\n'
      '💾 Offline storage - your data stays private\n\n'
      'Download now and start organizing your life better!',
      subject: 'Digital Planner App - Get Organized!',
    );
  }

  void _testAlarm() async {
    try {
      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Test Alarm'),
          content: const Text(
            'This will trigger a test alarm that will ring for 10 seconds. '
            'You can stop it early by tapping the notification or it will auto-stop.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Start Test'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        // await AlarmService.instance.testAlarm();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Test alarm started! It will ring for 10 seconds.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start test alarm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
