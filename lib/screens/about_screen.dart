import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.book_outlined,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Digital Planner',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About the App',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Digital Planner is your comprehensive offline journal and planning companion. '
                        'With over 100+ pre-designed templates, you can organize your daily tasks, '
                        'track your moods, plan your meals, manage your finances, and much more.\n\n'
                        'All your data is stored securely on your device, ensuring complete privacy '
                        'and offline access. No subscriptions, no ads - just a pure planning experience.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Features',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFeature('100+ pre-designed templates'),
                      _buildFeature('Offline functionality'),
                      _buildFeature('Drawing and note-taking'),
                      _buildFeature('Image insertion'),
                      _buildFeature('PDF export'),
                      _buildFeature('Calendar integration'),
                      _buildFeature('Reminders and notifications'),
                      _buildFeature('Customizable templates'),
                      _buildFeature('Multiple languages'),
                      _buildFeature('No ads or subscriptions'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact Us',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildContactInfo(Icons.email, 'support@digitalplanner.com'),
                      _buildContactInfo(Icons.language, 'www.digitalplanner.com'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '© 2025 Digital Planner. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 20,
            color: Color(0xFF6366F1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
