import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../database/database_helper.dart';
import '../services/alarm_service.dart';

class AlarmProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService.instance;

  List<NotificationModel> _alarms = [];
  bool _isLoading = false;

  List<NotificationModel> get alarms => _alarms;
  bool get isLoading => _isLoading;

  // Get alarms for a specific date
  List<NotificationModel> getAlarmsForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _alarms.where((alarm) {
      final alarmDate = DateTime(
        alarm.date.year,
        alarm.date.month,
        alarm.date.day,
      );
      return alarmDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  // Check if a date has alarms
  bool hasAlarmsForDate(DateTime date) {
    return getAlarmsForDate(date).isNotEmpty;
  }

  // Load all alarms
  Future<void> loadAlarms() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseHelper.checkDatabaseStructure();
      _alarms = await _databaseHelper.getAllNotifications();
      debugPrint('Loaded ${_alarms.length} alarms');
    } catch (e) {
      debugPrint('Error loading alarms: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new alarm
  Future<bool> createAlarm(NotificationModel alarm) async {
    try {
      debugPrint('Creating alarm: ${alarm.title}');
      debugPrint('Scheduled for: ${alarm.scheduledDateTime}');

      // Save to database
      await _databaseHelper.insertNotification(alarm);
      debugPrint('Alarm saved to database');

      // Schedule the notification
      await _scheduleNotification(alarm);
      debugPrint('Notification scheduled successfully');

      // Add to local list
      _alarms.add(alarm);
      _alarms.sort(
        (a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime),
      );

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating alarm: $e');
      return false;
    }
  }

  // Update an existing alarm
  Future<bool> updateAlarm(NotificationModel alarm) async {
    try {
      // Update in database
      await _databaseHelper.updateNotification(alarm);

      // Cancel old notification and schedule new one
      await _notificationService.cancelNotification(alarm.notificationId);
      await _scheduleNotification(alarm);

      // Update in local list
      final index = _alarms.indexWhere((a) => a.id == alarm.id);
      if (index != -1) {
        _alarms[index] = alarm;
        _alarms.sort(
          (a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime),
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating alarm: $e');
      return false;
    }
  }

  // Delete an alarm
  Future<bool> deleteAlarm(String id) async {
    try {
      final alarm = _alarms.firstWhere((a) => a.id == id);

      // Cancel the scheduled notification
      await _notificationService.cancelNotification(alarm.notificationId);

      // Delete from database
      await _databaseHelper.deleteNotification(id);

      // Remove from local list
      _alarms.removeWhere((a) => a.id == id);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting alarm: $e');
      return false;
    }
  }

  // Mark alarm as completed
  Future<bool> markAsCompleted(String id) async {
    try {
      await _databaseHelper.markNotificationAsCompleted(id);

      final index = _alarms.indexWhere((a) => a.id == id);
      if (index != -1) {
        _alarms[index] = _alarms[index].copyWith(
          isCompleted: true,
          updatedAt: DateTime.now(),
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error marking alarm as completed: $e');
      return false;
    }
  }

  // Schedule a notification
  Future<void> _scheduleNotification(NotificationModel alarm) async {
    if (alarm.isCompleted) return;

    final scheduledTime = alarm.scheduledDateTime;

    // Only schedule if the time is in the future
    if (scheduledTime.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: alarm.notificationId,
        title: alarm.title,
        body: alarm.description ?? 'Reminder: ${alarm.title}',
        scheduledDate: scheduledTime,
      );
    }
  }

  // Reschedule all pending notifications (useful after app restart)
  Future<void> rescheduleAllAlarms() async {
    try {
      final pendingAlarms = await _databaseHelper.getPendingNotifications();

      for (final alarm in pendingAlarms) {
        await _scheduleNotification(alarm);
      }
    } catch (e) {
      debugPrint('Error rescheduling notifications: $e');
    }
  }

  // Get pending alarms count
  int get pendingAlarmsCount {
    final now = DateTime.now();
    return _alarms
        .where((a) => !a.isCompleted && a.scheduledDateTime.isAfter(now))
        .length;
  }

  // Get overdue alarms count
  int get overdueAlarmsCount {
    final now = DateTime.now();
    return _alarms
        .where((a) => !a.isCompleted && a.scheduledDateTime.isBefore(now))
        .length;
  }

  // Get today's alarms
  List<NotificationModel> get todaysAlarms {
    final today = DateTime.now();
    return getAlarmsForDate(today);
  }

  // Get upcoming alarms (next 7 days)
  List<NotificationModel> get upcomingAlarms {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return _alarms
        .where(
          (a) =>
              !a.isCompleted &&
              a.scheduledDateTime.isAfter(now) &&
              a.scheduledDateTime.isBefore(nextWeek),
        )
        .toList();
  }
}
