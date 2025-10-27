import 'package:flutter/material.dart';

/// Utility class to help collect template data for PDF export
class TemplateDataCollector {
  /// Collects data from text controllers
  static Map<String, String> collectTextControllers(
    Map<String, TextEditingController> controllers,
  ) {
    final data = <String, String>{};
    controllers.forEach((key, controller) {
      data[key] = controller.text;
    });
    return data;
  }

  /// Collects data from a list of text controllers
  static List<String> collectTextControllerList(
    List<TextEditingController> controllers,
  ) {
    return controllers.map((controller) => controller.text).toList();
  }

  /// Collects checkbox states
  static Map<String, bool> collectCheckboxStates(Map<String, bool> checkboxes) {
    return Map.from(checkboxes);
  }

  /// Collects data from a list of checkboxes
  static List<bool> collectCheckboxList(List<bool> checkboxes) {
    return List.from(checkboxes);
  }

  /// Combines text and checkbox data for todo/task lists
  static List<Map<String, dynamic>> collectTodoList(
    List<TextEditingController> textControllers,
    List<bool> checkboxes,
  ) {
    final todos = <Map<String, dynamic>>[];
    for (int i = 0; i < textControllers.length; i++) {
      if (textControllers[i].text.isNotEmpty) {
        todos.add({
          'text': textControllers[i].text,
          'completed': i < checkboxes.length ? checkboxes[i] : false,
        });
      }
    }
    return todos;
  }

  /// Collects schedule data
  static Map<String, String> collectScheduleData(
    Map<String, TextEditingController> scheduleControllers,
  ) {
    final schedule = <String, String>{};
    scheduleControllers.forEach((time, controller) {
      if (controller.text.isNotEmpty) {
        schedule[time] = controller.text;
      }
    });
    return schedule;
  }

  /// Collects meal planning data
  static Map<String, Map<String, String>> collectMealData(
    Map<String, Map<String, TextEditingController>> mealControllers,
  ) {
    final meals = <String, Map<String, String>>{};
    mealControllers.forEach((mealType, controllers) {
      final mealData = <String, String>{};
      controllers.forEach((field, controller) {
        if (controller.text.isNotEmpty) {
          mealData[field] = controller.text;
        }
      });
      if (mealData.isNotEmpty) {
        meals[mealType] = mealData;
      }
    });
    return meals;
  }

  /// Collects mood tracking data
  static Map<String, dynamic> collectMoodData({
    String? selectedMood,
    List<String>? selectedEmotions,
    List<String>? selectedActivities,
    String? reflection,
    Map<String, dynamic>? additionalData,
  }) {
    final data = <String, dynamic>{};

    if (selectedMood != null && selectedMood.isNotEmpty) {
      data['mood'] = selectedMood;
    }

    if (selectedEmotions != null && selectedEmotions.isNotEmpty) {
      data['emotions'] = selectedEmotions;
    }

    if (selectedActivities != null && selectedActivities.isNotEmpty) {
      data['activities'] = selectedActivities;
    }

    if (reflection != null && reflection.isNotEmpty) {
      data['reflection'] = reflection;
    }

    if (additionalData != null) {
      data.addAll(additionalData);
    }

    return data;
  }

  /// Collects weekly planning data
  static Map<String, dynamic> collectWeeklyData({
    DateTime? weekStart,
    DateTime? weekEnd,
    List<String>? goals,
    Map<String, String>? dailyEntries,
    Map<String, dynamic>? additionalData,
  }) {
    final data = <String, dynamic>{};

    if (weekStart != null) {
      data['weekStart'] = weekStart.toIso8601String();
    }

    if (weekEnd != null) {
      data['weekEnd'] = weekEnd.toIso8601String();
    }

    if (goals != null && goals.isNotEmpty) {
      data['goals'] = goals;
    }

    if (dailyEntries != null && dailyEntries.isNotEmpty) {
      data['days'] = dailyEntries;
    }

    if (additionalData != null) {
      data.addAll(additionalData);
    }

    return data;
  }

  /// Collects monthly planning data
  static Map<String, dynamic> collectMonthlyData({
    int? month,
    int? year,
    List<String>? goals,
    List<String>? importantDates,
    Map<String, dynamic>? additionalData,
  }) {
    final data = <String, dynamic>{};

    if (month != null) {
      data['month'] = month;
    }

    if (year != null) {
      data['year'] = year;
    }

    if (goals != null && goals.isNotEmpty) {
      data['goals'] = goals;
    }

    if (importantDates != null && importantDates.isNotEmpty) {
      data['importantDates'] = importantDates;
    }

    if (additionalData != null) {
      data.addAll(additionalData);
    }

    return data;
  }

  /// Collects yearly planning data
  static Map<String, dynamic> collectYearlyData({
    int? year,
    List<String>? goals,
    Map<String, String>? monthlyEntries,
    Map<String, dynamic>? additionalData,
  }) {
    final data = <String, dynamic>{};

    if (year != null) {
      data['year'] = year;
    }

    if (goals != null && goals.isNotEmpty) {
      data['goals'] = goals;
    }

    if (monthlyEntries != null && monthlyEntries.isNotEmpty) {
      data['months'] = monthlyEntries;
    }

    if (additionalData != null) {
      data.addAll(additionalData);
    }

    return data;
  }

  /// Generic method to collect all template data
  static Map<String, dynamic> collectAllData({
    required String templateType,
    required DateTime date,
    Map<String, TextEditingController>? textControllers,
    List<TextEditingController>? textControllerList,
    Map<String, bool>? checkboxes,
    List<bool>? checkboxList,
    Map<String, dynamic>? customData,
  }) {
    final data = <String, dynamic>{
      'templateType': templateType,
      'date': date.toIso8601String(),
    };

    if (textControllers != null) {
      data.addAll(collectTextControllers(textControllers));
    }

    if (textControllerList != null) {
      data['textList'] = collectTextControllerList(textControllerList);
    }

    if (checkboxes != null) {
      data.addAll(collectCheckboxStates(checkboxes));
    }

    if (checkboxList != null) {
      data['checkboxList'] = collectCheckboxList(checkboxList);
    }

    if (customData != null) {
      data.addAll(customData);
    }

    return data;
  }

  /// Validates that required fields are filled
  static bool validateRequiredFields(
    Map<String, dynamic> data,
    List<String> requiredFields,
  ) {
    for (final field in requiredFields) {
      if (!data.containsKey(field) ||
          data[field] == null ||
          (data[field] is String && (data[field] as String).isEmpty) ||
          (data[field] is List && (data[field] as List).isEmpty)) {
        return false;
      }
    }
    return true;
  }

  /// Gets a user-friendly error message for missing required fields
  static String getValidationErrorMessage(
    Map<String, dynamic> data,
    List<String> requiredFields,
  ) {
    final missingFields = <String>[];

    for (final field in requiredFields) {
      if (!data.containsKey(field) ||
          data[field] == null ||
          (data[field] is String && (data[field] as String).isEmpty) ||
          (data[field] is List && (data[field] as List).isEmpty)) {
        missingFields.add(field);
      }
    }

    if (missingFields.isEmpty) {
      return '';
    }

    if (missingFields.length == 1) {
      return 'Please fill in the ${missingFields.first} field.';
    }

    return 'Please fill in the following fields: ${missingFields.join(', ')}.';
  }
}
