import 'package:flutter/material.dart';

class TemplateModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final IconData icon;
  final List<Color> colors;
  final Map<String, dynamic>? customData;

  TemplateModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.colors,
    this.customData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'iconCodePoint': icon.codePoint,
      'colors': colors.map((c) => c.value).toList().join(','),
      'customData': customData?.toString(),
    };
  }

  factory TemplateModel.fromMap(Map<String, dynamic> map) {
    final colorValues = (map['colors'] as String).split(',');
    final colors = colorValues.map((v) => Color(int.parse(v))).toList();

    return TemplateModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      icon: IconData(map['iconCodePoint'], fontFamily: 'MaterialIcons'),
      colors: colors,
      customData: map['customData'] != null ? {} : null,
    );
  }
}
