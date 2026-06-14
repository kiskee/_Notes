import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notes/models/note.dart';
import 'package:push_notes/navigation.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    final noteKey = int.tryParse(payload);
    if (noteKey == null) return;
    selectedNoteKeyNotifier.value = noteKey;
  }

  Future<void> _schedule(Note note) async {
    final id = note.key.hashCode;

    final androidDetails = AndroidNotificationDetails(
      'note_reminders',
      'Recordatorios',
      channelDescription: 'Recordatorios de notas',
      importance: Importance.high,
      priority: Priority.high,
      color: const Color(0xFF000000),
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final title = note.title;
    final body = note.description.isNotEmpty
        ? note.description
        : 'Tienes ${note.todos.length} tareas pendientes';

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(note.reminderAt!, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: note.key.toString(),
        matchDateTimeComponents: null,
      );
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permited') {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(note.reminderAt!, tz.local),
          details,
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: note.key.toString(),
          matchDateTimeComponents: null,
        );
      } else {
        rethrow;
      }
    }
  }

  Future<bool> scheduleNoteReminder(Note note) async {
    if (note.reminderAt == null) return false;
    if (note.reminderAt!.isBefore(DateTime.now())) return false;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestExactAlarmsPermission();
      final granted = await android.requestNotificationsPermission();
      if (granted != true) return false;
    }

    await _schedule(note);
    return true;
  }

  Future<bool> restoreNoteReminder(Note note) async {
    if (note.reminderAt == null) return false;
    if (note.reminderAt!.isBefore(DateTime.now())) return false;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final enabled = await android.areNotificationsEnabled();
      if (enabled != true) return false;
    }

    await _schedule(note);
    return true;
  }

  Future<void> cancelNoteReminder(Note note) async {
    await _plugin.cancel(note.key.hashCode);
  }
}
