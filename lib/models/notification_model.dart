class NotificationModel {
  final String id;
  final String title;
  final DateTime date;
  final DateTime time;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Get the full DateTime for scheduling
  DateTime get scheduledDateTime {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  // Get unique notification ID for the notification service
  int get notificationId {
    return id.hashCode.abs();
  }

  // Create from database map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      time: DateTime.parse(map['time'] as String),
      description: map['description'] as String?,
      isCompleted: (map['isCompleted'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': DateTime(date.year, date.month, date.day).toIso8601String(),
      'time': time.toIso8601String(),
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? title,
    DateTime? date,
    DateTime? time,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Create a new notification
  factory NotificationModel.create({
    required String title,
    required DateTime date,
    required DateTime time,
    String? description,
  }) {
    final now = DateTime.now();
    return NotificationModel(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      date: date,
      time: time,
      description: description,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, date: $date, time: $time, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
