import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Introduction',
                      'Digital Planner is committed to protecting your privacy. '
                          'This Privacy Policy explains how we handle your information when you use our app.',
                    ),
                    _buildSection(
                      'Data Collection',
                      'Digital Planner operates entirely offline and does NOT collect, transmit, '
                          'or store any of your personal data on external servers. All your journal entries, '
                          'templates, drawings, and images are stored locally on your device.',
                    ),
                    _buildSection(
                      'Data Storage',
                      'All data is stored locally on your device using secure local storage methods and never transmitted to our servers or any third parties.',
                    ),
                    _buildSection(
                      'Data Access',
                      'Only you have access to your data through the app. We do not have access to any '
                          'information stored in the app, and we cannot view, modify, or delete your data.',
                    ),
                    _buildSection(
                      'Data Security',
                      'We implement industry-standard security measures to protect your data on your device. '
                          'However, please note that the security of your data also depends on the security of your device itself.',
                    ),
                    _buildSection(
                      'Permissions',
                      'The app may request the following permissions:\n\n'
                          '• Storage: To save your entries, images locally\n'
                          '• Gallery: To add images to your entries (optional)\n'
                          '• Notifications: To send you reminders for your tasks and entries\n\n'
                          'These permissions are used solely for app functionality and do not involve data transmission.',
                    ),
                    _buildSection(
                      'No Third-Party Services',
                      'Digital Planner does not integrate with any third-party analytics, advertising, '
                          'or tracking services. Your privacy is our priority.',
                    ),
                    _buildSection(
                      'Data Deletion',
                      'You can delete your data at any time through the app settings. '
                          'Uninstalling the app will also remove all locally stored data from your device.',
                    ),
                    _buildSection(
                      'Changes to Privacy Policy',
                      'We may update this Privacy Policy from time to time.',
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.security,
                            color: Color(0xFF6366F1),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your data never leaves your device. Complete privacy guaranteed.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
