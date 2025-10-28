import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/planner_provider.dart';
import '../providers/notification_provider.dart';
import '../models/entry_model.dart';
import '../models/notification_model.dart';
import '../widgets/glass_card.dart';
import '../widgets/create_notification_dialog.dart';
import 'entry_editor_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    // Load notifications when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FA), Color(0xFFE0E7FF)],
          ),
        ),
        child: Column(
          children: [
            _buildCalendar(),
            Expanded(child: _buildContentList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateNotificationDialog(),
        backgroundColor: const Color(0xFF6366F1),
        tooltip: 'Create Alarm',
        child: const Icon(Icons.alarm_add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GlassCard(
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            Provider.of<PlannerProvider>(
              context,
              listen: false,
            ).setSelectedDate(selectedDay);
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: Color(0xFFEC4899),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
          ),
          eventLoader: (day) {
            final plannerProvider = Provider.of<PlannerProvider>(
              context,
              listen: false,
            );
            final notificationProvider = Provider.of<NotificationProvider>(
              context,
              listen: false,
            );

            final entries = plannerProvider.getEntriesForDate(day);
            final notifications = notificationProvider.getNotificationsForDate(
              day,
            );

            // Combine entries and notifications for event markers
            return [...entries, ...notifications];
          },
        ),
      ),
    );
  }

  Widget _buildContentList() {
    return Consumer2<PlannerProvider, NotificationProvider>(
      builder: (context, plannerProvider, notificationProvider, child) {
        final entries = plannerProvider.getEntriesForDate(_selectedDay);
        final notifications = notificationProvider.getNotificationsForDate(
          _selectedDay,
        );

        if (entries.isEmpty && notifications.isEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Calendar View',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDay),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No entries or notifications for this date',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap the + button to create a notification',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: entries.length + notifications.length,
          itemBuilder: (context, index) {
            if (index < entries.length) {
              return _buildEntryCard(context, entries[index]);
            } else {
              final notificationIndex = index - entries.length;
              return _buildNotificationCard(
                context,
                notifications[notificationIndex],
              );
            }
          },
        );
      },
    );
  }

  Widget _buildEntryCard(BuildContext context, EntryModel entry) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EntryEditorScreen(entry: entry)),
        );
      },
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  if (entry.reminderTime != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            size: 14,
                            color: Color(0xFFEC4899),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Reminder',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFEC4899),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              if (entry.images.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: entry.images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: const Icon(Icons.image),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
  ) {
    final isOverdue =
        notification.scheduledDateTime.isBefore(DateTime.now()) &&
        !notification.isCompleted;
    final isCompleted = notification.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _showNotificationOptions(notification),
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green.withOpacity(0.1)
                            : isOverdue
                            ? Colors.red.withOpacity(0.1)
                            : const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.notifications_active,
                        color: isCompleted
                            ? Colors.green
                            : isOverdue
                            ? Colors.red
                            : const Color(0xFF6366F1),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                TimeOfDay.fromDateTime(
                                  notification.time,
                                ).format(context),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (isOverdue && !isCompleted) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Overdue',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                              if (isCompleted) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Completed',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) =>
                          _handleNotificationAction(value, notification),
                      itemBuilder: (context) => [
                        if (!notification.isCompleted)
                          const PopupMenuItem(
                            value: 'complete',
                            child: Row(
                              children: [
                                Icon(Icons.check, size: 16),
                                SizedBox(width: 8),
                                Text('Mark Complete'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (notification.description != null &&
                    notification.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    notification.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateNotificationDialog() {
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            opaque: false, // This makes the background semi-transparent
            pageBuilder: (context, animation, secondaryAnimation) =>
                CreateNotificationDialog(selectedDate: _selectedDay),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        )
        .then((result) {
          if (result != null && result is NotificationModel) {
            _createNotification(result);
          }
        });
  }

  void _showNotificationOptions(NotificationModel notification) {
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) =>
                CreateNotificationDialog(existingNotification: notification),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        )
        .then((result) {
          if (result != null && result is NotificationModel) {
            _updateNotification(result);
          }
        });
  }

  Future<void> _createNotification(NotificationModel notification) async {
    try {
      print('Creating notification: ${notification.title}');
      print('Scheduled for: ${notification.scheduledDateTime}');

      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );

      final success = await notificationProvider.createNotification(
        notification,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Alarm scheduled successfully!'
                  : 'Failed to schedule alarm',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error in _createNotification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scheduling alarm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateNotification(NotificationModel notification) async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    final success = await notificationProvider.updateNotification(notification);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Notification updated successfully!'
                : 'Failed to update notification',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _handleNotificationAction(
    String action,
    NotificationModel notification,
  ) {
    switch (action) {
      case 'complete':
        _markNotificationComplete(notification);
        break;
      case 'edit':
        _showNotificationOptions(notification);
        break;
      case 'delete':
        _deleteNotification(notification);
        break;
    }
  }

  Future<void> _markNotificationComplete(NotificationModel notification) async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    final success = await notificationProvider.markAsCompleted(notification.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Notification marked as completed!'
                : 'Failed to update notification',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: Text(
          'Are you sure you want to delete "${notification.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );

      final success = await notificationProvider.deleteNotification(
        notification.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Notification deleted successfully!'
                  : 'Failed to delete notification',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
