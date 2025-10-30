import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/planner_provider.dart';
import '../providers/alarm_provider.dart';
import '../models/notification_model.dart';
import '../widgets/glass_card.dart';
import '../widgets/create_notification_dialog.dart';

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
      Provider.of<AlarmProvider>(context, listen: false).loadAlarms();
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
        onPressed: () => _showCreateAlarmDialog(),
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
            final alarmProvider = Provider.of<AlarmProvider>(
              context,
              listen: false,
            );

            final entries = plannerProvider.getEntriesForDate(day);
            final alarms = alarmProvider.getAlarmsForDate(day);

            // Combine entries and alarms for event markers
            return [...entries, ...alarms];
          },
        ),
      ),
    );
  }

  Widget _buildContentList() {
    return Consumer2<PlannerProvider, AlarmProvider>(
      builder: (context, plannerProvider, alarmProvider, child) {
        final entries = plannerProvider.getEntriesForDate(_selectedDay);
        final alarms = alarmProvider.getAlarmsForDate(_selectedDay);

        if (entries.isEmpty && alarms.isEmpty) {
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
                    'No entries or alarms for this date',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap the + button to create an alarm',
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
          itemCount: entries.length + alarms.length,
          itemBuilder: (context, index) {
            final alarmIndex = index - entries.length;
              return _buildAlarmCard(context, alarms[alarmIndex]);
          },
        );
      },
    );
  }

  Widget _buildAlarmCard(BuildContext context, NotificationModel alarm) {
    final isOverdue =
        alarm.scheduledDateTime.isBefore(DateTime.now()) && !alarm.isCompleted;
    final isCompleted = alarm.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _showAlarmOptions(alarm),
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
                            ? Colors.green.withValues(alpha:0.1)
                            : isOverdue
                            ? Colors.red.withValues(alpha:0.1)
                            : const Color(0xFF6366F1).withValues(alpha:0.1),
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
                            alarm.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
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
                                  alarm.time,
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
                                    color: Colors.red.withValues(alpha:0.1),
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
                                    color: Colors.green.withValues(alpha:0.1),
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
                      onSelected: (value) => _handleAlarmAction(value, alarm),
                      itemBuilder: (context) => [
                        if (!alarm.isCompleted)
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
                if (alarm.description != null &&
                    alarm.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    alarm.description!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateAlarmDialog() {
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
            _createAlarm(result);
          }
        });
  }

  void _showAlarmOptions(NotificationModel alarm) {
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) =>
                CreateNotificationDialog(existingNotification: alarm),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        )
        .then((result) {
          if (result != null && result is NotificationModel) {
            _updateAlarm(result);
          }
        });
  }

  Future<void> _createAlarm(NotificationModel notification) async {
    try {
      debugPrint('Creating notification: ${notification.title}');
      debugPrint('Scheduled for: ${notification.scheduledDateTime}');

      final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);

      final success = await alarmProvider.createAlarm(notification);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Notification scheduled successfully!'
                  : 'Failed to schedule alarm',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error in _createAlarm: $e');
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

  Future<void> _updateAlarm(NotificationModel alarm) async {
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);

    // Reset completion status when editing - if the alarm is rescheduled, it should be active again
    final updatedAlarm = alarm.copyWith(
      isCompleted: false,
      updatedAt: DateTime.now(),
    );

    final success = await alarmProvider.updateAlarm(updatedAlarm);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Notification updated successfully!' : 'Failed to update notification',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _handleAlarmAction(String action, NotificationModel alarm) {
    switch (action) {
      case 'complete':
        _markAlarmComplete(alarm);
        break;
      case 'edit':
        _showAlarmOptions(alarm);
        break;
      case 'delete':
        _deleteAlarm(alarm);
        break;
    }
  }

  Future<void> _markAlarmComplete(NotificationModel alarm) async {
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);

    final success = await alarmProvider.markAsCompleted(alarm.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Notification marked as completed!' : 'Failed to update noitification',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteAlarm(NotificationModel alarm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alarm'),
        content: Text('Are you sure you want to delete "${alarm.title}"?'),
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
      final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);

      final success = await alarmProvider.deleteAlarm(alarm.id);

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
