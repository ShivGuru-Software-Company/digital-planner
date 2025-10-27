import 'package:flutter/material.dart';
import '../services/notification_service.dart';
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
            colors: [Color(0xFFF5F7FA), Color(0xFFE0E7FF)],
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
                _buildNotificationTestSection(context),
                const SizedBox(height: 20),
                _buildAboutSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTestSection(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Testing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              icon: Icons.notifications_active,
              title: 'Test Instant Notification',
              subtitle: 'Show notification immediately',
              onTap: () => _testInstantNotification(context),
            ),
            const Divider(),
            _buildSettingTile(
              icon: Icons.schedule,
              title: 'Test Scheduled Notification',
              subtitle: 'Schedule notification for 10 seconds',
              onTap: () => _testScheduledNotification(context),
            ),
            const Divider(),
            _buildSettingTile(
              icon: Icons.list,
              title: 'Show Pending Notifications',
              subtitle: 'View all scheduled notifications',
              onTap: () => _showPendingNotifications(context),
            ),
            const Divider(),
            _buildSettingTile(
              icon: Icons.security,
              title: 'Check Notification Permissions',
              subtitle: 'Verify notification and alarm permissions',
              onTap: () => _checkNotificationPermissions(context),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
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
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  Future<void> _testInstantNotification(BuildContext context) async {
    try {
      await NotificationService.instance.showTestNotification();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test notification sent!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _testScheduledNotification(BuildContext context) async {
    try {
      await NotificationService.instance.scheduleTestNotification();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification scheduled for 10 seconds!'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _showPendingNotifications(BuildContext context) async {
    try {
      final pending = await NotificationService.instance
          .getPendingNotifications();
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pending Notifications'),
            content: SizedBox(
              width: double.maxFinite,
              child: pending.isEmpty
                  ? const Text('No pending notifications')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: pending.length,
                      itemBuilder: (context, index) {
                        final notification = pending[index];
                        return ListTile(
                          title: Text(notification.title ?? 'No title'),
                          subtitle: Text(notification.body ?? 'No body'),
                          trailing: Text('ID: ${notification.id}'),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _checkNotificationPermissions(BuildContext context) async {
    try {
      final canSchedule = await NotificationService.instance
          .canScheduleExactNotifications();
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Notification Permissions'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exact Alarm Permission: ${canSchedule ? "✅ Granted" : "❌ Not Granted"}',
                ),
                const SizedBox(height: 8),
                if (!canSchedule)
                  const Text(
                    'For reminders to work properly, please grant exact alarm permission in your device settings.',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking permissions: $e')),
        );
      }
    }
  }
}
