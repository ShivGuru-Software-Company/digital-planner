import 'package:flutter/material.dart';

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
  final List<String>? options; // For dropdown, checkbox lists
  final int? maxValue; // For rating, number fields
  final int? minValue;
  final Map<String, dynamic>? config; // Additional field configuration

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
            ? IconData(sectionMap['iconCodePoint'], fontFamily: 'MaterialIcons')
            : null,
        fields: fields,
      );
    }).toList();

    return TemplateModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      icon: IconData(map['iconCodePoint'], fontFamily: 'MaterialIcons'),
      colors: colors,
      sections: sections,
      customData: map['customData'] != null ? {} : null,
    );
  }
}
