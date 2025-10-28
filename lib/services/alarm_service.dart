import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';
import 'dart:async';

class AlarmService {
  static final AlarmService instance = AlarmService._init();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  // Map to track active alarms
  final Map<int, Timer> _activeAlarms = {};
  final Map<int, Completer<void>> _alarmCompleters = {};
  
  AlarmService._init();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onDidReceiveBackgroundNotificationResponse,
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      // Request notification permission
      await androidPlugin.requestNotificationsPermission();
      
      // Request exact alarm permission for Android 12+
      await androidPlugin.requestExactAlarmsPermission();
    }

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void _onNotificationTapped(NotificationResponse response) {
    final id = int.tryParse(response.payload ?? '');
    if (id != null) {
      if (response.actionId == 'STOP_ALARM') {
        // Stop all alarm notifications
        stopAllAlarmNotifications(id);
      } else {
        // If this is an alarm notification, stop all alarm notifications (tapping stops it)
        stopAllAlarmNotifications(id);
      }
    }
    print('Notification tapped: ${response.payload}');
  }

  // Background callback for when notifications are triggered
  @pragma('vm:entry-point')
  static void _onDidReceiveBackgroundNotificationResponse(
      NotificationResponse response) {
    final id = int.tryParse(response.payload ?? '');
    if (id != null) {
      if (response.actionId == 'STOP_ALARM') {
        // Stop all alarm notifications for this ID
        AlarmService.instance.stopAllAlarmNotifications(id);
      }
    }
  }

  /// Schedule an alarm notification that will ring for 10 seconds
  Future<void> scheduleAlarmNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      // High priority notification with fallback sound handling
      final androidDetails = _createAndroidNotificationDetails(
        'alarm_channel',
        'Alarm Notifications',
        'High priority alarm notifications for tasks',
        'Alarm: $title',
        scheduledDate.millisecondsSinceEpoch,
        true, // persistent
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'alarm_sound.aiff',
        interruptionLevel: InterruptionLevel.critical,
        categoryIdentifier: 'ALARM_CATEGORY',
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);

      print('Scheduling alarm notification:');
      print('ID: $id');
      print('Title: $title');
      print('Scheduled for: $scheduledTZ');

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        details,
        payload: id.toString(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      // Schedule automatic alarm start when notification triggers
      _scheduleAlarmStart(id, scheduledTZ);

      print('Alarm notification scheduled successfully');
    } catch (e) {
      print('Error scheduling alarm notification: $e');
      rethrow;
    }
  }

  /// Create Android notification details with sound fallback
  AndroidNotificationDetails _createAndroidNotificationDetails(
    String channelId,
    String channelName,
    String channelDescription,
    String ticker,
    int when,
    bool persistent,
  ) {
    try {
      // Try custom sound first
      return AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('alarm_sound'),
        ongoing: persistent,
        autoCancel: false,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        ticker: ticker,
        showWhen: true,
        when: when,
        timeoutAfter: persistent ? null : 10000,
        actions: const [
          AndroidNotificationAction(
            'STOP_ALARM',
            'Stop Alarm',
            cancelNotification: true,
          ),
        ],
      );
    } catch (e) {
      // Fallback to default system sound if custom sound fails
      print('Custom sound failed, using system default: $e');
      return AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true,
        playSound: true,
        // No custom sound - use system default
        ongoing: persistent,
        autoCancel: false,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        ticker: ticker,
        showWhen: true,
        when: when,
        timeoutAfter: persistent ? null : 10000,
        actions: const [
          AndroidNotificationAction(
            'STOP_ALARM',
            'Stop Alarm',
            cancelNotification: true,
          ),
        ],
      );
    }
  }

  /// Schedule automatic alarm start when notification triggers
  void _scheduleAlarmStart(int id, tz.TZDateTime scheduledTime) {
    final now = DateTime.now();
    final alarmTime = scheduledTime.toLocal();
    final difference = alarmTime.difference(now);

    if (difference.isNegative) {
      return; // Don't schedule if time has already passed
    }

    // Schedule repeated alarm notifications every 2 seconds for 10 seconds
    for (int i = 0; i < 5; i++) {
      final alarmNotificationTime = scheduledTime.add(Duration(seconds: i * 2));
      final repeatId = id + 1000 + i; // Use different IDs for repeat notifications
      
      _scheduleRepeatedAlarmNotification(
        repeatId,
        alarmNotificationTime,
        i == 4, // Last notification auto-cancels
      );
    }
  }

  /// Schedule a single repeated alarm notification
  Future<void> _scheduleRepeatedAlarmNotification(
    int id,
    tz.TZDateTime scheduledTime,
    bool isLast,
  ) async {
    try {
      final androidDetails = _createAndroidNotificationDetails(
        'repeated_alarm_channel',
        'Repeated Alarm Sound',
        'Repeated alarm sound notifications',
        '🚨 Alarm Ringing!',
        scheduledTime.millisecondsSinceEpoch,
        !isLast, // persistent unless it's the last one
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'alarm_sound.aiff',
        interruptionLevel: InterruptionLevel.critical,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        '🚨 Alarm!',
        'Your scheduled task reminder',
        scheduledTime,
        details,
        payload: (id - 1000).toString(), // Original alarm ID
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      print('Error scheduling repeated alarm: $e');
    }
  }

  /// Start alarm sound and vibration for 10 seconds
  void startAlarm(int id) {
    // Cancel any existing alarm with this ID
    stopAlarm(id);
    
    // Create a completer to track when alarm stops
    final completer = Completer<void>();
    _alarmCompleters[id] = completer;
    
    // Show persistent alarm notification
    _showAlarmNotification(id);
    
    // Start vibration pattern
    _startVibrationPattern();
    
    // Auto-stop after 10 seconds
    final timer = Timer(const Duration(seconds: 10), () {
      stopAlarm(id);
    });
    
    _activeAlarms[id] = timer;
    
    print('Alarm started for ID: $id');
  }

  /// Stop the alarm
  void stopAlarm(int id) {
    // Cancel the timer
    _activeAlarms[id]?.cancel();
    _activeAlarms.remove(id);
    
    // Stop vibration
    HapticFeedback.selectionClick();
    
    // Cancel the alarm notification
    _notifications.cancel(id);
    
    // Complete the completer if exists
    if (_alarmCompleters.containsKey(id) && !_alarmCompleters[id]!.isCompleted) {
      _alarmCompleters[id]!.complete();
    }
    _alarmCompleters.remove(id);
    
    print('Alarm stopped for ID: $id');
  }

  /// Show a persistent alarm notification while ringing
  Future<void> _showAlarmNotification(int id) async {
    final androidDetails = _createAndroidNotificationDetails(
      'active_alarm_channel',
      'Active Alarms',
      'Currently ringing alarms',
      'Alarm Ringing! 🚨',
      DateTime.now().millisecondsSinceEpoch,
      true, // persistent
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'alarm_sound.aiff',
      interruptionLevel: InterruptionLevel.critical,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      'Alarm Ringing! 🚨',
      'Your scheduled task reminder is active. Tap to stop.',
      details,
      payload: id.toString(),
    );
  }

  /// Start vibration pattern for alarm
  void _startVibrationPattern() {
    // Create a repeating vibration pattern
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_activeAlarms.isEmpty) {
        timer.cancel();
        return;
      }
      HapticFeedback.heavyImpact();
    });
  }

  /// Regular notification (no alarm)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'planner_channel',
      'Planner Notifications',
      channelDescription: 'Regular notifications for planner entries',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details);
  }

  /// Regular scheduled notification (no alarm)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'planner_channel',
        'Planner Notifications',
        channelDescription: 'Regular notifications for planner entries',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      print('Regular notification scheduled successfully');
    } catch (e) {
      print('Error scheduling notification: $e');
      rethrow;
    }
  }

  /// Cancel a specific notification/alarm
  Future<void> cancelNotification(int id) async {
    stopAlarm(id); // Also stops alarm if it's ringing
    await _notifications.cancel(id);
  }

  /// Cancel all notifications/alarms
  Future<void> cancelAllNotifications() async {
    // Stop all active alarms
    for (int id in List.from(_activeAlarms.keys)) {
      stopAlarm(id);
    }
    await _notifications.cancelAll();
  }

  /// Check if an alarm is currently ringing
  bool isAlarmRinging(int id) {
    return _activeAlarms.containsKey(id);
  }

  /// Get list of all active alarm IDs
  List<int> getActiveAlarmIds() {
    return List.from(_activeAlarms.keys);
  }

  /// Wait for alarm to stop (useful for testing)
  Future<void> waitForAlarmToStop(int id) async {
    if (_alarmCompleters.containsKey(id)) {
      await _alarmCompleters[id]!.future;
    }
  }

  /// Test alarm (rings immediately for 10 seconds)
  Future<void> testAlarm() async {
    const testId = 99999;
    await showNotification(
      id: testId,
      title: 'Test Alarm',
      body: 'Testing alarm functionality - this will ring for 10 seconds',
    );
    startAlarm(testId);
  }

  /// Get pending notifications for debugging
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Check if exact alarm permission is granted (Android 12+)
  Future<bool> canScheduleExactNotifications() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      return await androidPlugin.canScheduleExactNotifications() ?? false;
    }
    return true; // iOS or older Android versions
  }

  /// Stop all alarm notifications for a specific alarm ID
  Future<void> stopAllAlarmNotifications(int originalId) async {
    try {
      // Cancel the main notification
      await _notifications.cancel(originalId);
      
      // Cancel all repeated alarm notifications (IDs: originalId+1000 to originalId+1004)
      for (int i = 0; i < 5; i++) {
        await _notifications.cancel(originalId + 1000 + i);
      }
      
      // Stop any active alarm timers
      stopAlarm(originalId);
      
      print('Stopped all alarm notifications for ID: $originalId');
    } catch (e) {
      print('Error stopping alarm notifications: $e');
    }
  }
}