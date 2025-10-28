import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../database/database_helper.dart';
import '../services/alarm_service.dart';

class NotificationProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final AlarmService _alarmService = AlarmService.instance;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  // Get notifications for a specific date
  List<NotificationModel> getNotificationsForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _notifications.where((notification) {
      final notificationDate = DateTime(
        notification.date.year,
        notification.date.month,
        notification.date.day,
      );
      return notificationDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  // Check if a date has notifications
  bool hasNotificationsForDate(DateTime date) {
    return getNotificationsForDate(date).isNotEmpty;
  }

  // Load all notifications
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check database structure first
      await _databaseHelper.checkDatabaseStructure();
      _notifications = await _databaseHelper.getAllNotifications();
      debugPrint('Loaded ${_notifications.length} notifications');
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new notification
  Future<bool> createNotification(NotificationModel notification) async {
    try {
      debugPrint('Creating notification: ${notification.title}');
      debugPrint('Scheduled for: ${notification.scheduledDateTime}');

      // Save to database
      final id = await _databaseHelper.insertNotification(notification);
      debugPrint('Notification saved to database with ID: $id');

      // Schedule the notification
      await _scheduleNotification(notification);
      debugPrint('Notification scheduled successfully');

      // Add to local list
      _notifications.add(notification);
      _notifications.sort(
        (a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime),
      );

      notifyListeners();
      debugPrint('Notification created successfully');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error creating notification: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  // Update an existing notification
  Future<bool> updateNotification(NotificationModel notification) async {
    try {
      // Update in database
      await _databaseHelper.updateNotification(notification);

      // Cancel old alarm and schedule new one
      await _alarmService.cancelNotification(
        notification.notificationId,
      );
      await _scheduleNotification(notification);

      // Update in local list
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification;
        _notifications.sort(
          (a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime),
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating notification: $e');
      return false;
    }
  }

  // Delete a notification
  Future<bool> deleteNotification(String id) async {
    try {
      final notification = _notifications.firstWhere((n) => n.id == id);

      // Cancel the scheduled alarm
      await _alarmService.cancelNotification(
        notification.notificationId,
      );

      // Delete from database
      await _databaseHelper.deleteNotification(id);

      // Remove from local list
      _notifications.removeWhere((n) => n.id == id);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return false;
    }
  }

  // Mark notification as completed
  Future<bool> markAsCompleted(String id) async {
    try {
      await _databaseHelper.markNotificationAsCompleted(id);

      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          isCompleted: true,
          updatedAt: DateTime.now(),
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error marking notification as completed: $e');
      return false;
    }
  }

  // Schedule a notification with the notification service
  Future<void> _scheduleNotification(NotificationModel notification) async {
    if (notification.isCompleted) return;

    final scheduledTime = notification.scheduledDateTime;

    // Only schedule if the time is in the future
    if (scheduledTime.isAfter(DateTime.now())) {
      await _alarmService.scheduleAlarmNotification(
        id: notification.notificationId,
        title: notification.title,
        body: notification.description ?? 'Reminder: ${notification.title}',
        scheduledDate: scheduledTime,
      );
    }
  }

  // Reschedule all pending notifications (useful after app restart)
  Future<void> rescheduleAllNotifications() async {
    try {
      final pendingNotifications = await _databaseHelper
          .getPendingNotifications();

      for (final notification in pendingNotifications) {
        await _scheduleNotification(notification);
      }
    } catch (e) {
      debugPrint('Error rescheduling notifications: $e');
    }
  }

  // Get pending notifications count
  int get pendingNotificationsCount {
    final now = DateTime.now();
    return _notifications
        .where((n) => !n.isCompleted && n.scheduledDateTime.isAfter(now))
        .length;
  }

  // Get overdue notifications count
  int get overdueNotificationsCount {
    final now = DateTime.now();
    return _notifications
        .where((n) => !n.isCompleted && n.scheduledDateTime.isBefore(now))
        .length;
  }

  // Get today's notifications
  List<NotificationModel> get todaysNotifications {
    final today = DateTime.now();
    return getNotificationsForDate(today);
  }

  // Get upcoming notifications (next 7 days)
  List<NotificationModel> get upcomingNotifications {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return _notifications
        .where(
          (n) =>
              !n.isCompleted &&
              n.scheduledDateTime.isAfter(now) &&
              n.scheduledDateTime.isBefore(nextWeek),
        )
        .toList();
  }
}
