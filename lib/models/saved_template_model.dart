import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SavedTemplateModel {
  final String id;
  final String templateId;
  final String templateName;
  final String templateType;
  final String templateDesign;
  final List<Color> templateColors;
  final IconData templateIcon;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavedTemplateModel({
    required this.id,
    required this.templateId,
    required this.templateName,
    required this.templateType,
    required this.templateDesign,
    required this.templateColors,
    required this.templateIcon,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavedTemplateModel.create({
    required String templateId,
    required String templateName,
    required String templateType,
    required String templateDesign,
    required List<Color> templateColors,
    required IconData templateIcon,
    required Map<String, dynamic> data,
  }) {
    final now = DateTime.now();
    return SavedTemplateModel(
      id: const Uuid().v4(),
      templateId: templateId,
      templateName: templateName,
      templateType: templateType,
      templateDesign: templateDesign,
      templateColors: templateColors,
      templateIcon: templateIcon,
      data: data,
      createdAt: now,
      updatedAt: now,
    );
  }

  SavedTemplateModel copyWith({
    String? id,
    String? templateId,
    String? templateName,
    String? templateType,
    String? templateDesign,
    List<Color>? templateColors,
    IconData? templateIcon,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedTemplateModel(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      templateName: templateName ?? this.templateName,
      templateType: templateType ?? this.templateType,
      templateDesign: templateDesign ?? this.templateDesign,
      templateColors: templateColors ?? this.templateColors,
      templateIcon: templateIcon ?? this.templateIcon,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'template_id': templateId,
      'template_name': templateName,
      'template_type': templateType,
      'template_design': templateDesign,
      'template_colors': jsonEncode(
        templateColors.map((c) => c.value).toList(),
      ),
      'template_icon': templateIcon.codePoint,
      'data': jsonEncode(data),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SavedTemplateModel.fromMap(Map<String, dynamic> map) {
    final colorValues = List<int>.from(jsonDecode(map['template_colors']));
    final colors = colorValues.map((value) => Color(value)).toList();

    return SavedTemplateModel(
      id: map['id'],
      templateId: map['template_id'],
      templateName: map['template_name'],
      templateType: map['template_type'],
      templateDesign: map['template_design'],
      templateColors: colors,
      templateIcon: _createIconData(map['template_icon']),
      data: Map<String, dynamic>.from(jsonDecode(map['data'])),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory SavedTemplateModel.fromJson(String source) =>
      SavedTemplateModel.fromMap(jsonDecode(source));

  @override
  String toString() {
    return 'SavedTemplateModel(id: $id, templateName: $templateName, templateType: $templateType, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SavedTemplateModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
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
