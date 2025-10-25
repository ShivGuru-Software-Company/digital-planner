class EntryModel {
  final String id;
  final String templateId;
  final DateTime date;
  final String title;
  final String content;
  final String? drawingData;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? reminderTime;

  EntryModel({
    required this.id,
    required this.templateId,
    required this.date,
    required this.title,
    required this.content,
    this.drawingData,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
    this.reminderTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'templateId': templateId,
      'date': date.toIso8601String(),
      'title': title,
      'content': content,
      'drawingData': drawingData,
      'images': images.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'reminderTime': reminderTime,
    };
  }

  factory EntryModel.fromMap(Map<String, dynamic> map) {
    final imageString = map['images'] as String? ?? '';
    final images = imageString.isNotEmpty ? imageString.split(',') : <String>[];

    return EntryModel(
      id: map['id'],
      templateId: map['templateId'],
      date: DateTime.parse(map['date']),
      title: map['title'],
      content: map['content'],
      drawingData: map['drawingData'],
      images: images,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      reminderTime: map['reminderTime'],
    );
  }

  EntryModel copyWith({
    String? id,
    String? templateId,
    DateTime? date,
    String? title,
    String? content,
    String? drawingData,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? reminderTime,
  }) {
    return EntryModel(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      drawingData: drawingData ?? this.drawingData,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
