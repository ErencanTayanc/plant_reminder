import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/plant_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'plant_watering';
  static const _channelName = 'Plant Watering Reminders';
  static const _channelDesc = 'Daily reminders to water your plants';

  Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(settings: const InitializationSettings(android: android, iOS: ios));

    // Request permissions (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Schedule (or reschedule) the daily watering reminder.
  /// Call this whenever the reminder time changes or plants change.
  Future<void> scheduleDailyReminder({required int hour, required int minute, required List<Plant> plants}) async {
    // Cancel existing reminder before rescheduling
    await _plugin.cancel(id: 0);

    final criticalNames = plants.where((p) => p.urgency == WaterUrgency.critical).map((p) => p.name).toList();
    final soonNames = plants.where((p) => p.urgency == WaterUrgency.soon).map((p) => p.name).toList();

    // Build notification body
    String body;
    if (criticalNames.isEmpty && soonNames.isEmpty) {
      body = 'All your plants are doing well today 🌿';
    } else if (criticalNames.isNotEmpty && soonNames.isNotEmpty) {
      body = '💧 ${criticalNames.join(', ')} need water now · ${soonNames.join(', ')} need water tomorrow';
    } else if (criticalNames.isNotEmpty) {
      body = '💧 ${criticalNames.join(', ')} need water now!';
    } else {
      body = '🌱 ${soonNames.join(', ')} need water tomorrow';
    }

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    // If time already passed today, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: 0,
      title: '🌿 Plant Watering',
      body: body,
      scheduledDate: scheduled,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
    );
  }

  /// Fire an immediate notification when a plant is watered (confirmation).
  Future<void> showWateredConfirmation(String plantName) async {
    await _plugin.show(
      id: 1,
      title: '💧 Watered!',
      body: '$plantName has been watered. Next reminder is on the way!',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
