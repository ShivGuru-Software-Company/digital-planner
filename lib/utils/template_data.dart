import 'package:flutter/material.dart';
import '../models/template_model.dart';

class TemplateData {
  static List<TemplateModel> getAllTemplates() {
    return [
      TemplateModel(
        id: 'daily_planner',
        name: 'Daily Planner',
        description: 'Plan your day with tasks and schedules',
        category: 'Daily',
        icon: Icons.today,
        colors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      ),
      TemplateModel(
        id: 'weekly_planner',
        name: 'Weekly Planner',
        description: 'Organize your entire week',
        category: 'Weekly',
        icon: Icons.view_week,
        colors: [const Color(0xFF10B981), const Color(0xFF34D399)],
      ),
      TemplateModel(
        id: 'monthly_planner',
        name: 'Monthly Planner',
        description: 'Plan and track monthly goals',
        category: 'Monthly',
        icon: Icons.calendar_month,
        colors: [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
      ),
      TemplateModel(
        id: 'bullet_journal',
        name: 'Bullet Journal',
        description: 'Quick notes and task tracking',
        category: 'Journal',
        icon: Icons.circle_outlined,
        colors: [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)],
      ),
      TemplateModel(
        id: 'mood_tracker',
        name: 'Mood Tracker',
        description: 'Track your daily moods and emotions',
        category: 'Journal',
        icon: Icons.sentiment_satisfied_alt,
        colors: [const Color(0xFFEC4899), const Color(0xFFF472B6)],
      ),
      TemplateModel(
        id: 'gratitude_journal',
        name: 'Gratitude Journal',
        description: 'Daily gratitude and reflections',
        category: 'Journal',
        icon: Icons.favorite,
        colors: [const Color(0xFFEF4444), const Color(0xFFF87171)],
      ),
      TemplateModel(
        id: 'fitness_tracker',
        name: 'Fitness Tracker',
        description: 'Track workouts and fitness goals',
        category: 'Fitness',
        icon: Icons.fitness_center,
        colors: [const Color(0xFF06B6D4), const Color(0xFF22D3EE)],
      ),
      TemplateModel(
        id: 'meal_planner',
        name: 'Meal Planner',
        description: 'Plan your meals and recipes',
        category: 'Daily',
        icon: Icons.restaurant,
        colors: [const Color(0xFFF97316), const Color(0xFFFB923C)],
      ),
      TemplateModel(
        id: 'study_planner',
        name: 'Study Planner',
        description: 'Organize study sessions and topics',
        category: 'Study',
        icon: Icons.school,
        colors: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
      ),
      TemplateModel(
        id: 'finance_tracker',
        name: 'Finance Tracker',
        description: 'Track expenses and budget',
        category: 'Finance',
        icon: Icons.attach_money,
        colors: [const Color(0xFF10B981), const Color(0xFF059669)],
      ),
      TemplateModel(
        id: 'habit_tracker',
        name: 'Habit Tracker',
        description: 'Build and track daily habits',
        category: 'Daily',
        icon: Icons.check_circle_outline,
        colors: [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
      ),
      TemplateModel(
        id: 'travel_planner',
        name: 'Travel Planner',
        description: 'Plan trips and itineraries',
        category: 'Daily',
        icon: Icons.flight,
        colors: [const Color(0xFF0EA5E9), const Color(0xFF38BDF8)],
      ),
      TemplateModel(
        id: 'project_planner',
        name: 'Project Planner',
        description: 'Manage projects and milestones',
        category: 'Daily',
        icon: Icons.assignment,
        colors: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
      ),
      TemplateModel(
        id: 'reading_log',
        name: 'Reading Log',
        description: 'Track books and reading progress',
        category: 'Journal',
        icon: Icons.menu_book,
        colors: [const Color(0xFF78350F), const Color(0xFF92400E)],
      ),
      TemplateModel(
        id: 'water_tracker',
        name: 'Water Tracker',
        description: 'Track daily water intake',
        category: 'Fitness',
        icon: Icons.water_drop,
        colors: [const Color(0xFF0284C7), const Color(0xFF0EA5E9)],
      ),
      TemplateModel(
        id: 'sleep_tracker',
        name: 'Sleep Tracker',
        description: 'Monitor sleep patterns',
        category: 'Fitness',
        icon: Icons.bedtime,
        colors: [const Color(0xFF6366F1), const Color(0xFF818CF8)],
      ),
      TemplateModel(
        id: 'workout_log',
        name: 'Workout Log',
        description: 'Record exercise routines',
        category: 'Fitness',
        icon: Icons.sports_gymnastics,
        colors: [const Color(0xFFDC2626), const Color(0xFFEF4444)],
      ),
      TemplateModel(
        id: 'goal_setting',
        name: 'Goal Setting',
        description: 'Set and track personal goals',
        category: 'Daily',
        icon: Icons.flag,
        colors: [const Color(0xFFD97706), const Color(0xFFF59E0B)],
      ),
      TemplateModel(
        id: 'time_blocking',
        name: 'Time Blocking',
        description: 'Schedule time blocks for tasks',
        category: 'Daily',
        icon: Icons.schedule,
        colors: [const Color(0xFF7C3AED), const Color(0xFF8B5CF6)],
      ),
      TemplateModel(
        id: 'birthday_tracker',
        name: 'Birthday Tracker',
        description: 'Remember important birthdays',
        category: 'Daily',
        icon: Icons.cake,
        colors: [const Color(0xFFEC4899), const Color(0xFFF472B6)],
      ),
    ];
  }

  static List<TemplateModel> getTemplatesByCategory(String category) {
    return getAllTemplates()
        .where((template) => template.category == category)
        .toList();
  }

  static TemplateModel? getTemplateById(String id) {
    try {
      return getAllTemplates().firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }
}
