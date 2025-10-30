import 'package:flutter/material.dart';

enum TemplateType { daily, weekly, monthly, yearly, meal, finance, mood }

enum TemplateDesign { minimal, colorful, elegant }

class PlannerTemplate {
  final String id;
  final String name;
  final String description;
  final TemplateType type;
  final TemplateDesign design;
  final IconData icon;
  final List<Color> colors;
  final String previewImage;

  PlannerTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.design,
    required this.icon,
    required this.colors,
    required this.previewImage,
  });
}

class TemplateData {
  final String id;
  final DateTime date;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime updatedAt;

  TemplateData({
    required this.id,
    required this.date,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TemplateData.fromMap(Map<String, dynamic> map) {
    return TemplateData(
      id: map['id'],
      date: DateTime.parse(map['date']),
      data: Map<String, dynamic>.from(map['data']),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

// Legacy models for backward compatibility
enum FieldType {
  text,
  multilineText,
  checkbox,
  checkboxList,
  dropdown,
  dateTime,
  time,
  number,
  rating,
  moodSelector,
  imageUpload,
  drawing,
  timer,
  progressBar,
  colorPicker,
  tags,
}

class TemplateField {
  final String id;
  final String label;
  final FieldType type;
  final bool required;
  final String? placeholder;
  final List<String>? options;
  final int? maxValue;
  final int? minValue;
  final Map<String, dynamic>? config;

  TemplateField({
    required this.id,
    required this.label,
    required this.type,
    this.required = false,
    this.placeholder,
    this.options,
    this.maxValue,
    this.minValue,
    this.config,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'type': type.name,
      'required': required,
      'placeholder': placeholder,
      'options': options?.join(','),
      'maxValue': maxValue,
      'minValue': minValue,
      'config': config,
    };
  }

  factory TemplateField.fromMap(Map<String, dynamic> map) {
    return TemplateField(
      id: map['id'],
      label: map['label'],
      type: FieldType.values.firstWhere((e) => e.name == map['type']),
      required: map['required'] ?? false,
      placeholder: map['placeholder'],
      options: map['options']?.split(','),
      maxValue: map['maxValue'],
      minValue: map['minValue'],
      config: map['config'],
    );
  }
}

class TemplateSection {
  final String id;
  final String title;
  final List<TemplateField> fields;
  final String? description;
  final IconData? icon;

  TemplateSection({
    required this.id,
    required this.title,
    required this.fields,
    this.description,
    this.icon,
  });
}

class TemplateModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final IconData icon;
  final List<Color> colors;
  final List<TemplateSection> sections;
  final Map<String, dynamic>? customData;

  TemplateModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.colors,
    required this.sections,
    this.customData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'iconCodePoint': icon.codePoint,
      'colors': colors
          .map((c) => c.red << 16 | c.green << 8 | c.blue)
          .toList()
          .join(','),
      'sections': sections
          .map(
            (s) => {
              'id': s.id,
              'title': s.title,
              'description': s.description,
              'iconCodePoint': s.icon?.codePoint,
              'fields': s.fields.map((f) => f.toMap()).toList(),
            },
          )
          .toList(),
      'customData': customData?.toString(),
    };
  }

  factory TemplateModel.fromMap(Map<String, dynamic> map) {
    final colorValues = (map['colors'] as String).split(',');
    final colors = colorValues.map((v) => Color(int.parse(v))).toList();

    final sectionsData = map['sections'] as List<dynamic>? ?? [];
    final sections = sectionsData.map((sectionMap) {
      final fieldsData = sectionMap['fields'] as List<dynamic>? ?? [];
      final fields = fieldsData
          .map((fieldMap) => TemplateField.fromMap(fieldMap))
          .toList();

      return TemplateSection(
        id: sectionMap['id'],
        title: sectionMap['title'],
        description: sectionMap['description'],
        icon: sectionMap['iconCodePoint'] != null
            ? _createIconData(sectionMap['iconCodePoint'])
            : null,
        fields: fields,
      );
    }).toList();

    return TemplateModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      icon: _createIconData(map['iconCodePoint']),
      colors: colors,
      sections: sections,
      customData: map['customData'] != null ? {} : null,
    );
  }

  static IconData _createIconData(int codePoint) {
    // Map common icon codePoints to const Icons
    switch (codePoint) {
      case 58135:
        return Icons.today; // 0xe2e7
      case 59679:
        return Icons.view_week; // 0xe8df
      case 59681:
        return Icons.calendar_month; // 0xe8e1
      case 59558:
        return Icons.calendar_today; // 0xe8a6
      case 58732:
        return Icons.restaurant; // 0xe56c
      case 59378:
        return Icons.sentiment_satisfied_alt; // 0xe7f2
      case 58894:
        return Icons.school; // 0xe80e
      case 59573:
        return Icons.schedule; // 0xe8b5
      case 57531:
        return Icons.book; // 0xe0bb
      case 59683:
        return Icons.trending_up; // 0xe8e3
      case 57559:
        return Icons.free_breakfast; // 0xe0d7
      case 58340:
        return Icons.lunch_dining; // 0xe3e4
      case 58137:
        return Icons.dinner_dining; // 0xe319
      case 59557:
        return Icons.calendar_view_week; // 0xe8a5
      case 59574:
        return Icons.psychology; // 0xe8b6
      default:
        return Icons.today; // Default fallback
    }
  }
}
