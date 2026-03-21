import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../db/models/debt_transaction.dart';
import '../db/models/enums.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'raseed_due_dates';
  static const _channelName = 'Due Date Reminders';
  static const _channelDesc =
      'Alerts when a transaction reaches its due date';

  static Future<void> initialize() async {
    // Use UTC as the base; we'll schedule using wall-clock (local) time
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
    );

    // Create Android notification channel
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
          ),
        );

    // Request Android 13+ notification permission
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Schedule a due-date notification for a transaction.
  /// Fires at 9:00 AM local time on the due date.
  static Future<void> scheduleTransactionDue(DebtTransaction tx) async {
    if (tx.dueDate == null) return;
    if (tx.status == TransactionStatus.settled) return;

    final due = tx.dueDate!;

    // Build the scheduled time as local wall-clock time
    final scheduledLocal = DateTime(due.year, due.month, due.day, 9, 0, 0);
    if (scheduledLocal.isBefore(DateTime.now())) return;

    // Represent it as a TZDateTime in UTC (wallClockTime interpretation fires at local time)
    final tzScheduled = tz.TZDateTime(
      tz.UTC,
      scheduledLocal.year,
      scheduledLocal.month,
      scheduledLocal.day,
      scheduledLocal.hour,
      scheduledLocal.minute,
      scheduledLocal.second,
    );

    final personName = tx.person.value?.name ?? '';
    final isDebt = tx.type == TransactionType.debt;
    final amount = tx.remaining.toStringAsFixed(2);

    final title = isDebt ? '💰 Payment Due Today' : '📅 Loan Due Today';
    final body = isDebt
        ? '$personName owes you $amount — due today'
        : 'You owe $personName $amount — due today';

    await _plugin.zonedSchedule(
      _notifId(tx.id),
      title,
      body,
      tzScheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  /// Cancel the notification for a transaction (settled or deleted).
  static Future<void> cancel(int txId) async {
    await _plugin.cancel(_notifId(txId));
  }

  /// Re-sync all scheduled notifications with current DB state.
  /// Called on app startup.
  static Future<void> syncAll(List<DebtTransaction> transactions) async {
    await _plugin.cancelAll();
    for (final tx in transactions) {
      if (tx.dueDate != null && tx.status != TransactionStatus.settled) {
        await scheduleTransactionDue(tx);
      }
    }
  }

  // Android notification IDs must fit in int32
  static int _notifId(int txId) => txId % 2147483647;
}
