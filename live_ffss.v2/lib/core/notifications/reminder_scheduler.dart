import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:timezone/timezone.dart' as tz;

/// Une notification locale à montrer en [at]. [id] est stable : une même
/// course garde le même rappel d'une planification à l'autre.
@immutable
class Reminder {
  const Reminder({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
  });

  final int id;
  final DateTime at;
  final String title;
  final String body;

  @override
  bool operator ==(Object other) =>
      other is Reminder &&
      other.id == id &&
      other.at == at &&
      other.title == title &&
      other.body == body;

  @override
  int get hashCode => Object.hash(id, at, title, body);

  @override
  String toString() => 'Reminder($id, $at, $title)';
}

/// Les rappels du téléphone. Une interface pour que les tests et le web
/// tournent sans la plateforme.
abstract interface class ReminderScheduler {
  /// Vrai si les notifications sont permises ; ne demande à l'utilisateur
  /// que si rien n'est encore décidé.
  Future<bool> requestPermission();

  /// Remplace tous les rappels planifiés par [reminders].
  Future<void> replaceAll(List<Reminder> reminders);

  Future<void> cancelAll();
}

/// Ailleurs qu'Android (web, tests), aucun rappel : rien n'est demandé ni
/// planifié.
class NoReminderScheduler implements ReminderScheduler {
  const NoReminderScheduler();

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> replaceAll(List<Reminder> reminders) async {}

  @override
  Future<void> cancelAll() async {}
}

/// Les rappels Android, par `flutter_local_notifications`. Alarmes inexactes :
/// quelques minutes d'écart suffisent pour un rappel, et l'exacte exigerait
/// `SCHEDULE_EXACT_ALARM`, que le Play Store réserve aux réveils et agendas.
class LocalNotificationsScheduler implements ReminderScheduler {
  LocalNotificationsScheduler(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _ready;

  static const _channelId = 'race_reminders';

  /// Nom du canal dans les réglages du téléphone. Le planificateur ne connaît
  /// pas la langue de l'app : celle de la FFSS.
  static const _channelName = 'Rappels de course';

  Future<void> _init() => _ready ??= _plugin
      .initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      )
      .then((_) {});

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> requestPermission() => _guard(() async {
    await _init();
    return await _android?.requestNotificationsPermission() ?? false;
  });

  @override
  Future<void> replaceAll(List<Reminder> reminders) => _guard(() async {
    await _init();
    await _plugin.cancelAllPendingNotifications();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    final now = DateTime.now();
    for (final reminder in reminders) {
      // Passé entre le calcul et ici, le plugin lèverait.
      if (!reminder.at.isAfter(now)) continue;
      await _plugin.zonedSchedule(
        id: reminder.id,
        // Un instant, pas une heure murale : l'UTC évite de lire le fuseau du
        // téléphone, et un rappel ponctuel ne dépend pas de l'heure d'été.
        scheduledDate: tz.TZDateTime.from(reminder.at, tz.UTC),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: reminder.title,
        body: reminder.body,
      );
    }
  });

  @override
  Future<void> cancelAll() => _guard(() async {
    await _init();
    await _plugin.cancelAllPendingNotifications();
  });

  /// La plateforme lève des `PlatformException`, que les appelants n'attrapent
  /// pas : traduites en [AppException], la seule qu'ils attrapent.
  static Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on PlatformException catch (e) {
      throw UnknownException(e.message ?? e.code);
    }
  }
}

/// Les rappels ne sont pris en charge que sur Android (décision du
/// 2026-10-18) : le web n'en a pas, l'iPhone viendra plus tard.
final remindersSupportedProvider = Provider<bool>(
  (ref) => !kIsWeb && defaultTargetPlatform == TargetPlatform.android,
);

final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => ref.watch(remindersSupportedProvider)
      ? LocalNotificationsScheduler(FlutterLocalNotificationsPlugin())
      : const NoReminderScheduler(),
);
