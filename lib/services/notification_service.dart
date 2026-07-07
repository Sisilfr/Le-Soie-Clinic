import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    print('NotificationService: init() started');
    tz.initializeTimeZones();

    try {
      final TimezoneInfo currentTimeZone = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = currentTimeZone.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      print('NotificationService: Device timezone detected as: $timeZoneName');
    } catch (e) {
      print('NotificationService: Failed to get local timezone, defaulting to UTC: $e');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
    print('NotificationService: Plugin initialized successfully');

    // Create the required Android notification channel explicitly
    await _createAndroidNotificationChannel();

    // Initial permission request
    await requestPermissions();
  }

  Future<void> _createAndroidNotificationChannel() async {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_reminder_channel', // id
      'Daily Reminders', // name
      description: 'Daily skincare routine reminders', // description
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    try {
      await androidPlugin?.createNotificationChannel(channel);
      print('NotificationService: Android notification channel created successfully');
    } catch (e) {
      print('NotificationService: Failed to create Android notification channel: $e');
    }
  }

  Future<bool> requestPermissions() async {
    print('NotificationService: requestPermissions() triggered');
    // Request for Android 13+ (API 33+)
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    // Request notifications permission (post notifications)
    final bool? androidGranted = await androidImplementation?.requestNotificationsPermission();
    print('NotificationService: Android notifications permission granted: $androidGranted');

    // Request exact alarm permission (Android 12+)
    final bool? exactAlarmGranted = await androidImplementation?.requestExactAlarmsPermission();
    print('NotificationService: Android exact alarm permission granted: $exactAlarmGranted');

    return androidGranted ?? false;
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    print('NotificationService: showInstantNotification() called with id=$id');
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Daily skincare routine reminders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
    print('NotificationService: Instant notification show request sent to system');
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    print('NotificationService: scheduleDailyReminder() invoked for id=$id, target time $hour:$minute');
    
    // Get the current time in the local timezone space
    final now = tz.TZDateTime.now(tz.local);
    print('NotificationService: Current time in tz.local: $now');
    
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    print('NotificationService: Constructed scheduled Date today: $scheduledDate');

    // If the scheduled time has already passed today, set it for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      print('NotificationService: Scheduled date was in the past. Moved to tomorrow: $scheduledDate');
    } else {
      print('NotificationService: Scheduled date is in the future. Kept for today: $scheduledDate');
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Daily skincare routine reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('NotificationService: zonedSchedule registered with exactAllowWhileIdle for $scheduledDate');
    } catch (e) {
      print('NotificationService: Failed to schedule with exactAllowWhileIdle ($e). Falling back to inexactAllowWhileIdle.');
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('NotificationService: zonedSchedule registered with inexactAllowWhileIdle for $scheduledDate');
    }

    // Print all pending notifications to confirm registration
    await printPendingNotificationRequests();
  }

  Future<void> cancelReminder(int id) async {
    print('NotificationService: cancelReminder() called for id=$id');
    await flutterLocalNotificationsPlugin.cancel(id);
    await printPendingNotificationRequests();
  }

  Future<void> printPendingNotificationRequests() async {
    try {
      final List<PendingNotificationRequest> pendingRequests =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      print('NotificationService: [PENDING LOG] Total pending requests: ${pendingRequests.length}');
      for (var r in pendingRequests) {
        print('NotificationService: [PENDING LOG] -> ID=${r.id}, Title="${r.title}", Body="${r.body}"');
      }
    } catch (e) {
      print('NotificationService: [PENDING LOG] Failed to retrieve pending requests: $e');
    }
  }
}
