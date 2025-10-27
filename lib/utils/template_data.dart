import 'package:flutter/material.dart';
import '../models/template_model.dart';

class TemplateData {
  static List<TemplateModel> getAllTemplates() {
    return [
      // Daily Planner Template
      TemplateModel(
        id: 'daily_planner',
        name: 'Daily Planner',
        description: 'Plan your day with tasks and priorities',
        category: 'Daily',
        icon: Icons.today,
        colors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
        sections: [
          TemplateSection(
            id: 'date_section',
            title: 'Date & Overview',
            icon: Icons.calendar_today,
            fields: [
              TemplateField(
                id: 'date',
                label: 'Date',
                type: FieldType.dateTime,
                required: true,
              ),
              TemplateField(
                id: 'priority_task',
                label: 'Priority Task of the Day',
                type: FieldType.text,
                placeholder: 'What\'s your most important task today?',
              ),
            ],
          ),
          TemplateSection(
            id: 'morning_section',
            title: 'Morning Tasks',
            icon: Icons.wb_sunny,
            fields: [
              TemplateField(
                id: 'morning_tasks',
                label: 'Morning To-Do List',
                type: FieldType.checkboxList,
                options: [
                  'Review daily goals',
                  'Check emails',
                  'Exercise/Workout',
                  'Healthy breakfast',
                  'Plan priorities',
                ],
              ),
              TemplateField(
                id: 'morning_notes',
                label: 'Morning Notes',
                type: FieldType.multilineText,
                placeholder: 'How are you feeling? Any thoughts for the day?',
              ),
            ],
          ),
          TemplateSection(
            id: 'afternoon_section',
            title: 'Afternoon Tasks',
            icon: Icons.wb_cloudy,
            fields: [
              TemplateField(
                id: 'afternoon_tasks',
                label: 'Afternoon To-Do List',
                type: FieldType.checkboxList,
                options: [
                  'Complete priority task',
                  'Attend meetings',
                  'Respond to messages',
                  'Work on projects',
                  'Take breaks',
                ],
              ),
            ],
          ),
          TemplateSection(
            id: 'evening_section',
            title: 'Evening Reflection',
            icon: Icons.nightlight,
            fields: [
              TemplateField(
                id: 'accomplishments',
                label: 'What did you accomplish today?',
                type: FieldType.multilineText,
                placeholder: 'List your achievements...',
              ),
              TemplateField(
                id: 'gratitude',
                label: 'What are you grateful for?',
                type: FieldType.multilineText,
                placeholder: 'Three things you\'re grateful for...',
              ),
              TemplateField(
                id: 'tomorrow_prep',
                label: 'Tomorrow\'s Priority',
                type: FieldType.text,
                placeholder: 'What\'s the most important thing for tomorrow?',
              ),
            ],
          ),
        ],
      ),

      // Weekly Planner Template
      TemplateModel(
        id: 'weekly_planner',
        name: 'Weekly Planner',
        description: 'Organize your week with goals and tasks',
        category: 'Weekly',
        icon: Icons.view_week,
        colors: [const Color(0xFF10B981), const Color(0xFF34D399)],
        sections: [
          TemplateSection(
            id: 'week_overview',
            title: 'Week Overview',
            icon: Icons.calendar_view_week,
            fields: [
              TemplateField(
                id: 'week_start',
                label: 'Week Starting',
                type: FieldType.dateTime,
                required: true,
              ),
              TemplateField(
                id: 'weekly_goals',
                label: 'Goals for This Week',
                type: FieldType.checkboxList,
                options: [
                  'Complete project milestone',
                  'Exercise 3 times',
                  'Read for 30 minutes daily',
                  'Connect with friends/family',
                  'Learn something new',
                ],
              ),
              TemplateField(
                id: 'weekly_focus',
                label: 'Main Focus Area',
                type: FieldType.dropdown,
                options: [
                  'Work/Career',
                  'Health/Fitness',
                  'Relationships',
                  'Learning',
                  'Personal Projects',
                ],
              ),
            ],
          ),
          TemplateSection(
            id: 'week_reflection',
            title: 'Weekly Reflection',
            icon: Icons.psychology,
            fields: [
              TemplateField(
                id: 'progress_rating',
                label: 'How was your week? (1-10)',
                type: FieldType.rating,
                maxValue: 10,
                minValue: 1,
              ),
              TemplateField(
                id: 'week_highlights',
                label: 'Week Highlights',
                type: FieldType.multilineText,
                placeholder: 'What were the best moments of your week?',
              ),
              TemplateField(
                id: 'improvements',
                label: 'Areas for Improvement',
                type: FieldType.multilineText,
                placeholder: 'What could you do better next week?',
              ),
            ],
          ),
        ],
      ),

      // Study Planner Template
      TemplateModel(
        id: 'study_planner',
        name: 'Study Planner',
        description: 'Organize study sessions and track progress',
        category: 'Study',
        icon: Icons.school,
        colors: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
        sections: [
          TemplateSection(
            id: 'study_session',
            title: 'Study Session Info',
            icon: Icons.schedule,
            fields: [
              TemplateField(
                id: 'study_date',
                label: 'Study Date',
                type: FieldType.dateTime,
                required: true,
              ),
              TemplateField(
                id: 'subject',
                label: 'Subject',
                type: FieldType.dropdown,
                options: [
                  'Mathematics',
                  'Science',
                  'History',
                  'Literature',
                  'Languages',
                  'Computer Science',
                  'Other',
                ],
                required: true,
              ),
              TemplateField(
                id: 'topic',
                label: 'Topic/Chapter',
                type: FieldType.text,
                placeholder: 'What specific topic are you studying?',
                required: true,
              ),
              TemplateField(
                id: 'study_duration',
                label: 'Planned Study Duration (minutes)',
                type: FieldType.number,
                placeholder: '60',
              ),
            ],
          ),
          TemplateSection(
            id: 'study_content',
            title: 'Study Content',
            icon: Icons.book,
            fields: [
              TemplateField(
                id: 'learning_objectives',
                label: 'Learning Objectives',
                type: FieldType.checkboxList,
                options: [
                  'Understand key concepts',
                  'Complete practice problems',
                  'Review previous material',
                  'Prepare for test/exam',
                  'Take notes',
                ],
              ),
              TemplateField(
                id: 'study_notes',
                label: 'Study Notes',
                type: FieldType.multilineText,
                placeholder: 'Key points, formulas, important concepts...',
              ),
            ],
          ),
          TemplateSection(
            id: 'progress_tracking',
            title: 'Progress & Completion',
            icon: Icons.trending_up,
            fields: [
              TemplateField(
                id: 'completion_status',
                label: 'Completion Status',
                type: FieldType.dropdown,
                options: [
                  'Not Started',
                  'In Progress',
                  'Completed',
                  'Needs Review',
                ],
              ),
              TemplateField(
                id: 'understanding_level',
                label: 'Understanding Level (1-10)',
                type: FieldType.rating,
                maxValue: 10,
                minValue: 1,
              ),
            ],
          ),
        ],
      ),

      // Meal Planner Template
      TemplateModel(
        id: 'meal_planner',
        name: 'Meal Planner',
        description: 'Plan daily meals and track nutrition',
        category: 'Health',
        icon: Icons.restaurant,
        colors: [const Color(0xFFF97316), const Color(0xFFFB923C)],
        sections: [
          TemplateSection(
            id: 'meal_date',
            title: 'Meal Planning Date',
            icon: Icons.calendar_today,
            fields: [
              TemplateField(
                id: 'meal_date',
                label: 'Date',
                type: FieldType.dateTime,
                required: true,
              ),
            ],
          ),
          TemplateSection(
            id: 'breakfast_section',
            title: 'Breakfast',
            icon: Icons.free_breakfast,
            fields: [
              TemplateField(
                id: 'breakfast_meal',
                label: 'Breakfast Meal',
                type: FieldType.text,
                placeholder: 'What are you having for breakfast?',
              ),
              TemplateField(
                id: 'breakfast_calories',
                label: 'Estimated Calories',
                type: FieldType.number,
                placeholder: '400',
              ),
              TemplateField(
                id: 'breakfast_photo',
                label: 'Food Photo',
                type: FieldType.imageUpload,
              ),
            ],
          ),
          TemplateSection(
            id: 'lunch_section',
            title: 'Lunch',
            icon: Icons.lunch_dining,
            fields: [
              TemplateField(
                id: 'lunch_meal',
                label: 'Lunch Meal',
                type: FieldType.text,
                placeholder: 'What are you having for lunch?',
              ),
              TemplateField(
                id: 'lunch_calories',
                label: 'Estimated Calories',
                type: FieldType.number,
                placeholder: '600',
              ),
            ],
          ),
          TemplateSection(
            id: 'dinner_section',
            title: 'Dinner',
            icon: Icons.dinner_dining,
            fields: [
              TemplateField(
                id: 'dinner_meal',
                label: 'Dinner Meal',
                type: FieldType.text,
                placeholder: 'What are you having for dinner?',
              ),
              TemplateField(
                id: 'dinner_calories',
                label: 'Estimated Calories',
                type: FieldType.number,
                placeholder: '700',
              ),
            ],
          ),
        ],
      ),

      // Mood Tracker Template
      TemplateModel(
        id: 'mood_tracker',
        name: 'Mood Tracker',
        description: 'Track daily moods and mental wellbeing',
        category: 'Journal',
        icon: Icons.sentiment_satisfied_alt,
        colors: [const Color(0xFFEC4899), const Color(0xFFF472B6)],
        sections: [
          TemplateSection(
            id: 'mood_date',
            title: 'Date & Time',
            icon: Icons.access_time,
            fields: [
              TemplateField(
                id: 'mood_date',
                label: 'Date',
                type: FieldType.dateTime,
                required: true,
              ),
              TemplateField(
                id: 'mood_time',
                label: 'Time of Day',
                type: FieldType.dropdown,
                options: ['Morning', 'Afternoon', 'Evening', 'Night'],
              ),
            ],
          ),
          TemplateSection(
            id: 'mood_assessment',
            title: 'Mood Assessment',
            icon: Icons.psychology,
            fields: [
              TemplateField(
                id: 'primary_mood',
                label: 'Primary Mood',
                type: FieldType.moodSelector,
                options: [
                  '😊 Happy',
                  '😢 Sad',
                  '😠 Angry',
                  '😰 Anxious',
                  '😴 Tired',
                  '😌 Calm',
                ],
              ),
              TemplateField(
                id: 'mood_intensity',
                label: 'Mood Intensity (1-10)',
                type: FieldType.rating,
                maxValue: 10,
                minValue: 1,
              ),
            ],
          ),
          TemplateSection(
            id: 'mood_reflection',
            title: 'Reflection & Notes',
            icon: Icons.edit_note,
            fields: [
              TemplateField(
                id: 'mood_description',
                label: 'Describe your feelings',
                type: FieldType.multilineText,
                placeholder: 'How are you feeling today? What\'s on your mind?',
              ),
              TemplateField(
                id: 'gratitude_note',
                label: 'Something you\'re grateful for',
                type: FieldType.text,
                placeholder: 'One thing that made you smile today...',
              ),
            ],
          ),
        ],
      ),

      // Fitness Planner Template
      TemplateModel(
        id: 'fitness_planner',
        name: 'Fitness Planner',
        description: 'Track workouts and fitness progress',
        category: 'Fitness',
        icon: Icons.fitness_center,
        colors: [const Color(0xFF06B6D4), const Color(0xFF22D3EE)],
        sections: [
          TemplateSection(
            id: 'workout_info',
            title: 'Workout Information',
            icon: Icons.schedule,
            fields: [
              TemplateField(
                id: 'workout_date',
                label: 'Workout Date',
                type: FieldType.dateTime,
                required: true,
              ),
              TemplateField(
                id: 'workout_type',
                label: 'Workout Type',
                type: FieldType.dropdown,
                options: [
                  'Cardio',
                  'Strength Training',
                  'Yoga',
                  'HIIT',
                  'Swimming',
                  'Running',
                ],
                required: true,
              ),
              TemplateField(
                id: 'workout_duration',
                label: 'Duration (minutes)',
                type: FieldType.number,
                placeholder: '45',
              ),
            ],
          ),
          TemplateSection(
            id: 'exercise_details',
            title: 'Exercise Details',
            icon: Icons.sports_gymnastics,
            fields: [
              TemplateField(
                id: 'exercises_performed',
                label: 'Exercises Performed',
                type: FieldType.checkboxList,
                options: [
                  'Push-ups',
                  'Squats',
                  'Lunges',
                  'Planks',
                  'Burpees',
                  'Pull-ups',
                ],
              ),
              TemplateField(
                id: 'workout_notes',
                label: 'Workout Notes',
                type: FieldType.multilineText,
                placeholder: 'How did the workout feel? Any achievements?',
              ),
            ],
          ),
        ],
      ),

      // Finance Tracker Template
      TemplateModel(
        id: 'finance_tracker',
        name: 'Finance Tracker',
        description: 'Track income, expenses and budget',
        category: 'Finance',
        icon: Icons.attach_money,
        colors: [const Color(0xFF10B981), const Color(0xFF059669)],
        sections: [
          TemplateSection(
            id: 'transaction_info',
            title: 'Transaction Information',
            icon: Icons.receipt,
            fields: [
              TemplateField(
                id: 'transaction_date',
                label: 'Date',
                type: FieldType.dateTime,
                required: true,
              ),
              TemplateField(
                id: 'transaction_type',
                label: 'Transaction Type',
                type: FieldType.dropdown,
                options: ['Income', 'Expense'],
                required: true,
              ),
              TemplateField(
                id: 'amount',
                label: 'Amount',
                type: FieldType.number,
                placeholder: '0.00',
                required: true,
              ),
            ],
          ),
          TemplateSection(
            id: 'categorization',
            title: 'Category & Details',
            icon: Icons.category,
            fields: [
              TemplateField(
                id: 'expense_category',
                label: 'Category',
                type: FieldType.dropdown,
                options: [
                  'Food & Dining',
                  'Transportation',
                  'Shopping',
                  'Entertainment',
                  'Bills & Utilities',
                  'Healthcare',
                  'Other',
                ],
              ),
              TemplateField(
                id: 'description',
                label: 'Description',
                type: FieldType.text,
                placeholder: 'What was this transaction for?',
              ),
            ],
          ),
        ],
      ),

      // Travel Planner Template
      TemplateModel(
        id: 'travel_planner',
        name: 'Travel Planner',
        description: 'Plan trips and track travel experiences',
        category: 'Travel',
        icon: Icons.flight,
        colors: [const Color(0xFF0EA5E9), const Color(0xFF38BDF8)],
        sections: [
          TemplateSection(
            id: 'trip_details',
            title: 'Trip Information',
            icon: Icons.info,
            fields: [
              TemplateField(
                id: 'destination',
                label: 'Destination',
                type: FieldType.text,
                placeholder: 'Where are you going?',
                required: true,
              ),
              TemplateField(
                id: 'departure_date',
                label: 'Departure Date',
                type: FieldType.dateTime,
                required: true,
              ),
              TemplateField(
                id: 'return_date',
                label: 'Return Date',
                type: FieldType.dateTime,
              ),
            ],
          ),
          TemplateSection(
            id: 'packing_list',
            title: 'Packing Checklist',
            icon: Icons.luggage,
            fields: [
              TemplateField(
                id: 'clothing_items',
                label: 'Clothing & Accessories',
                type: FieldType.checkboxList,
                options: [
                  'Shirts/Tops',
                  'Pants/Bottoms',
                  'Underwear',
                  'Shoes',
                  'Jacket/Coat',
                ],
              ),
              TemplateField(
                id: 'essentials',
                label: 'Travel Essentials',
                type: FieldType.checkboxList,
                options: [
                  'Passport/ID',
                  'Tickets',
                  'Phone charger',
                  'Camera',
                  'Medications',
                ],
              ),
            ],
          ),
        ],
      ),

      // Affirmation Journal Template
      TemplateModel(
        id: 'affirmation_journal',
        name: 'Affirmation Journal',
        description: 'Daily affirmations and positive thoughts',
        category: 'Journal',
        icon: Icons.self_improvement,
        colors: [const Color(0xFFEF4444), const Color(0xFFF87171)],
        sections: [
          TemplateSection(
            id: 'affirmation_date',
            title: 'Date & Intention',
            icon: Icons.calendar_today,
            fields: [
              TemplateField(
                id: 'affirmation_date',
                label: 'Date',
                type: FieldType.dateTime,
                required: true,
              ),
              TemplateField(
                id: 'daily_intention',
                label: 'Today\'s Intention',
                type: FieldType.text,
                placeholder: 'What do you want to focus on today?',
              ),
            ],
          ),
          TemplateSection(
            id: 'affirmations',
            title: 'Daily Affirmations',
            icon: Icons.favorite,
            fields: [
              TemplateField(
                id: 'morning_affirmation',
                label: 'Morning Affirmation',
                type: FieldType.multilineText,
                placeholder: 'I am strong, capable, and ready for today...',
              ),
              TemplateField(
                id: 'personal_affirmations',
                label: 'Personal Affirmations',
                type: FieldType.checkboxList,
                options: [
                  'I am worthy of love and respect',
                  'I believe in my abilities',
                  'I am grateful for what I have',
                  'I choose happiness and positivity',
                  'I am growing every day',
                ],
              ),
            ],
          ),
        ],
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

  static List<String> getAllCategories() {
    return getAllTemplates()
        .map((template) => template.category)
        .toSet()
        .toList()
      ..sort();
  }
}
